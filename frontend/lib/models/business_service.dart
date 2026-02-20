import 'package:schedula/models/business.dart';

class BusinessService {
  final int id;
  final String name;
  final double? price;
  final int? durationMinutes;
  final String? iconUrl;
  final Business business;

  BusinessService({
    required this.id,
    required this.name,
    this.price,
    this.durationMinutes,
    this.iconUrl,
    required this.business,
  });

  // Costruttore factory che a partire da un oggetto json costruisce un BusinessService
  factory BusinessService.fromJson(Map<String, dynamic> json) {
    final businessJson = json['business'] ?? {};
    return BusinessService(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      durationMinutes: json['durationMinutes'],
      iconUrl: json['iconUrl'],
      business: Business.fromJson({
        'id': businessJson['id'],
        'name': businessJson['name'],
        'address': businessJson['address'],
        'photoUrl': businessJson['photoUrl'],
        'services': businessJson['services'],
        'businessName': businessJson['businessName'],
      })
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'iconUrl': iconUrl,
      'business': business.toJson()
    };
  }
}
