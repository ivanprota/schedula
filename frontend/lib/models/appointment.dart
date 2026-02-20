import 'package:schedula/models/user.dart';

import 'business_service.dart';
import 'appointments_status.dart';

class Appointment {
  final int id;
  final String date; // "2025-03-10"
  final String time; // "10:30:00"
  final AppointmentsStatus status;
  final BusinessService service;
  final User? user;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.service,
    this.user
  });

  // Costruttore factory che a partire da un oggetto json crea un Appointment
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json["id"],
      date: json["date"],
      time: json["time"],
      status: statusFromString(json["status"]),
      service: BusinessService.fromJson(json["service"]),
      user: json["user"] != null ? User.fromJson(json["user"]) : null
    );
  }

  // Converte le due stringhe date e time in un singolo oggetto DateTime
  DateTime getDateTime() {

    // split delle stringhe in array
    final dateParts = date.split('-');       // ["2025", "03", "10"]
    final timeParts = time.split(':');       // ["10", "30", "00"]

    return DateTime(
      int.parse(dateParts[0]),               // anno
      int.parse(dateParts[1]),               // mese
      int.parse(dateParts[2]),               // giorno
      int.parse(timeParts[0]),               // ora
      int.parse(timeParts[1]),               // minuti
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time, 
      'status': statusToString(status),
      'service': service.toJson(),
    };
  }
}
