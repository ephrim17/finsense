import SwiftUI
import Vision

@available(iOS 26.0, *)
struct ImageView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var imageDataModel: ImageDataViewModel
    @EnvironmentObject var viewModel: VisionModel
    @State var imageData: Data?
    
    @State private var loadingMessage = ""
    @State private var isAlertShowing = false
    
    var body: some View {
        ZStack {
             VStack(spacing: 16) {
                 if let uiImage = UIImage(data: imageDataModel.imageData ?? Data()) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 300, height: 400)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    if !viewModel.recognizedLines.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recognized Text")
                                .font(.headline)
                            ForEach(Array(viewModel.recognizedLines.prefix(8).enumerated()), id: \.offset) { _, line in
                                Text(line.text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                if viewModel.showBillSummary {
                    HStack(spacing: 0) {
                        Button(action: {
                            if let invoiceMakerItems = viewModel.summarisedData {
                                StorageManager.shared.saveInvoice(invoiceMakerItems)
                                let allInvoices = StorageManager.shared.loadInvoices()
                                router.navigate(to: .allSummaries(invoiceMakers: allInvoices))
                            }
                            imageDataModel.imageData = nil
                            viewModel.resetState()
                        }) {
                            Text("Save Updated Bill")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            //imageDataModel.imageData = nil
                            //viewModel.resetState()
                        }) {
                            Text("Re-Upload Bill")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
                }
            }
            LoadingOverlayView(loadingText: viewModel.loadingText)
        }
        .task {
            // Process the image with the simplified OCR-based recognizer.
            await viewModel.recognizeTable(in: imageDataModel.imageData ?? Data())
        }
        .onDisappear {
            viewModel.resetState()
        }
    }
    
    /// Copy the detected table to the clipboard and show an alert upon success.
    private func copyTable() {
        Task {
            UIPasteboard.general.string = try await viewModel.exportTable()
            withAnimation {
                isAlertShowing = true
            }
            try? await Task.sleep(for: .seconds(5))
            withAnimation {
                isAlertShowing = false
            }
        }
    }
}
