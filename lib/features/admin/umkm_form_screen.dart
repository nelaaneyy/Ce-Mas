import 'package:cemas/features/umkm/models/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UmkmFormScreen extends StatefulWidget {
  final String? title;
  final RegistrationData? initialData;
  const UmkmFormScreen({super.key, this.title, this.initialData});

  @override
  State<UmkmFormScreen> createState() => _UmkmFormScreenState();
}

class _UmkmFormScreenState extends State<UmkmFormScreen> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _blokController;
  late TextEditingController _nomorController;
  late TextEditingController _descController;
  late TextEditingController _mapController;
  late TextEditingController _waController;
  late TextEditingController _igController;
  late TextEditingController _fbController;
  late TextEditingController _tiktokController;
  
  String? _selectedCategory;
  final List<String> _categories = ['Kuliner', 'Fesyen', 'Kerajinan', 'Jasa', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data?.namaUmkm ?? '');
    _blokController = TextEditingController(text: data?.blok ?? '');
    _nomorController = TextEditingController(text: data?.nomor ?? '');
    _descController = TextEditingController(text: data?.deskripsi ?? '');
    _mapController = TextEditingController(text: data?.linkMaps ?? '');
    _waController = TextEditingController(text: data?.whatsapp ?? '');
    _igController = TextEditingController(text: data?.instagram ?? '');
    _fbController = TextEditingController(text: data?.facebook ?? '');
    _tiktokController = TextEditingController(text: data?.tiktok ?? '');
    
    if (data?.kategori != null && _categories.contains(data!.kategori)) {
      _selectedCategory = data!.kategori;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _blokController.dispose();
    _nomorController.dispose();
    _descController.dispose();
    _mapController.dispose();
    _waController.dispose();
    _igController.dispose();
    _fbController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold)),
        content: Text('Apakah yakin membatalkan? Data akan hilang.', style: GoogleFonts.mPlusRounded1c()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // No, stay
            child: Text('Tidak', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Yes, exit
            child: Text('Ya', style: GoogleFonts.mPlusRounded1c(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldPop == true && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data gagal disimpan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(widget.title ?? 'Tambah UMKM'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          backgroundColor: const Color(0xFF0066CC),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card 1: General Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nama UMKM *'),
                  _buildTextField(_nameController),
                  const SizedBox(height: 16),

                  _buildLabel('Kategori UMKM *'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('--Pilih Kategori--', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
                        value: _selectedCategory,
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.mPlusRounded1c()),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Alamat UMKM *'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_blokController, hint: 'Blok')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_nomorController, hint: 'Nomor')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Deskripsi Singkat UMKM *'),
                  _buildTextField(_descController, maxLines: 3),
                  const SizedBox(height: 16),

                  _buildLabel('Foto UMKM *'),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            elevation: 0,
                          ),
                          child: const Text('Choose File'),
                        ),
                        const SizedBox(width: 12),
                        Text('No File Chosen', style: GoogleFonts.mPlusRounded1c(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Lokasi Map *'),
                  _buildTextField(_mapController, hint: 'Link Google Maps'),
                  const SizedBox(height: 8),
                   Text(
                    '* Menunjukkan inputan yang wajib diisi',
                    style: GoogleFonts.mPlusRounded1c(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 2: Contact Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Kontak UMKM',
                      style: GoogleFonts.mPlusRounded1c(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Untuk pembeli menghubungi penjual',
                      style: GoogleFonts.mPlusRounded1c(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('Nomor WhatsApp *'),
                  _buildTextField(_waController),
                  const SizedBox(height: 16),

                  _buildLabel('Instagram'),
                  _buildTextField(_igController),
                  const SizedBox(height: 16),

                  _buildLabel('Facebook'),
                  _buildTextField(_fbController),
                  const SizedBox(height: 16),

                  _buildLabel('Tiktok'),
                  _buildTextField(_tiktokController),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0066CC)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Kembali', 
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066CC),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Construct RegistrationData
                      final newData = RegistrationData()
                        ..namaUmkm = _nameController.text
                        ..kategori = _selectedCategory ?? '-'
                        ..blok = _blokController.text
                        ..nomor = _nomorController.text
                        ..deskripsi = _descController.text
                        ..linkMaps = _mapController.text
                        ..whatsapp = _waController.text
                        ..instagram = _igController.text
                        ..facebook = _fbController.text
                        ..tiktok = _tiktokController.text
                        ..alamatLengkap = 'Blok ${_blokController.text} No. ${_nomorController.text}' // Simple logic
                        ..status = widget.initialData?.status ?? 'Aktif'; // Preserve status or default

                      // Return the data
                      Navigator.pop(context, newData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.mPlusRounded1c(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.mPlusRounded1c(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066CC)),
        ),
      ),
    );
  }
}
