import 'package:flutter/material.dart';
import 'registration_model.dart';

class StepUMKM extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StepUMKM({super.key, required this.data, required this.onNext, required this.onBack});

  @override
  State<StepUMKM> createState() => _StepUMKMState();
}

class _StepUMKMState extends State<StepUMKM> {
  final List<String> _kategoriList = ['Kelontong', 'Kuliner', 'Jasa', 'Transportasi'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Data UMKM", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          _buildTextField('Nama UMKM *', (val) => widget.data.namaUmkm = val, initial: widget.data.namaUmkm),
          
          // Dropdown Kategori
          DropdownButtonFormField<String>(
            value: widget.data.kategori.isNotEmpty ? widget.data.kategori : null,
            decoration: InputDecoration(
              labelText: 'Kategori *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _kategoriList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => widget.data.kategori = val ?? '',
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: _buildTextField('Blok', (val) => widget.data.blok = val, initial: widget.data.blok)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField('Nomor', (val) => widget.data.nomor = val, initial: widget.data.nomor)),
            ],
          ),

          _buildTextField('Deskripsi Singkat *', (val) => widget.data.deskripsi = val, initial: widget.data.deskripsi, maxLines: 3),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: widget.onBack, child: const Text('Kembali'))),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNext,
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

  Widget _buildTextField(String label, Function(String) onChanged, {String? initial, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}