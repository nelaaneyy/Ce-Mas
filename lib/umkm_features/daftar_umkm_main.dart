import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import service
// Pastikan path ini benar. '..' artinya naik satu folder ke 'lib/'
import '../auth_service.dart'; 
import '../seller_service.dart';

// Import model dan steps
import 'registration_model.dart';
import 'step_akun.dart';
import 'step_pemilik.dart';
import 'step_umkm.dart';
import 'step_kontak.dart';
import 'step_review.dart';

class DaftarUmkmMainPage extends StatefulWidget {
  const DaftarUmkmMainPage({super.key});

  @override
  State<DaftarUmkmMainPage> createState() => _DaftarUmkmMainPageState();
}

class _DaftarUmkmMainPageState extends State<DaftarUmkmMainPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Data penampung
  final RegistrationData _data = RegistrationData();
  
  // Service didefinisikan di sini agar bisa diakses seluruh class
  final AuthService _authService = AuthService();
  final SellerService _sellerService = SellerService();

  // --- FUNGSI NAVIGASI ---
  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    }
  }

  void _jumpToPage(int pageIndex) {
    if (pageIndex <= _currentStep) {
       _pageController.jumpToPage(pageIndex);
       setState(() => _currentStep = pageIndex);
    }
  }

  // --- FUNGSI SUBMIT DATA ---
  void _submitData() async {
    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Buat Akun User
      await _authService.signUpWithEmailPassword(
        _data.email,
        _data.password,
        _data.namaPemilik,
        "", 
        _data.username,
        _data.noHp,
      );

      // 2. Cek Langsung ke Firebase Auth
      // Apakah user benar-benar sudah login/terbuat?
      if (FirebaseAuth.instance.currentUser != null) {
        
        // Jika ada user, Lanjut Buat Toko
        await _sellerService.createStore(
          namaToko: _data.namaUmkm,
          deskripsi: _data.deskripsi,
          noWhatsapp: _data.whatsapp.isEmpty ? _data.noHp : _data.whatsapp,
          alamat: "Blok ${_data.blok} No. ${_data.nomor}",
          kategori: _data.kategori,
        );

        if (mounted) {
          Navigator.pop(context); // Tutup Loading
          _showSuccessDialog();   // Tampilkan Sukses
        }
      } else {
        // Jika currentUser null, berarti pendaftaran gagal
        throw Exception("Gagal membuat akun. Email mungkin sudah terdaftar.");
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e")),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Registrasi Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Akun dan Toko Anda telah berhasil dibuat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Tutup Dialog
                    Navigator.of(context).pop(); // Kembali ke Halaman Akun
                  },
                  child: const Text('Selesai', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Stack(
        children: [
          // Header Biru
          Positioned(
            top: 60, left: 0, right: 0,
            child: Column(
              children: [
                // Ganti dengan Image.asset jika ada logo
                const CircleAvatar(
                  radius: 40, 
                  backgroundColor: Colors.white, 
                  child: Icon(Icons.store, size: 40, color: Colors.blue)
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up UMKM', 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),

          // Container Putih
          Positioned(
            top: screenSize.height * 0.25,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // TAB INDIKATOR
                  _buildStepIndicator(),
                  
                  const Divider(),
                  
                  // ISI HALAMAN (PageView)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StepAkun(data: _data, onNext: _nextPage),
                        StepPemilik(data: _data, onNext: _nextPage, onBack: _prevPage),
                        StepUMKM(data: _data, onNext: _nextPage, onBack: _prevPage),
                        StepKontak(data: _data, onNext: _nextPage, onBack: _prevPage),
                        
                        // Step Review memanggil fungsi _submitData
                        StepReview(data: _data, onSubmit: _submitData, onBack: _prevPage),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Akun', 'Pemilik', 'UMKM', 'Kontak', 'Review'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        bool isActive = index == _currentStep;
        return GestureDetector(
          onTap: () => _jumpToPage(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: isActive ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.blue, width: 2))
            ) : null,
            child: Text(
              steps[index],
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.blue.shade800 : Colors.grey,
                fontSize: 12, // Ukuran font disesuaikan agar muat
              ),
            ),
          ),
        );
      }),
    );
  }
}