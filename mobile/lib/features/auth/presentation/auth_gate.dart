import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/main_shell.dart';
import 'login_screen.dart';

// This screen decides where to send the user when the app first opens:
// - If a saved token exists and still works -> straight to the dashboard
// - Otherwise -> login screen
// It shows a brief loading spinner while it checks.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiClient.getToken();

    if (token == null) {
      setState(() {
        _isChecking = false;
        _isLoggedIn = false;
      });
      return;
    }

    // Token exists, but might be expired - confirm with the backend
    // by calling the protected /auth/me endpoint.
    try {
      final apiClient = ApiClient();
      await apiClient.dio.get('/auth/me');
      setState(() {
        _isChecking = false;
        _isLoggedIn = true;
      });
    } catch (e) {
      // Token invalid/expired - clear it and send to login
      await ApiClient.clearToken();
      setState(() {
        _isChecking = false;
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isLoggedIn ? const MainShell() : const LoginScreen();
  }
}