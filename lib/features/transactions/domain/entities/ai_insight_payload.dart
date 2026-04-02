class AiInsightPayload {
  const AiInsightPayload({
    required this.headline,
    required this.summary,
    required this.mood,
    required this.highlights,
    required this.sections,
    required this.actionItems,
  });

  final String headline;
  final String summary;
  final String mood;
  final List<AiInsightHighlight> highlights;
  final List<AiInsightSection> sections;
  final List<String> actionItems;

  factory AiInsightPayload.fromJson(Map<String, dynamic> json) {
    return AiInsightPayload(
      headline: (json['headline'] as String? ?? '').trim(),
      summary: (json['summary'] as String? ?? '').trim(),
      mood: (json['mood'] as String? ?? 'steady').trim(),
      highlights: ((json['highlights'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AiInsightHighlight.fromJson)
          .toList(),
      sections: ((json['sections'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AiInsightSection.fromJson)
          .toList(),
      actionItems: ((json['actionItems'] as List<dynamic>?) ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }
}

class AiInsightHighlight {
  const AiInsightHighlight({
    required this.label,
    required this.value,
    required this.insight,
    required this.sentiment,
  });

  final String label;
  final String value;
  final String insight;
  final String sentiment;

  factory AiInsightHighlight.fromJson(Map<String, dynamic> json) {
    return AiInsightHighlight(
      label: (json['label'] as String? ?? '').trim(),
      value: (json['value'] as String? ?? '').trim(),
      insight: (json['insight'] as String? ?? '').trim(),
      sentiment: (json['sentiment'] as String? ?? 'neutral').trim(),
    );
  }
}

class AiInsightSection {
  const AiInsightSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  factory AiInsightSection.fromJson(Map<String, dynamic> json) {
    return AiInsightSection(
      title: (json['title'] as String? ?? '').trim(),
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }
}
