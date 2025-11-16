// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import service kita

class LoginPage extends StatefulWidget {
  final VoidCallback? onSwitchToRegister; // Untuk pindah ke halaman Sign Up

  const LoginPage({super.key, this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() { _isLoading = true; });
    
    try {
      // Panggil fungsi login dari auth_service
      await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      // Jika berhasil, AuthWrapper akan otomatis pindah halaman
    } catch (e) {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Gagal: ${e.toString()}'))
      );
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Bagian Logo
              const SizedBox(height: 50),
              // Ganti dengan logo-mu
              const Icon(Icons.store, color: Colors.white, size: 100), 
              const SizedBox(height: 50),

              // Bagian Form Putih
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    
                    // Link ke Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: widget.onSwitchToRegister, // Panggil fungsi pindah
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Form Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Form Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Sembunyikan password
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: const Icon(Icons.visibility_off),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Log In
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Log In',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                    // Kita skip Social Login untuk saat ini
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}