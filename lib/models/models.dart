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
  String? supersetId;
  int? supersetOrder;
  bool isHighPriority;

  Exercise({
    required this.name,
    this.imageUrl,
    List<SetData>? sets,
    this.hasLocalImage = false,
    this.groupId,
    this.supersetId,
    this.supersetOrder,
    this.isHighPriority = false,
  }) : sets = sets ?? [SetData(), SetData(), SetData()];

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
    'imageUrl': imageUrl,
    'hasLocalImage': hasLocalImage,
    'groupId': groupId,
    'supersetId': supersetId,
    'supersetOrder': supersetOrder,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'],
    imageUrl: json['imageUrl'],
    hasLocalImage: json['hasLocalImage'] ?? false,
    groupId: json['groupId'],
    supersetId: json['supersetId'],
    supersetOrder: json['supersetOrder'],
    sets:
        (json['sets'] as List?)
            ?.map((setJson) => SetData.fromJson(setJson))
            .toList() ??
        [],
  );

  bool get isPartOfGroup => groupId != null && groupId!.isNotEmpty;
  bool get isPartOfSuperset => supersetId != null && supersetId!.isNotEmpty;
}
