/// Inisial dari dua kata pertama nama, mis. "Rina Putri" -> "RP".
String profileInitials(String name) {
  final List<String> words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) {
    return '';
  }
  if (words.length == 1) {
    return words.first.substring(0, 1).toUpperCase();
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}
