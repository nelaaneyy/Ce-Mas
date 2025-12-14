import 'package:flutter/material.dart';
import 'package:cemas/features/umkm/models/registration_model.dart';

class StepKontak extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepKontak({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StepKontak> createState() => _StepKontakState();
}

class _StepKontakState extends State<StepKontak> {
  final _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Kontak UMKM", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Agar pembeli mudah menghubungimu", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            _buildTextField(
              'Nomor WhatsApp *',
              (val) => widget.data.whatsapp = val,
              initial: widget.data.whatsapp,
              isNumber: true,
              hint: 'Contoh: 08123456789',
              validator: (val) => (val == null || val.isEmpty) ? "Nomor WhatsApp wajib diisi." : null,
            ),
            
            _buildTextField(
              'Instagram',
              (val) => widget.data.instagram = val,
              initial: widget.data.instagram,
              hint: '@username',
            ),
            
            _buildTextField(
              'Facebook',
              (val) => widget.data.facebook = val,
              initial: widget.data.facebook,
            ),
            
            _buildTextField(
              'TikTok',
              (val) => widget.data.tiktok = val,
              initial: widget.data.tiktok,
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack, 
                    child: const Text('Kembali')
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                    child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    Function(String) onChanged, {
    String? initial, 
    bool isNumber = false, 
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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