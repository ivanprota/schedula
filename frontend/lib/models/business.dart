class Business {
  final int id;
  final String name;
  final String address;
  final String photoUrl;
  final List<dynamic>? services;
  final String? businessName;

  Business({
    required this.id,
    required this.name,
    required this.address,
    required this.photoUrl,
    this.services,
    this.businessName
  });

  // Costruttore factory che a partire da un oggetto json costruisce un Business
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? 0, 
      name: json['name'] ?? '', 
      address: json['address'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      services: json['services'],
      businessName: json['businessName']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'photoUrl': photoUrl,
      'businessName': businessName
    };
  }
}
