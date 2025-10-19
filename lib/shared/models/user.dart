import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? token; // Make token nullable
  final String email;
  final String phone;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token, // Nullable
    required this.phone,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        token,
        avatar,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? token, // Nullable
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token, // Handle null
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'token': token, // Nullable
      'avatar': avatar,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['_id'] ?? '', // Handle both id and _id
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      token: map['token'], // Nullable
      avatar: map['avatar'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt']) // Use parse for ISO 8601
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt']) // Use parse for ISO 8601
          : null,
    );
  }
}