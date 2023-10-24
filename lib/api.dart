import 'dart:convert';
import 'medicina.dart';
import 'package:http/http.dart' as http;

Future<List<Medicina>> fetchAllMedicinas() async {
  final response = await http.get(Uri.parse('http://167.71.172.206:3000/api/medicina'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<Medicina> medicinas = data.map((item) => Medicina.fromJson(item)).toList();
    return medicinas;
  } else {
    throw Exception('Failed to load medicinas');
  }
}

Future<Medicina?> fetchMedicinaById(int id) async {
  final response = await http.get(Uri.parse('http://167.71.172.206:3000/api/medicina/$id'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    return Medicina.fromJson(data);
  } else {
    throw Exception('Failed to load medicina');
  }
}

Future<Medicina?> fetchMedicinaByNombre(String nombre) async {
  final response = await http.get(Uri.parse('http://167.71.172.206:3000/api/medicina/$nombre'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    return Medicina.fromJson(data);
  } else {
    throw Exception('Failed to load medicina');
  }
}
