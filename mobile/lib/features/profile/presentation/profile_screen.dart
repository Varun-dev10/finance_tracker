import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiClient = ApiClient();
  String? _name;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      setState(() {
        _name = response.data['display_name'] ?? 'User';
        _email = response.data['email'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ApiClient.clearToken();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 28),

              // Simple avatar circle with initial letter
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryPurple,
                      child: Text(
                        (_name ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_name ?? '', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(_email ?? '', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  icon: const Icon(Iconsax.logout, color: Colors.white, size: 18),
                  label: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}