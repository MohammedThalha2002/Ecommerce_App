class ClothesService {
  static final List<String> clothes = [
    "Cotton Vesti",
    "Cotton Lungi",
    "Cotton Shirt Bit",
    "Boy Baby Dress",
    "Chudihtaar",
    "Leggins",
    "Tops",
    "Shalls",
    "Girl Baby Frock",
    "Girl Baby Midi",
    "Silk Saree",
    "Cotton Saree",
    "Poonam Saree"
];

  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(clothes);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}