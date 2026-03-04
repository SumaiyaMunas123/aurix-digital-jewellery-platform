import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoApi implements AuthRepository {
  @override
  Future<User?> getSavedUser() async {
    // TODO: integrate real storage + backend
    return null;
  }

  @override
  Future<User> login(String identifier, String password) async {
    // TODO: integrate backend
    return const User(id: "u_api", name: "API User", role: UserRole.customer);
  }

  @override
  Future<void> logout() async {}
}