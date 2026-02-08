import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AppUser.fromFirebaseUser(String uid, String email) {
    return AppUser(
      id: uid,
      email: email,
      name: email.split('@').first,
      role: 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name, 'role': role};
  }

  @override
  List<Object?> get props => [id, email, name, role];
}