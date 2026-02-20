import 'package:schedula/models/business.dart';

class User {
  final int id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String profileImage;
  final List<Business>? businesses;
  final List<dynamic>? appointments;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    this.businesses,
    this.appointments
  });

  // Costruttore factory che a partire da un oggetto json costruisce un User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
      businesses: (json['businesses'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map((b) => Business.fromJson(b))
        .toList(),
      appointments: json['appointments']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'businesses': businesses?.map((b) => b.toJson()).toList(),
      'appointments': []
    };
  }
}