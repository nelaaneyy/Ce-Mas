class RegistrationData {
  // Step 1: Akun
  String email = '';
  String username = '';
  String noHp = '';
  String password = '';

  // Step 2: Pemilik
  String namaPemilik = '';
  String nik = '';
  String? fotoKtpPath; // Path ke file foto KTP
  String fotoKtpUrl = ''; // URL setelah upload ke Firebase Storage

  // Step 3: UMKM
  String namaUmkm = '';
  String kategori = '';
  String blok = '';
  String nomor = '';
  String deskripsi = '';
  String linkMaps = '';
  String? fotoUmkmPath; // Path ke file foto UMKM
  String fotoUmkmUrl = ''; // URL setelah upload ke Firebase Storage

  // Step 4: Kontak
  String whatsapp = '';
  String instagram = '';
  String facebook = '';
  String tiktok = '';

  // Step 5: Admin & Verification
  String uid = ''; // Added for Admin actions
  String alamatLengkap = '';
  String status = 'Menunggu';
}
