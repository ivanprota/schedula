import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schedula/models/appointment.dart';

class AppointmentService {
  final String baseUrl = "http://10.0.2.2:8080/api/appointments";

  // ---------------------------------------------------------
  //  PRENOTAZIONI PER BUSINESS + DATA (per BookingPage)
  // ---------------------------------------------------------
  Future<List<Appointment>> getAppointmentsForBusiness(
      int businessId, DateTime date) async {
    
    final dateString =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    final response = await http.get(
      Uri.parse("$baseUrl/business/$businessId/date/$dateString"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((a) => Appointment.fromJson(a)).toList();
    } else {
      throw Exception("Errore nel caricamento delle prenotazioni");
    }
  }

  // ---------------------------------------------------------
  //  PRENOTAZIONI EFFETTUATE (utente standard)
  // ---------------------------------------------------------
  Future<List<Appointment>> getAppointmentsForUser(int userId) async {
    if (userId == -1) return []; // Utente non loggato → nessuna prenotazione

    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((a) => Appointment.fromJson(a)).toList();
    } else {
      throw Exception("Errore nel caricamento delle prenotazioni effettuate");
    }
  }

  // ---------------------------------------------------------
  //  PRENOTAZIONI RICEVUTE (titolare attività)
  // ---------------------------------------------------------
  Future<List<Appointment>> getAppointmentsForOwner(int ownerId) async {
    final url = "$baseUrl/owner/$ownerId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((a) => Appointment.fromJson(a)).toList();
    } else {
      throw Exception("Errore nel caricamento delle prenotazioni ricevute");
    }
  }


  // ---------------------------------------------------------
  //  CANCELLAZIONE PRENOTAZIONE
  // ---------------------------------------------------------
  Future<void> cancelAppointment(int id) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id/cancel"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Errore durante la cancellazione della prenotazione");
    }
  }

  // ---------------------------------------------------------
  //  CREAZIONE PRENOTAZIONE
  // ---------------------------------------------------------
  Future<void> createAppointment({
    required int businessId,
    required int serviceId,
    required DateTime date,
    required DateTime time,
    required int userId,
  }) async {
    if (userId == -1) {
      throw Exception("Devi effettuare il login per prenotare");
    }

    final body = jsonEncode({
      "businessId": businessId,
      "serviceId": serviceId,
      "date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "time":
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      "userId": userId,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Errore nella creazione della prenotazione");
    }
  }
}
