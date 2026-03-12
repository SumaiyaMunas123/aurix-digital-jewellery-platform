import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoDummy implements AuthRepository {
  User? _saved;

  @override
  Future<User?> getSavedUser() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _saved;
  }

  @override
  Future<User> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 450));

    // Demo logic: if identifier contains "jewel" treat as jeweller
    final isJeweller = identifier.toLowerCase().contains("jewel");

    _saved = User(
      id: "u1",
      name: "User",
      role: isJeweller ? UserRole.jeweller : UserRole.customer,
    );
    return _saved!;
  }

  @override
  Future<void> logout() async {
    _saved = null;
  }
}