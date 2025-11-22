import 'package:flutter/material.dart';
import 'registration_model.dart';

class StepAkun extends StatelessWidget {
  final RegistrationData data;
  final VoidCallback onNext;

  const StepAkun({super.key, required this.data, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Data Akun", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Informasi dasar untuk login", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          _buildTextField('Email *', (val) => data.email = val, initial: data.email),
          _buildTextField('Username *', (val) => data.username = val, initial: data.username),
          _buildTextField('Password *', (val) => data.password = val, isPass: true, initial: data.password),
          // Konfirmasi password logic bisa ditambah validasi nanti
          _buildTextField('Konfirmasi Password *', (val) {}, isPass: true),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {bool isPass = false, String? initial}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}