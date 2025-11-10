class SetData {
  String weight;
  String reps;

  SetData({this.weight = '', this.reps = ''});

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'reps': reps,
      };

  factory SetData.fromJson(Map<String, dynamic> json) => SetData(
        weight: json['weight'],
        reps: json['reps'],
      );
}

class Exercise {
  String name;
  List<SetData> sets;
  String? imageUrl;
  bool hasLocalImage;

  Exercise({required this.name, this.imageUrl, List<SetData>? sets, this.hasLocalImage = false})
      : sets = sets ?? [SetData(), SetData(), SetData()];

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets.map((set) => set.toJson()).toList(),
        'imageUrl': imageUrl,
        'hasLocalImage': hasLocalImage,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'],
        imageUrl: json['imageUrl'],
        hasLocalImage: json['hasLocalImage'] ?? false,
        sets: (json['sets'] as List)
            .map((setJson) => SetData.fromJson(setJson))
            .toList(),
      );
}
