import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  String baseUrl;
  String apiKey;
  final http.Client? client;

  ApiClient({
    required this.baseUrl,
    required this.apiKey,
    this.client,
  });

  Future<http.Response> post(
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    var cleanBase = baseUrl.trim();
    if (cleanBase.endsWith('/')) {
      cleanBase = cleanBase.substring(0, cleanBase.length - 1);
    }
    
    var cleanPath = path.trim();
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    final uri = Uri.parse('$cleanBase$cleanPath').replace(queryParameters: queryParams);
    
    final allHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-api-key': apiKey,
      ...?headers,
    };

    debugPrint('ApiClient: Sending POST to $uri');
    debugPrint('ApiClient: Headers: $allHeaders');
    debugPrint('ApiClient: Body: ${body != null ? jsonEncode(body) : null}');

    try {
      final response = await (client ?? http.Client()).post(
        uri,
        headers: allHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      debugPrint('ApiClient: Received Response code: ${response.statusCode}');
      debugPrint('ApiClient: Received Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('ApiClient: Request failed with error: $e');
      rethrow;
    }
  }
}
