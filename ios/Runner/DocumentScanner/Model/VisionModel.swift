import SwiftUI
import Vision
internal import Combine
internal import DataDetection
#if canImport(FoundationModels)
import FoundationModels
#endif

// Custom model for a recognized line in the document.
struct RecognizedLine {
    let text: String
    let boundingBox: CGRect
}

struct RecognizedTableRow {
    let columns: [String]
}

struct InvoiceMakerModel: Equatable, Hashable, Codable {
    let date: String
    let totalAmount: String
    let currencySymbol: String
    let storeName: String
    let address: String
    let personName: String
}

struct ScannedBillResult: Equatable, Hashable, Codable {
    let title: String
    let totalAmount: Double
    let currencySymbol: String
    let date: String
}

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct FoundationInvoiceExtraction {
    @Guide(description: "Invoice or bill date as plain text.")
    let date: String

    @Guide(description: "Final payable total amount only, returned as a numeric string without extra commentary.")
    let totalAmount: String

    @Guide(description: "Currency symbol for the final amount, such as ₹, $, £, or €.")
    let currencySymbol: String

    @Guide(description: "Store or merchant name from the bill.")
    let storeName: String

    @Guide(description: "Business or billing address from the bill.")
    let address: String

    @Guide(description: "Customer or recipient name from the bill if present.")
    let personName: String
}
#endif

final class VisionModel: ObservableObject {

    enum AppError: Error {
        case noDocument
        case noTable
        case invalidPoint
        case visionFailed
        case foundationModelsUnavailable
    }

    @Published var recognizedLines: [RecognizedLine] = []
    @Published var recognizedTable: [RecognizedTableRow] = []
    @Published var contacts = [Contact]()
    @Published var summarisedData: InvoiceMakerModel? = nil
    @Published var showBillSummary: Bool = false
    @Published var isShowLoading: Bool = true
    @Published var loadingText: String = ""
    @Published var scannedBill: ScannedBillResult? = nil

    private var currentTask: Task<Void, Never>?

    deinit {
        currentTask?.cancel()
    }

