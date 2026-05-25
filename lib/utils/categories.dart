const List<Map<String, String>> kCategories = [
  {'name': 'Food', 'emoji': '🍔'},
  {'name': 'Shopping', 'emoji': '🛒'},
  {'name': 'Transportation', 'emoji': '🚗'},
  {'name': 'Bills', 'emoji': '💡'},
  {'name': 'Entertainment', 'emoji': '🎬'},
  {'name': 'Health', 'emoji': '💊'},
  {'name': 'Travel', 'emoji': '✈️'},
  {'name': 'Education', 'emoji': '📚'},
  {'name': 'Other', 'emoji': '📦'},
];

String getCategoryEmoji(String category) {
  final match = kCategories.firstWhere(
    (c) => c['name']!.toLowerCase() == category.toLowerCase(),
    orElse: () => {'emoji': '📦'},
  );
  return match['emoji']!;
}