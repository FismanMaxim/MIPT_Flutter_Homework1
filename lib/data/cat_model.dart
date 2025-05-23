class Cat {
  final String id;
  final String url;
  final String breedName;
  final String description;
  final String temperament;

  Cat({
    required this.id,
    required this.url,
    required this.breedName,
    required this.description,
    required this.temperament,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'],
      url: json['url'],
      breedName: json['breeds'][0]['name'],
      description: json['breeds'][0]['description'],
      temperament: json['breeds'][0]['temperament'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'breedName': breedName,
        'description': description,
        'temperament': temperament,
      };

  static Cat fromSimpleJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'],
      url: json['url'],
      breedName: json['breedName'],
      description: json['description'],
      temperament: json['temperament'],
    );
  }
}
