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
  final _emailController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok!'))
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _authService.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        _namaPertamaController.text,
        _namaTerakhirController.text,
        _nomorHpController.text,
      );
      // Jika berhasil, AuthWrapper akan otomatis pindah halaman
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daftar Gagal: ${e.toString()}'))
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
              const SizedBox(height: 30),

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
                      'Sign up',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Link ke Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: widget.onSwitchToLogin, // Panggil fungsi pindah
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
                    const SizedBox(height: 20),

                    // Form Nama
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _namaPertamaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Pertama',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _namaTerakhirController,
                            decoration: InputDecoration(
                              labelText: 'Nama Terakhir',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // (Kita skip Username sesuai desain)
                    
                    // Form Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Form Nomor HP
                    TextFormField(
                      controller: _nomorHpController,
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Form Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Konfirmasi Password
                    TextFormField(
                      controller: _konfirmasiPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Register
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

                    // Link Daftar UMKM
                    GestureDetector(
                      onTap: () {
                        // Nanti ini akan ke halaman daftar UMKM
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
            ],
          ),
        ),
      ),
    );
  }
}