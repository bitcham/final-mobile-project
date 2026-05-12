abstract final class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerProfile = '/register/profile';
  static const String welcome = '/welcome';
}

class PendingRegistration {
  const PendingRegistration({required this.email, required this.password});

  final String email;
  final String password;
}
