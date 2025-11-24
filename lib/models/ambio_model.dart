// models/ambio_model.dart
class Amiibo {
  final String amiiboSeries;
  final String character;
  final String gameSeries;
  final String head;
  final String image;
  final String name;
  final String tail;
  final String type;
  final Map<String, dynamic>? release;

  Amiibo({
    required this.amiiboSeries,
    required this.character,
    required this.gameSeries,
    required this.head,
    required this.image,
    required this.name,
    required this.tail,
    required this.type,
    this.release,
  });

  factory Amiibo.fromJson(Map<String, dynamic> json) {
    return Amiibo(
      amiiboSeries: json['amiiboSeries'] ?? '-',
      character: json['character'] ?? '-',
      gameSeries: json['gameSeries'] ?? '-',
      head: json['head'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '-',
      tail: json['tail'] ?? '',
      type: json['type'] ?? '-',
      // Handle jika release date kosong
      release: json['release'] is Map<String, dynamic> ? json['release'] : {},
    );
  }

  // Untuk simpan ke Local Storage (Favorite)
  Map<String, dynamic> toJson() {
    return {
      'amiiboSeries': amiiboSeries,
      'character': character,
      'gameSeries': gameSeries,
      'head': head,
      'image': image,
      'name': name,
      'tail': tail,
      'type': type,
      'release': release,
    };
  }
}