    func recognizeTable(in image: Data) async {
        resetState()
        currentTask?.cancel()
        currentTask = Task {
            self.loadingText = "Recognizing document..."
            do {
                let lines: [RecognizedLine]
                let table: [RecognizedTableRow]
                if #available(iOS 26.0, *) {
                    let documentContent = try await extractDocumentContent(from: image)
                    lines = documentContent.lines
                    table = documentContent.tableRows
                } else {
                    lines = try await recognizeText(in: image)
                    table = self.extractSimpleTable(from: lines)
                }
                await MainActor.run {
                    self.recognizedLines = lines
                    self.recognizedTable = table
                    self.contacts = self.parseContacts(from: table)
                }
            } catch {
                print("Vision recognizeTable failed: \(error)")
                await MainActor.run { self.loadingText = "" }
            }
        }
    }

    func resetState() {
        currentTask?.cancel()
        currentTask = nil
        self.recognizedLines = []
        self.recognizedTable = []
        self.contacts = []
        self.summarisedData = nil
        self.showBillSummary = false
        self.loadingText = ""
        self.scannedBill = nil
    }

    func recognizeBill(in image: Data) async -> ScannedBillResult? {
        resetState()
        do {
            self.loadingText = "Scanning bill..."
            let lines: [RecognizedLine]
            let paragraphs: [String]
            let tableRows: [RecognizedTableRow]

            if #available(iOS 26.0, *) {
                let documentContent = try await extractDocumentContent(from: image)
                lines = documentContent.lines
                paragraphs = documentContent.paragraphs
                tableRows = documentContent.tableRows
            } else {
                lines = try await recognizeText(in: image)
                paragraphs = lines.map { $0.text }
                tableRows = self.extractSimpleTable(from: lines)
            }

            let textParagraph = paragraphs.joined(separator: "\n")
            let parsedBill = try await summarizedBill(from: textParagraph, fallbackLines: paragraphs)
            await MainActor.run {
                self.recognizedLines = lines
                self.recognizedTable = tableRows
                self.loadingText = ""
                self.scannedBill = parsedBill
            }
            return parsedBill
        } catch {
            await MainActor.run {
                self.loadingText = ""
            }
            print("Bill scanning failed: \(error)")
            return nil
        }
    }

    func exportTable() async throws -> String {
        guard !self.recognizedTable.isEmpty else {
            throw AppError.noTable
        }
        let tableRowData = recognizedTable.map { $0.columns.joined(separator: "\t") }
        let textParagraph = recognizedLines.map { $0.text }.joined(separator: "\n")
        isShowLoading = false
        do {
            loadingText = "Analyzing document..."
            summarisedData = try await summarizeArticle(articleText: textParagraph)
            withAnimation { showBillSummary = true }
        } catch {
            if isFoundationModelsUnavailable(error) {
                print("Foundation Models unavailable on this device right now.")
            } else {
                print("Summarization failed: \(error)")
            }
        }
        return tableRowData.joined(separator: "\n")
    }

    // Stub: You'd need to call a server or Core ML model for this pre-iOS 26
    func summarizeArticle(articleText: String) async throws -> InvoiceMakerModel {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let session = LanguageModelSession()
            let prompt = """
            Take a summary of the following bill or invoice OCR text and give date, currency symbol, total amount, address, store name and person name.
            totalAmount must be only the final payable bill total in numbers, not GST, CGST, SGST, taxable value, discount, round off, subtotal, or line item amounts.

            \(articleText)
            """

            let response = try await session.respond(generating: FoundationInvoiceExtraction.self) {
                prompt
            }

            loadingText = ""
            return InvoiceMakerModel(
                date: response.content.date.trimmingCharacters(in: .whitespacesAndNewlines),
                totalAmount: sanitizedAmountString(response.content.totalAmount),
                currencySymbol: normalizedCurrencySymbol(response.content.currencySymbol),
                storeName: response.content.storeName.trimmingCharacters(in: .whitespacesAndNewlines),
                address: response.content.address.trimmingCharacters(in: .whitespacesAndNewlines),
                personName: response.content.personName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        #endif

        throw AppError.foundationModelsUnavailable
    }

    @available(iOS 26.0, *)
    private func extractDocumentContent(
        from image: Data
    ) async throws -> (
        paragraphs: [String],
        tableRows: [RecognizedTableRow],
        lines: [RecognizedLine]
    ) {
        let request = RecognizeDocumentsRequest()
        let observations = try await request.perform(on: image)

        guard let document = observations.first?.document else {
            throw AppError.noDocument
        }

        let paragraphs = document.paragraphs.map { $0.transcript }
        let lines = paragraphs.map { RecognizedLine(text: $0, boundingBox: .zero) }
        let tableRows = document.tables.first?.rows.map { row in
            RecognizedTableRow(
                columns: row.map { $0.content.text.transcript }
            )
        } ?? []

        return (paragraphs: paragraphs, tableRows: tableRows, lines: lines)
    }

    // MARK: - Vision text recognition (available since iOS 13)
    private func recognizeText(in imageData: Data) async throws -> [RecognizedLine] {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            throw AppError.visionFailed
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            throw AppError.visionFailed
        }
        return observations.compactMap { obs in
            guard let candidate = obs.topCandidates(1).first else { return nil }
            return RecognizedLine(text: candidate.string, boundingBox: obs.boundingBox)
        }
    }

    // Simple heuristic: look for tab-separated or multi-space-separated lines as "table rows"
    private func extractSimpleTable(from lines: [RecognizedLine]) -> [RecognizedTableRow] {
        let tableRows: [RecognizedTableRow] = lines.compactMap { line in
            let cellSeparators = ["\t", "  "] // tab or multiple spaces
            for sep in cellSeparators {
                let columns = line.text.components(separatedBy: sep).map { $0.trimmingCharacters(in: .whitespaces) }
                if columns.count > 1 {
                    return RecognizedTableRow(columns: columns)
                }
            }
            return nil
        }
        return tableRows
    }

    // Extract name, email, phone from rows (only as a stub)
    private func parseContacts(from rows: [RecognizedTableRow]) -> [Contact] {
        var contacts = [Contact]()
        for row in rows {
            let name = row.columns.first ?? ""
            let email = row.columns.first(where: { $0.contains("@") }) ?? ""
            let phone = row.columns.first(where: { $0.range(of: #"(\+?\d[\d \-\(\)]{7,})"#, options: .regularExpression) != nil })
            if !email.isEmpty {
                contacts.append(Contact(name: name, email: email, phoneNumber: phone))
            }
        }
        return contacts
    }

    private func summarizedBill(from articleText: String, fallbackLines: [String]) async throws -> ScannedBillResult? {
        let heuristicResult = parseBill(from: fallbackLines)

        do {
            self.loadingText = "Extracting bill details..."
            let summary = try await summarizeArticle(articleText: articleText)
            if let foundationResult = scannedBill(from: summary, fallbackLines: fallbackLines) {
                return foundationResult
            }
        } catch {
            if isFoundationModelsUnavailable(error) {
                print("Foundation Models unavailable on this device right now. Falling back to OCR parser.")
            } else {
                print("Foundation Models extraction failed: \(error)")
            }
        }

        return heuristicResult
    }

    private func scannedBill(from summary: InvoiceMakerModel, fallbackLines: [String]) -> ScannedBillResult? {
        let fallback = parseBill(from: fallbackLines)
        let title = firstNonEmpty(summary.storeName, fallback?.title, "Scanned Bill")
        let date = firstNonEmpty(summary.date, fallback?.date, "")
        let currencySymbol = firstNonEmpty(
            normalizedCurrencySymbol(summary.currencySymbol),
            fallback?.currencySymbol,
            "₹"
        )

        if let amount = amountValue(from: summary.totalAmount) {
            return ScannedBillResult(
                title: title,
                totalAmount: amount,
                currencySymbol: currencySymbol,
                date: date
            )
        }

        return fallback.map {
            ScannedBillResult(
                title: title.isEmpty ? $0.title : title,
                totalAmount: $0.totalAmount,
                currencySymbol: currencySymbol,
                date: date.isEmpty ? $0.date : date
            )
        }
    }

    // MARK: - Bill parsing logic (copied from your original)
    private func parseBill(from paragraphs: [String]) -> ScannedBillResult? {
        let cleanedLines = paragraphs
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleanedLines.isEmpty else {
            return nil
        }

        let title = cleanedLines.first(where: { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.rangeOfCharacter(from: .letters) != nil && !trimmed.lowercased().contains("tax invoice")
        }) ?? "Scanned Bill"

        let date = cleanedLines.first(where: { line in
            extractDate(from: line) != nil
        }).flatMap(extractDate) ?? ""

        if let prioritizedMatch = prioritizedAmountMatch(in: cleanedLines) {
            return ScannedBillResult(
                title: title,
                totalAmount: prioritizedMatch.amount,
                currencySymbol: prioritizedMatch.currencySymbol,
                date: date
            )
        }

        let fallbackMatches = cleanedLines
            .flatMap { line in extractAmounts(from: line) }
            .sorted { $0.amount > $1.amount }

        guard let fallback = fallbackMatches.first else {
            return nil
        }

        return ScannedBillResult(
            title: title,
            totalAmount: fallback.amount,
            currencySymbol: fallback.currencySymbol,
            date: date
        )
    }

    private func prioritizedAmountMatch(in lines: [String]) -> (amount: Double, currencySymbol: String)? {
        let strongLabels = [
            "grand total", "bill total", "invoice total", "net amount",
            "amount due", "balance due"
        ]
        let ignoredLabels = [
            "cgst", "sgst", "igst", "gst", "tax amount", "taxable value",
            "discount", "round off", "rate", "qty", "mrp", "hsn", "batch",
            "exp.", "mfg", "total amount (in words)", "hsn sac",
            "total tax amount"
        ]

        var candidates: [(amount: Double, currencySymbol: String, score: Int)] = []

        for line in lines {
            let normalized = normalizedBillText(line)
            guard isExactPayableTotalLine(normalized) else {
                continue
            }

            let matches = extractAmounts(from: line)
            if let exactTotal = matches.last {
                return exactTotal
            }
        }

        for (index, line) in lines.enumerated() {
            let normalized = normalizedBillText(line)

            guard normalized.contains("total")
                    || strongLabels.contains(where: { normalized.contains($0) })
            else {
                continue
            }

            guard !ignoredLabels.contains(where: { normalized.contains($0) }) else {
                continue
            }

            let sameLineMatches = extractAmounts(from: line)
            if !sameLineMatches.isEmpty {
                for (matchIndex, match) in sameLineMatches.enumerated() {
                    var score = 0

                    if strongLabels.contains(where: { normalized.contains($0) }) {
                        score += 220
                    }

                    if normalized == "total" || normalized.hasPrefix("total ") || normalized.contains(" total ") {
                        score += 300
                    }

                    if normalized.contains("invoice") || normalized.contains("bill") {
                        score += 30
                    }

                    if match.amount >= 100 {
                        score += 40
                    }

                    if match.amount >= 500 {
                        score += 60
                    }

                    if match.amount < 20 {
                        score -= 120
                    }

                    if normalized.contains("sub total") || normalized.contains("subtotal") {
                        score -= 30
                    }

                    // In invoice rows, the payable amount is usually the last amount on the line.
                    if matchIndex == sameLineMatches.count - 1 {
                        score += 120
                    }

                    candidates.append((match.amount, match.currencySymbol, score))
                }
                continue
            }

            let nearbyLines = Array(lines.dropFirst(index + 1).prefix(1))
            let nearbyMatches = nearbyLines.flatMap { extractAmounts(from: $0) }

            for match in nearbyMatches {
                var score = 0

                if strongLabels.contains(where: { normalized.contains($0) }) {
                    score += 180
                }

                if normalized == "total" || normalized.hasPrefix("total ") || normalized.contains(" total ") {
                    score += 220
                }

                if normalized.contains("invoice") || normalized.contains("bill") {
                    score += 30
                }

                if match.amount >= 100 {
                    score += 40
                }

                if match.amount >= 500 {
                    score += 60
                }

                if match.amount < 20 {
                    score -= 140
                }

                if normalized.contains("sub total") || normalized.contains("subtotal") {
                    score -= 30
                }

                candidates.append((match.amount, match.currencySymbol, score))
            }
        }

        return candidates
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.amount > rhs.amount
                }
                return lhs.score > rhs.score
            }
            .first
            .map { ($0.amount, $0.currencySymbol) }
    }

    private func isExactPayableTotalLine(_ normalized: String) -> Bool {
        guard normalized.contains("total") else {
            return false
        }

        let disallowedFragments = [
            "cgst", "sgst", "igst", "gst", "tax", "taxable", "amount in words",
            "total amount", "sub total", "subtotal", "hsn", "rate", "qty", "mrp",
            "discount", "round off"
        ]

        guard !disallowedFragments.contains(where: { normalized.contains($0) }) else {
            return false
        }

        return normalized == "total"
            || normalized.hasPrefix("total ")
            || normalized.contains(" total ")
    }

    private func extractAmounts(from line: String) -> [(amount: Double, currencySymbol: String)] {
        let pattern = #"((?:₹|Rs\.?|INR|\$|USD|EUR|£)\s*)?\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        let nsLine = line as NSString
        let matches = regex.matches(in: line, range: NSRange(location: 0, length: nsLine.length))

        return matches.compactMap { match in
            let rawValue = nsLine.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
            let currencySymbol = detectedCurrencySymbol(in: rawValue)
            let numericText = rawValue
                .replacingOccurrences(of: "INR", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "USD", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "EUR", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "Rs.", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "Rs", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "₹", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: "£", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: " ", with: "")

            guard let amount = Double(numericText), amount > 0 else {
                return nil
            }

            return (amount: amount, currencySymbol: currencySymbol)
        }
    }

    private func detectedCurrencySymbol(in value: String) -> String {
        let normalized = value.lowercased()
        if normalized.contains("₹") || normalized.contains("rs") || normalized.contains("inr") {
            return "₹"
        }
        if normalized.contains("$") || normalized.contains("usd") {
            return "$"
        }
        if normalized.contains("£") {
            return "£"
        }
        if normalized.contains("eur") {
            return "€"
        }
        return "₹"
    }

    private func normalizedCurrencySymbol(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ""
        }
        return detectedCurrencySymbol(in: trimmed)
    }

    private func sanitizedAmountString(_ value: String) -> String {
        let cleaned = value
            .replacingOccurrences(of: #"[^0-9.,]"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.contains(",") && cleaned.contains(".") {
            return cleaned.replacingOccurrences(of: ",", with: "")
        }
        return cleaned
    }

    private func amountValue(from value: String) -> Double? {
        let cleaned = sanitizedAmountString(value)
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned)
    }

    private func firstNonEmpty(_ candidates: String?...) -> String {
        for candidate in candidates {
            if let trimmed = candidate?.trimmingCharacters(in: .whitespacesAndNewlines),
               !trimmed.isEmpty {
                return trimmed
            }
        }
        return ""
    }

    private func isFoundationModelsUnavailable(_ error: Error) -> Bool {
        if case AppError.foundationModelsUnavailable = error {
            return true
        }

        let description = String(describing: error).lowercased()
        return description.contains("guardrailviolation")
            || description.contains("model catalog")
            || description.contains("modelcatalog")
            || description.contains("unifiedassetframework")
            || description.contains("sensitivecontentanalysisml")
    }

    private func normalizedBillText(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9 ]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractDate(from line: String) -> String? {
        let patterns = [
            #"\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b"#,
            #"\b\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4}\b"#,
            #"\b[A-Za-z]{3,9}\s+\d{1,2},\s+\d{4}\b"#
        ]

        let nsLine = line as NSString
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                continue
            }
            if let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)) {
                return nsLine.substring(with: match.range)
            }
        }
        return nil
    }
}
