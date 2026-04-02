import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/generative_ai_config.dart';
import '../../../budgets/domain/entities/budget_plan.dart';
import '../../../goals/domain/entities/savings_goal.dart';
import '../../domain/entities/ai_insight_payload.dart';
import '../../domain/entities/transaction_record.dart';

class FinancialInsightsService {
  const FinancialInsightsService();

  Future<AiInsightPayload> generateOverviewInsights({
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) async {
    final contextPrompt = _baseContextPrompt(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      currencyCode: currencyCode,
    );
    final prompt = '''
$contextPrompt

Task:
Create a polished financial-health review.

Output sections:
1. Overall financial health
2. Current spending observations
3. Top risk areas
4. Savings tips and tricks
5. 3 concrete actions for this week

Be encouraging, practical, and specific. Use short headings and bullets.
''';
    return _generate(prompt);
  }

  Future<AiInsightPayload> generateWeeklySummary({
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) {
    final contextPrompt = _baseContextPrompt(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      currencyCode: currencyCode,
    );
    final prompt = '''
$contextPrompt

Task:
Write a short weekly money summary.

Output sections:
1. This week at a glance
2. Biggest spending shifts
3. One win to celebrate
4. One thing to improve next week

Keep it concise and motivating.
''';
    return _generate(prompt);
  }

  Future<AiInsightPayload> generateBudgetSuggestions({
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) {
    final contextPrompt = _baseContextPrompt(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      currencyCode: currencyCode,
    );
    final prompt = '''
$contextPrompt

Task:
Act as a budget rescue coach.

Output sections:
1. Categories at risk
2. Why they are risky
3. Immediate fixes
4. Better spending swaps
5. A simple rescue plan for the rest of the month

Focus on category-level budget advice.
''';
    return _generate(prompt);
  }

  Future<AiInsightPayload> generateGoalPlan({
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) {
    final contextPrompt = _baseContextPrompt(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      currencyCode: currencyCode,
    );
    final prompt = '''
$contextPrompt

Task:
Create a goal-planning strategy using the user's existing savings goals and cash-flow behavior.

Output sections:
1. Goal progress snapshot
2. Which goal to prioritize first
3. Suggested monthly top-ups
4. What spending to trim to fund the goals
5. A realistic action plan

Be concrete with numbers when possible.
''';
    return _generate(prompt);
  }

  Future<AiInsightPayload> askCoach({
    required String userPrompt,
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) {
    final contextPrompt = _baseContextPrompt(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      currencyCode: currencyCode,
    );
    final prompt = '''
$contextPrompt

User request:
$userPrompt

Task:
Answer as a personal finance coach using the provided app data. Be helpful, practical, and specific. If relevant, suggest concrete next steps.
''';
    return _generate(prompt);
  }

  Future<AiInsightPayload> _generate(String prompt) async {
    final apiKey = GenerativeAiConfig.apiKey.trim();
    if (apiKey.isEmpty) {
      throw const FinancialInsightsException(
        'Add your Google AI API key in lib/core/config/generative_ai_config.dart',
      );
    }

    FinancialInsightsException? lastError;

    for (final model in GenerativeAiConfig.modelCandidates) {
      try {
        return await _generateWithModel(
          prompt: prompt,
          apiKey: apiKey,
          model: model,
        );
      } on FinancialInsightsException catch (error) {
        lastError = error;
        if (!_shouldTryNextModel(error.message)) {
          rethrow;
        }
      }
    }

    throw lastError ??
        const FinancialInsightsException(
          'Unable to generate insights right now. Please try again.',
        );
  }

  Future<AiInsightPayload> _generateWithModel({
    required String prompt,
    required String apiKey,
    required String model,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseJsonSchema': {
            'type': 'object',
            'properties': {
              'headline': {'type': 'string'},
              'summary': {'type': 'string'},
              'mood': {'type': 'string'},
              'highlights': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'label': {'type': 'string'},
                    'value': {'type': 'string'},
                    'insight': {'type': 'string'},
                    'sentiment': {'type': 'string'},
                  },
                  'required': ['label', 'value', 'insight', 'sentiment'],
                },
              },
              'sections': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'title': {'type': 'string'},
                    'items': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                  },
                  'required': ['title', 'items'],
                },
              },
              'actionItems': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
            'required': [
              'headline',
              'summary',
              'mood',
              'highlights',
              'sections',
              'actionItems',
            ],
          },
        },
      }),
    );

    if (response.statusCode >= 400) {
      throw FinancialInsightsException(_extractErrorMessage(response.body));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>? ?? const [];
    final firstCandidate = candidates.isNotEmpty
        ? candidates.first as Map<String, dynamic>
        : null;
    final content = firstCandidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>? ?? const [];
    final firstPart = parts.isNotEmpty ? parts.first as Map<String, dynamic> : null;
    final text = (firstPart?['text'] as String?)?.trim();

    if (text == null || text.isEmpty) {
      throw const FinancialInsightsException(
        'The AI response came back empty. Please try again.',
      );
    }

    try {
      return AiInsightPayload.fromJson(
        jsonDecode(text) as Map<String, dynamic>,
      );
    } catch (_) {
      throw const FinancialInsightsException(
        'The AI response format was invalid. Please try again.',
      );
    }
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return _humanizeErrorMessage(message);
      }
    } catch (_) {
      // Fall through to generic message.
    }
    return 'Unable to generate insights right now. Please try again.';
  }

  String _humanizeErrorMessage(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('quota exceeded') ||
        normalized.contains('rate-limit') ||
        normalized.contains('rate limit') ||
        normalized.contains('retry in')) {
      final retryMatch = RegExp(
        r'retry in\s+([0-9]+(?:\.[0-9]+)?)s',
        caseSensitive: false,
      ).firstMatch(message);
      final retrySeconds = retryMatch == null
          ? null
          : double.tryParse(retryMatch.group(1) ?? '');
      final roundedSeconds = retrySeconds?.ceil();

      return roundedSeconds == null
          ? 'FinSense Insights is a little busy right now. Please wait a moment and try again.'
          : 'FinSense Insights is a little busy right now. Please try again in about $roundedSeconds seconds.';
    }

    if (normalized.contains('api key')) {
      return 'The AI setup needs attention before insights can run.';
    }

    return message;
  }

  bool _shouldTryNextModel(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('busy right now') ||
        normalized.contains('not found') ||
        normalized.contains('not supported') ||
        normalized.contains('unavailable') ||
        normalized.contains('overloaded');
  }

  String _baseContextPrompt({
    required List<TransactionRecord> transactions,
    required List<BudgetPlan> budgets,
    required List<SavingsGoal> goals,
    required String currencyCode,
  }) {
    if (transactions.isEmpty) {
      throw const FinancialInsightsException(
        'Add a few transactions first to generate insights.',
      );
    }

    final expenseTransactions = transactions
        .where((item) => item.type.isIncome == false)
        .toList();
    final incomeTransactions = transactions
        .where((item) => item.type.isIncome)
        .toList();

    final totalIncome = incomeTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalExpenses = expenseTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final balance = totalIncome - totalExpenses;

    final topCategories = <String, double>{};
    for (final transaction in expenseTransactions) {
      topCategories.update(
        transaction.categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final sortedCategories = topCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final compactTransactions = transactions
        .map(
          (item) => {
            'type': item.type.name,
            'title': item.title,
            'amount': item.amount,
            'category': item.categoryName,
            'paymentMethod': item.paymentMethod,
            'date': item.transactionDate.toIso8601String(),
            'note': item.note,
          },
        )
        .toList();

    final compactBudgets = budgets
        .map(
          (item) => {
            'category': item.categoryName,
            'limitAmount': item.limitAmount,
            'spentAmount': item.spentAmount,
            'progress': item.progress,
            'health': item.health.name,
          },
        )
        .toList();

    final compactGoals = goals
        .map(
          (item) => {
            'title': item.title,
            'targetAmount': item.targetAmount,
            'currentAmount': item.currentAmount,
            'progress': item.progress,
            'deadline': item.deadline?.toIso8601String(),
            'status': item.status.name,
          },
        )
        .toList();

    return '''
You are a personal finance coach.

Analyze the following real user finance data and provide actionable financial guidance.

Rules:
- Focus on spending patterns, budget risk, savings behavior, goals, practical tips, and improvement suggestions.
- Be encouraging, concise, and specific.
- Mention amounts in $currencyCode.
- Do not invent data that is not present.

Summary:
- Total income: ${totalIncome.toStringAsFixed(2)}
- Total expenses: ${totalExpenses.toStringAsFixed(2)}
- Net balance: ${balance.toStringAsFixed(2)}
- Top expense categories: ${jsonEncode(sortedCategories.take(5).map((e) => {'category': e.key, 'amount': e.value}).toList())}

Transactions:
${jsonEncode(compactTransactions)}

Budgets:
${jsonEncode(compactBudgets)}

Goals:
${jsonEncode(compactGoals)}
''';
  }
}

class FinancialInsightsException implements Exception {
  const FinancialInsightsException(this.message);

  final String message;

  @override
  String toString() => message;
}
