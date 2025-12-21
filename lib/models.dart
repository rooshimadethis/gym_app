class SetData {
  String weight;
  String reps;

  SetData({this.weight = '', this.reps = ''});

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};

  factory SetData.fromJson(Map<String, dynamic> json) =>
      SetData(weight: json['weight'], reps: json['reps']);
}

class Exercise {
  String name;
  List<SetData> sets;
  String? imageUrl;
  bool hasLocalImage;
  String? groupId;

  Exercise({
    required this.name,
    this.imageUrl,
    List<SetData>? sets,
    this.hasLocalImage = false,
    this.groupId,
  }) : sets = sets ?? [SetData(), SetData(), SetData()];

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
    'imageUrl': imageUrl,
    'hasLocalImage': hasLocalImage,
    'groupId': groupId,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'],
    imageUrl: json['imageUrl'],
    hasLocalImage: json['hasLocalImage'] ?? false,
    groupId: json['groupId'],
    sets:
        (json['sets'] as List?)
            ?.map((setJson) => SetData.fromJson(setJson))
            .toList() ??
        [],
  );

  bool get isPartOfGroup => groupId != null && groupId!.isNotEmpty;
}
