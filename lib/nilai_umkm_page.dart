import 'package:flutter/material.dart';
import 'nilai_umkm_berhasil_page.dart';

class NilaiUmkmPage extends StatefulWidget {
  final String umkmNama;

  const NilaiUmkmPage({super.key, required this.umkmNama});

  @override
  State<NilaiUmkmPage> createState() => _NilaiUmkmPageState();
}

class _NilaiUmkmPageState extends State<NilaiUmkmPage> {
  int selectedStar = 0;
  TextEditingController reviewC = TextEditingController();
  bool hideName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text("Nilai UMKM"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama UMKM
            Text(
              widget.umkmNama,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Label rating
            const Text(
              "Nilai UMKM",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),

            // Bintang Rating
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      selectedStar = starIndex;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: selectedStar >= starIndex
                        ? Colors.amber
                        : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Label ulasan
            const Text(
              "Tulis ulasan Anda",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 6),

            // TextField Ulasan
            TextField(
              controller: reviewC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tuliskan ulasan Anda...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: hideName,
                  onChanged: (v) {
                    setState(() => hideName = v!);
                  },
                ),
                const Text("Sembunyikan nama saya"),
              ],
            ),

            const Spacer(),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
               onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NilaiUmkmBerhasilPage(umkmNama: widget.umkmNama),
                  ),
                );
              },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Kirim",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
