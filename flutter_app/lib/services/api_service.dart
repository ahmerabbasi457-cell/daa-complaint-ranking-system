// lib/services/api_service.dart
// ─────────────────────────────────────────────────────────
// All HTTP communication with the Flask backend.
// Backend base URL: http://10.0.2.2:5000  (Android emulator)
// For real device on same WiFi: http://192.168.x.x:5000
// ─────────────────────────────────────────────────────────
 
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';
 
class ApiService {
  // ── Change this to your machine's LAN IP for real device ──
  static const String baseUrl = 'http://192.168.100.84:5000';
  // static const String baseUrl = 'http://192.168.1.x:5000';
 
  static const Duration _timeout = Duration(seconds: 8);
 
  // ── Headers ─────────────────────────────────────────────
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
  };
 
  // ────────────────────────────────────────────────────────
  // GET /get-complaints  →  List<Complaint>
  // ────────────────────────────────────────────────────────
  static Future<List<Complaint>> getComplaints() async {
    final uri = Uri.parse('$baseUrl/get-complaints');
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
 
    if (res.statusCode != 200) {
      throw Exception('Failed to load complaints: ${res.statusCode}');
    }
 
    final Map<String, dynamic> body = jsonDecode(res.body);
    final List<dynamic> list = body['complaints'] ?? [];
    return list.map((e) => Complaint.fromJson(e)).toList();
  }
 
  // ────────────────────────────────────────────────────────
  // POST /submit-complaint  →  Map (success/error)
  // ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitComplaint({
    required String title,
    required String description,
    required String category,
    required String urgency,
    required String location,
  }) async {
    final uri  = Uri.parse('$baseUrl/submit-complaint');
    final body = jsonEncode({
      'title':       title,
      'description': description,
      'category':    category,
      'urgency':     urgency,
      'location':    location,
    });
 
    final res = await http
        .post(uri, headers: _headers, body: body)
        .timeout(_timeout);
 
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Submission failed: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }
 
  // ────────────────────────────────────────────────────────
  // POST /like-complaint/{id}  →  Map
  // ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> likeComplaint(int id) async {
    final uri = Uri.parse('$baseUrl/like-complaint/$id');
    final res = await http
        .post(uri, headers: _headers)
        .timeout(_timeout);
 
    if (res.statusCode != 200) {
      throw Exception('Like failed: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }
 
  // ────────────────────────────────────────────────────────
  // Health check — returns true if backend reachable
  // ────────────────────────────────────────────────────────
  static Future<bool> ping() async {
    try {
      final uri = Uri.parse('$baseUrl/get-complaints');
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
