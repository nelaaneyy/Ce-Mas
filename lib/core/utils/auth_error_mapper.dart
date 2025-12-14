import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  static String getFriendlyErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS': // For safety
          return "Ups, Email atau Kata Sandi kamu salah. Coba dicek lagi ya.";
        case 'wrong-password':
          return "Kata sandi salah. Hati-hati tombol Capslock/Huruf Besar.";
        case 'user-not-found':
          return "Akun dengan email ini belum terdaftar.";
        case 'too-many-requests':
          return "Terlalu banyak percobaan gagal. Istirahat dulu sebentar ya.";
        default:
          return "Ada gangguan koneksi atau sistem. Coba lagi nanti ya.";
      }
    }
    return "Ada gangguan koneksi atau sistem. Coba lagi nanti ya.";
  }
}
