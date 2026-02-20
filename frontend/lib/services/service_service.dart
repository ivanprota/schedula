import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schedula/models/business_service.dart';

class ServiceService {
  final String baseUrl = "http://10.0.2.2:8080/api/business-services";

  Future<List<BusinessService>> getServicesOfBusiness(int businessId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/business/$businessId"),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((s) => BusinessService.fromJson(s)).toList();
    } else {
      throw Exception("Errore nel caricamento dei servizi");
    }
  }

  Future<BusinessService> createService({
  required int businessId,
  required String name,
  required double price,
  required int durationMinutes,
  required String iconUrl,
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "price": price,
      "durationMinutes": durationMinutes,
      "iconUrl": iconUrl,
      "business": {"id": businessId}
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return BusinessService.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Errore nella creazione del servizio");
  }
}

  Future<BusinessService> updateService({
    required int id,
    required String name,
    required double price,
    required int durationMinutes,
    required String iconUrl,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "price": price,
        "durationMinutes": durationMinutes,
        "iconUrl": iconUrl
      }),
    );

    if (response.statusCode == 200) {
      return BusinessService.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Errore nell'aggiornamento del servizio");
    }
  }

  Future<void> deleteService(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Errore nell'eliminazione del servizio");
    }
  }
}
