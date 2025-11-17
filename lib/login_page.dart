// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'auth_service.dart'; // Pastikan file ini ada

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
  bool _rememberMe = false; // State untuk "Remember me"

  // Fungsi login
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Gagal: ${e.toString()}')));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI WIDGET UTAMA ---
  @override
  Widget build(BuildContext context) {
    // Kita pakai MediaQuery untuk tahu ukuran layar
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Warna latar belakang biru untuk bagian atas
      backgroundColor: Colors.blue.shade800,
      body: Stack(
        children: [
          // WADAH KONTEN PUTIH (FORM)
          Positioned(
            // Mulai 25% dari atas layar
            top: screenSize.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // Sudut melengkung HANYA di kiri atas dan kanan atas
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // Kita pakai SingleChildScrollView di DALAM sini
              // agar form-nya bisa di-scroll jika keyboard muncul
              child: SingleChildScrollView(
                // Beri padding atas agar form tidak tertutup logo
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Judul dan Link Sign Up ---
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: widget
                              .onSwitchToRegister, // Panggil fungsi pindah
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

                    // --- Form Input Kustom ---
                    _buildCustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      isEmail: true,
                    ),
                    const SizedBox(height: 20),
                    _buildCustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),

                    // --- Baris Remember Me & Forgot ---
                    _buildRememberMeRow(),
                    const SizedBox(height: 20),

                    // --- Tombol Log In ---
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
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 25),

                    // --- Pemisah "Or" ---
                    _buildOrDivider(),
                    const SizedBox(height: 25),

                    // --- Tombol Social Login ---
                    _buildSocialButton(
                      label: 'Continue with Google',
                      iconAsset: 'assets/images/logogoogle.png',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 15),
                    _buildSocialButton(
                      label: 'Continue with Facebook',
                      iconAsset: 'assets/images/logofacebook.png',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- LOGO (DI ATAS SEMUANYA) ---
          Positioned(
            // (Posisi top Container putih) - (Setengah tinggi logo)
            top: (screenSize.height * 0.125) - 50,
            // (Setengah lebar layar) - (Setengah lebar logo)
            left: (screenSize.width / 2) - 50,

            // --- INI BAGIAN YANG DIUBAH ---
            child: Container(
              width: 100, // Atur lebar logo
              height: 100, // Atur tinggi logo
              child: Image.asset(
                'assets/images/logocemas.jpeg',
                fit: BoxFit.contain, // Agar gambar pas
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade800),
            ),
            suffixIcon: isPassword
                ? const Icon(Icons.visibility_off_outlined)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.blue.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color.fromARGB(255, 202, 202, 202))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(color: Color.fromARGB(137, 37, 37, 37)),
          ),
        ),
        Expanded(child: Divider(color: Color.fromARGB(255, 202, 202, 202))),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String iconAsset,
    required VoidCallback onPressed,
  }) {
    // Pastikan aset sosial media ada, jika tidak, tampilkan tanpa ikon
    // Ini adalah cara aman agar tidak error jika logo google/fb belum ada
    Widget iconWidget;
    try {
      iconWidget = Image.asset(iconAsset, height: 20, width: 20);
    } catch (e) {
      iconWidget = const SizedBox(width: 0); // Tampilkan box kosong
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: iconWidget,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black, // Warna teks
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color.fromARGB(255, 218, 218, 218)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
