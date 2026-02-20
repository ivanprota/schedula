import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:schedula/models/business.dart';

class BusinessService {
  final String baseUrl = "http://10.0.2.2:8080/api/businesses";

  /// --------------------------------------------------------------
  ///  GET TUTTE LE ATTIVITÀ
  /// --------------------------------------------------------------
  Future<List<Business>> getAllBusiness() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((b) => Business.fromJson(b)).toList();
    }

    throw Exception("Errore nel caricamento dei business");
  }

  /// --------------------------------------------------------------
  ///  GET ATTIVITÀ DELL'OWNER
  /// --------------------------------------------------------------
  Future<List<Business>> getOwnedBusinesses(int ownerId) async {
    final response = await http.get(Uri.parse('$baseUrl/owner/$ownerId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((b) => Business.fromJson(b)).toList();
    }

    throw Exception("Errore nel caricamento dei business dell'utente");
  }

  /// --------------------------------------------------------------
  ///  CREA BUSINESS (senza immagine)
  /// --------------------------------------------------------------
  Future<Business> createBusiness({
    required String name,
    required String address,
    required int ownerId,
  }) async {
    final body = {
      "name": name,
      "address": address,
      "ownerId": ownerId,
      "photoUrl": null, // placeholder
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Business.fromJson(jsonDecode(response.body));
    }

    print(response.body);
    throw Exception("Errore nella creazione del business");
  }

  /// --------------------------------------------------------------
  ///  UPDATE SOLO TESTO (name + address)
  /// --------------------------------------------------------------
  Future<Business> updateBusiness({
    required int id,
    required String name,
    required String address,
  }) async {
    final body = {
      "name": name,
      "address": address,
      // photoUrl e owner NON vengono inviati
    };

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Business.fromJson(jsonDecode(response.body));
    }

    throw Exception("Errore nell'aggiornamento del business");
  }

  /// --------------------------------------------------------------
  ///  UPLOAD IMMAGINE DEL BUSINESS
  ///  + il backend aggiorna photoUrl automaticamente
  /// --------------------------------------------------------------
  Future<String> uploadBusinessImage(int businessId, File imageFile) async {
    final uri = Uri.parse("$baseUrl/$businessId/upload-image");

    final request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath("image", imageFile.path));

    final streamed = await request.send();
    final responseBody = await streamed.stream.bytesToString();

    if (streamed.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data["photoUrl"]; // ritorna il nuovo percorso
    }

    throw Exception("Errore nel caricamento dell'immagine");
  }

  Future<List<Business>> searchBusinesses(String query) async {
    final uri = Uri.parse('$baseUrl/search?query=$query');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Business.fromJson(json)).toList();
    } else {
      throw Exception('Errore nella ricerca attività');
    }
  }

  Future<void> deleteBusiness(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Errore nell'eliminazione del business");
    }
  }

}
