import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import service kita

class SignUpPage extends StatefulWidget {
  final VoidCallback? onSwitchToLogin; // Untuk pindah ke halaman Login

  const SignUpPage({super.key, this.onSwitchToLogin});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final _namaPertamaController = TextEditingController();
  final _namaTerakhirController = TextEditingController();
  final _usernameController = TextEditingController(); // Field baru
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    // Cek apakah password cocok
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password tidak cocok!')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Panggil service dengan field 'username' yang baru
      await _authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _namaPertamaController.text.trim(),
        _namaTerakhirController.text.trim(),
        _usernameController.text.trim(), // Kirim username
        _nomorHpController.text.trim(),
      );
      // Jika berhasil, AuthWrapper akan otomatis pindah halaman
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Daftar Gagal: ${e.toString()}')));
    }
  }

  // --- UI WIDGET UTAMA ---
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue.shade800, // Latar biru
      body: Stack(
        children: [
          // WADAH KONTEN PUTIH (FORM)
          Positioned(
            top: screenSize.height * 0.25, // Mulai 25% dari atas
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // 60px padding atas
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Judul dan Link Login ---
                    const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: widget.onSwitchToLogin, // Pindah ke Login
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- Form Input ---
                    // Baris Nama Pertama & Terakhir
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomTextField(
                            label: 'Nama Pertama',
                            controller: _namaPertamaController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCustomTextField(
                            label: 'Nama Terakhir',
                            controller: _namaTerakhirController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildCustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 20),

                    _buildCustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      isEmail: true,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildCustomTextField(
                      label: 'Nomor HP',
                      controller: _nomorHpController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 20),

                    _buildCustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    _buildCustomTextField(
                      label: 'Konfirmasi Password',
                      controller: _konfirmasiPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    // --- Tombol Register ---
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                              'Register',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // --- Link Daftar UMKM ---
                    GestureDetector(
                      onTap: () {
                        // TODO: Buat alur pendaftaran UMKM
                        print('Pindah ke halaman daftar UMKM');
                      },
                      child: Text(
                        'Daftar sebagai UMKM? Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- LOGO (DI ATAS SEMUANYA) ---
          Positioned(
            top: (screenSize.height * 0.125) - 50, 
            left: (screenSize.width / 2) - 50,
            
            child: Container(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/images/logocemas.jpeg', 
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER (Sama seperti di login_page) ---
  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
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
              : (isPhone ? TextInputType.phone : TextInputType.text),
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
}