import 'package:flutter/material.dart';
import 'registration_model.dart'; 

class StepPemilik extends StatefulWidget {
  final RegistrationData data; 
  final VoidCallback onNext;   
  final VoidCallback onBack;   

  const StepPemilik({
    super.key, 
    required this.data, 
    required this.onNext, 
    required this.onBack
  });

  @override
  State<StepPemilik> createState() => _StepPemilikState();
}

class _StepPemilikState extends State<StepPemilik> {
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Column(
              children: [
                Text("Data Pemilik", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Identitas pemilik untuk verifikasi", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: 'Nama Pemilik *', 
            initialValue: widget.data.namaPemilik, // Isi jika sudah ada data sebelumnya
            onChanged: (val) => widget.data.namaPemilik = val,
          ),

          _buildTextField(
            label: 'NIK *', 
            initialValue: widget.data.nik,
            isNumber: true,
            onChanged: (val) => widget.data.nik = val,
          ),

          _buildFilePicker('Foto KTP *'),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.blue.shade800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: widget.onBack, // Panggil fungsi kembali
                  child: Text('Kembali', style: TextStyle(color: Colors.blue.shade800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: widget.onNext, // Panggil fungsi lanjut
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildTextField({
    required String label, 
    required Function(String) onChanged, 
    String? initialValue,
    bool isNumber = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFilePicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], elevation: 0),
                onPressed: (){}, 
                child: const Text('Choose File', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 10),
              const Text('No File Chosen', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}