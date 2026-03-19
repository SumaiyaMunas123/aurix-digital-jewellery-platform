import 'dart:async';

import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoDummy implements AuthRepository {
  static const String _password = '123456';

  User? _savedUser;

  final List<_DummyAccount> _accounts = const [
    _DummyAccount(
      id: '1',
      name: 'Aurix Customer',
      role: UserRole.customer,
      identifiers: ['customer@aurix.com', '0770000001'],
    ),
    _DummyAccount(
      id: '2',
      name: 'Aurix Jeweller',
      role: UserRole.jeweller,
      identifiers: ['jeweller@aurix.com', '0770000002'],
    ),
  ];

  @override
  Future<User> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (password != _password) {
      throw Exception('Invalid password');
    }

    final normalized = identifier.trim().toLowerCase();

    final account = _accounts.cast<_DummyAccount?>().firstWhere(
          (a) => a!.identifiers.any(
            (value) => value.toLowerCase() == normalized,
          ),
          orElse: () => null,
        );

    if (account == null) {
      throw Exception('User not found');
    }

    final user = User(
      id: account.id,
      name: account.name,
      role: account.role,
    );

    _savedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _savedUser = null;
  }

  @override
  Future<User?> getSavedUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _savedUser;
  }
}

class _DummyAccount {
  final String id;
  final String name;
  final UserRole role;
  final List<String> identifiers;

  const _DummyAccount({
    required this.id,
    required this.name,
    required this.role,
    required this.identifiers,
  });
}