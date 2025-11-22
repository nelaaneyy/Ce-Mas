import 'package:flutter/material.dart';
import 'registration_model.dart';

class StepKontak extends StatelessWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepKontak({
    super.key, 
    required this.data, 
    required this.onNext, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Kontak UMKM", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Agar pembeli mudah menghubungimu", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          _buildTextField(
            'Nomor WhatsApp *', 
            (val) => data.whatsapp = val, 
            initial: data.whatsapp,
            isNumber: true,
            hint: 'Contoh: 08123456789'
          ),
          
          _buildTextField(
            'Instagram', 
            (val) => data.instagram = val, 
            initial: data.instagram,
            hint: '@username'
          ),
          
          _buildTextField(
            'Facebook', 
            (val) => data.facebook = val, 
            initial: data.facebook
          ),
          
          _buildTextField(
            'TikTok', 
            (val) => data.tiktok = val, 
            initial: data.tiktok
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack, 
                  child: const Text('Kembali')
                )
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {String? initial, bool isNumber = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}