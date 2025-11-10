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

  Exercise({required this.name, List<SetData>? sets})
      : sets = sets ?? [SetData(), SetData(), SetData()];

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets.map((set) => set.toJson()).toList(),
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'],
        sets: (json['sets'] as List)
            .map((setJson) => SetData.fromJson(setJson))
            .toList(),
      );
}
