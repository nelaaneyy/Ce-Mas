import 'package:flutter/material.dart';
import 'auth_service.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback? onSwitchToLogin;

  const SignUpPage({super.key, this.onSwitchToLogin});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();

  final _namaPertamaController = TextEditingController();
  final _namaTerakhirController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  bool _isLoading = false;

  // REGISTER
  void _register() async {
    // 1. Validasi Password
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Proses Register ke Backend/Firebase
      await _authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _namaPertamaController.text.trim(),
        _namaTerakhirController.text.trim(),
        _usernameController.text.trim(),
        _nomorHpController.text.trim(),
      );

      // ==================================================================
      // PERBAIKAN: Logout paksa agar sesi tidak berlanjut (Auto Login mati)
      // ==================================================================
      await _authService.signOut(); 
      
      if (!mounted) return;

      setState(() => _isLoading = false);

      // 3. Pindah UI kembali ke LOGIN
      if (widget.onSwitchToLogin != null) {
        widget.onSwitchToLogin!();
      }

      // 4. Tampilkan Pesan Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat. Silakan login kembali.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daftar gagal: $e')),
      );
    }
  }

  // UI HALAMAN
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Stack(
        children: [
          /// ============================
          /// FORM PUTIH
          /// ============================
          Positioned(
            top: size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign Up',
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
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: widget.onSwitchToLogin,
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

                    /// Nama Depan & Belakang
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            label: "Nama Pertama",
                            controller: _namaPertamaController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            label: "Nama Terakhir",
                            controller: _namaTerakhirController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                        label: 'Username', controller: _usernameController),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      isEmail: true,
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Nomor HP',
                      controller: _nomorHpController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Konfirmasi Password',
                      controller: _konfirmasiPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),

                    /// TOMBOL REGISTER
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
                              "Register",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Daftar sebagai UMKM? Sign In",
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

          /// ============================
          /// LOGO DI ATAS
          /// ============================
          Positioned(
            top: (size.height * 0.125) - 50,
            left: (size.width / 2) - 50,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset("assets/images/logocemas.jpeg"),
            ),
          ),
        ],
      ),
    );
  }

  /// FIELD REUSABLE
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            )),
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