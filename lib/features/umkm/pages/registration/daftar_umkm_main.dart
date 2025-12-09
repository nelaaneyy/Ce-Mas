import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan ini untuk XFile
import 'dart:io';

// Import service
// Pastikan path ini benar. '..' artinya naik satu folder ke 'lib/'
import 'package:cemas/core/services/auth_service.dart';
import 'package:cemas/features/umkm/services/seller_service.dart';

// Import model dan steps
import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:cemas/features/umkm/pages/registration/step_akun.dart';
import 'package:cemas/features/umkm/pages/registration/step_pemilik.dart';
import 'package:cemas/features/umkm/pages/registration/step_umkm.dart';
import 'package:cemas/features/umkm/pages/registration/step_kontak.dart';
import 'package:cemas/features/umkm/pages/registration/step_review.dart';

// Import MainPage untuk navigasi setelah registrasi
import 'package:cemas/shared/pages/main_page.dart';


class DaftarUmkmMainPage extends StatefulWidget {
  final bool showBackButton; // Flag untuk menentukan apakah tampil back button

  const DaftarUmkmMainPage({super.key, this.showBackButton = false});

  @override
  State<DaftarUmkmMainPage> createState() => _DaftarUmkmMainPageState();
}

class _DaftarUmkmMainPageState extends State<DaftarUmkmMainPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Data penampung
  final RegistrationData _data = RegistrationData();
  
  // Progress message untuk loading dialog
  String _progressMessage = 'Memproses...';


  // Service didefinisikan di sini agar bisa diakses seluruh class
  final AuthService _authService = AuthService();
  final SellerService _sellerService = SellerService();

  // --- FUNGSI NAVIGASI ---
  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
    // Tampilkan Loading dengan progress message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_progressMessage),
          ],
        ),
      ),
    );

    try {
      // 1. Buat Akun User
      setState(() => _progressMessage = 'Membuat akun...');
      await _authService.signUpWithEmailPassword(
        _data.email,
        _data.password,
        _data.namaPemilik,
        // Pass optional params
        namaTerakhir: "", // Using empty string as per original intent
        username: _data.username,
        nomorHp: _data.noHp,
        role: 'umkm', // Explicity set role to UMKM since this is UMKM registration area
      );

      // 2. Cek Langsung ke Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Gagal membuat akun. Email mungkin sudah terdaftar.");
      }

      final uid = currentUser.uid;

      // 3. Upload Foto KTP dan UMKM SECARA PARALEL (LEBIH CEPAT!)
      setState(() => _progressMessage = 'Mengupload foto...');
      
      final results = await Future.wait([
        _uploadKtpPhoto(uid),
        _uploadUmkmPhoto(uid),
      ]);
      
      String? fotoKtpUrl = results[0];
      String? fotoUmkmUrl = results[1];

      // 4. Buat Toko
      setState(() => _progressMessage = 'Menyimpan data toko...');
      await _sellerService.createStore(
        namaToko: _data.namaUmkm,
        deskripsi: _data.deskripsi,
        noWhatsapp: _data.whatsapp.isEmpty ? _data.noHp : _data.whatsapp,
        alamat: "Blok ${_data.blok} No. ${_data.nomor}",
        kategori: _data.kategori,
        fotoKtpUrl: fotoKtpUrl,
        fotoUmkmUrl: fotoUmkmUrl,
      );

      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        _showSuccessDialog(); // Tampilkan Sukses
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    }
  }

  // --- FUNGSI UPLOAD FOTO KTP ---
  Future<String?> _uploadKtpPhoto(String uid) async {
    if (_data.fotoKtpPath == null || _data.fotoKtpPath!.isEmpty) {
      return null;
    }

    try {
      final ktpBytes = await XFile(_data.fotoKtpPath!).readAsBytes();
      if (ktpBytes.isEmpty) return null;

      final storageRef = FirebaseStorage.instance.ref().child(
        "seller_ktp/$uid.jpg",
      );
      await storageRef.putData(
        ktpBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();
      debugPrint("KTP foto uploaded: $url");
      return url;
    } catch (e) {
      debugPrint("Warning: Gagal upload KTP: $e");
      return null;
    }
  }

  // --- FUNGSI UPLOAD FOTO UMKM ---
  Future<String?> _uploadUmkmPhoto(String uid) async {
    if (_data.fotoUmkmPath == null || _data.fotoUmkmPath!.isEmpty) {
      return null;
    }

    try {
      final umkmBytes = await XFile(_data.fotoUmkmPath!).readAsBytes();
      if (umkmBytes.isEmpty) return null;

      final storageRef = FirebaseStorage.instance.ref().child(
        "seller_umkm/$uid.jpg",
      );
      await storageRef.putData(
        umkmBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();
      debugPrint("UMKM foto uploaded: $url");
      return url;
    } catch (e) {
      debugPrint("Warning: Gagal upload UMKM: $e");
      return null;
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
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registrasi Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Akun dan Toko Anda telah berhasil dibuat.\nAnda akan diarahkan ke Dashboard UMKM.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Tutup Dialog
                    // Navigasi ke MainPage dan hapus semua halaman sebelumnya
                    // MainPage akan otomatis mendeteksi role 'penjual' dan menampilkan DashboardTokoPage
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainPage()),
                      (route) => false, // Hapus semua route sebelumnya
                    );
                  },
                  child: const Text(
                    'Lihat Dashboard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
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
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Ganti dengan Image.asset jika ada logo
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up UMKM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Container Putih
          Positioned(
            top: screenSize.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
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
                        StepAkun(
                          data: _data,
                          onNext: _nextPage,
                          onBack: widget.showBackButton ? _prevPage : null,
                        ),
                        StepPemilik(
                          data: _data,
                          onNext: _nextPage,
                          onBack: _prevPage,
                        ),
                        StepUMKM(
                          data: _data,
                          onNext: _nextPage,
                          onBack: _prevPage,
                        ),
                        StepKontak(
                          data: _data,
                          onNext: _nextPage,
                          onBack: _prevPage,
                        ),

                        // Step Review memanggil fungsi _submitData
                        StepReview(
                          data: _data,
                          onSubmit: _submitData,
                          onBack: _prevPage,
                        ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (index) {
          bool isActive = index == _currentStep;
          return GestureDetector(
            onTap: () => _jumpToPage(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Increased horizontal padding
              decoration: isActive
                  ? const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    )
                  : null,
              child: Text(
                steps[index],
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.blue.shade800 : Colors.grey,
                  fontSize: 14, // Slightly larger font for better readability
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
