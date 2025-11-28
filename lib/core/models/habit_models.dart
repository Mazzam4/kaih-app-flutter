

class Habit {
  final String name;
  final String description;
  final String iconPath;
  final bool isMultiEntry;

  Habit({
    required this.name,
    required this.description,
    required this.iconPath,
    this.isMultiEntry = false,
  });
}