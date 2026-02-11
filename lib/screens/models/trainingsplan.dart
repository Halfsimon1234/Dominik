// Datenmodell für Firebase
class Uebung {  // Klasse für eine einzelne Übung
  String name;
  int saetze;
  int wiederholungen;

  Uebung({required this.name, required this.saetze, required this.wiederholungen});

  Map<String, dynamic> toMap() {  // Umwandlung in Map, damit es in Firebase gespeichert werden kann
    return {
      'name': name,
      'saetze': saetze,
      'wiederholungen': wiederholungen,
    };
  }
}

class Trainingsplan { // Klasse für den Trainingsplan, bestehend aus mehreren Übungen
  String name;
  List<Uebung> uebungen;

  Trainingsplan({required this.name, required this.uebungen});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uebungen': uebungen.map((u) => u.toMap()).toList(),
      'createdAt': DateTime.now(),  // hilft beim Sortieren der Trainingspläne nach Erstellungszeit
    };
  }
}
