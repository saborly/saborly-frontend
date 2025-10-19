import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soely/core/constant/api_constants.dart';

class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final int order;
  final bool isActive;
  final String? link;
  final String? description;
  final String category;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.order,
    required this.isActive,
    this.link,
    this.description,
    required this.category,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
      link: json['link'],
      description: json['description'],
      category: json['category'] ?? 'general',
    );
  }
}

class BannerService {
  static const String baseUrl = 'https://soleybackend.vercel.app/api/v1'; // Replace with your API URL
  
  static Future<List<BannerModel>> getActiveBanners({String? category}) async {
    try {
      String url = '$baseUrl/banners/active';
      

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> bannersJson = data['data'];
        return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      print('Error fetching banners: $e');
      return [];
    }
  }
}



class ContactService {
  // Submit contact form
  static Future<Map<String, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? phone,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/contact');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Mensaje enviado correctamente',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al enviar el mensaje',
        };
      }
    } catch (e) {
      print('Error submitting contact form: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Por favor verifica tu internet.',
      };
    }
  }

}