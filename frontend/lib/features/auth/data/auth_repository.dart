import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> getSavedUser();
  Future<User> login(String identifier, String password);
  Future<void> logout();
}