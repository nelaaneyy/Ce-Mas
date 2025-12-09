import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cemas/features/admin/edit_profile_screen.dart'; // Import
import 'package:cemas/features/admin/change_password_screen.dart'; // Import
import 'package:cemas/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Akun Admin'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.mPlusRounded1c(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Profile Info (Static for now)
          StreamBuilder<DocumentSnapshot>(
            // Listen to 'admins' collection for the specific admin document
            stream: FirebaseFirestore.instance.collection('admins').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator());
              }
              
              // Data retrieval with safe fallbacks
              var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              
              // If 'admins' doc doesn't exist yet (first run before profile save), 
              // we can display defaults or try to fetch from 'users' (optional, but defaults are cleaner here)
              // Let's stick to defaults 'Admin Utama' to prompt them to 'Edit Profile' to populate the new DB.
              String name = data['nama'] ?? 'Admin Utama'; 
              String email = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'admin@cemas.id';
              String photoUrl = data['photoUrl'] ?? '';

              return Column(
                children: [
                   CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF0066CC),
                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            label: 'Edit Profil',
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            label: 'Ganti Password',
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),

          
          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                    // Logout Logic
                    await AuthService().signOut();
                    // No need to Navigator.pop because AuthWrapper will handle the stream change 
                    // and rebuild the MaterialApp's home. 
                    // However, we are inside a pushed route (AccountScreen).
                    // We should pop everything until the root to let AuthWrapper take over correctly 
                    // or just let AuthWrapper rebuild.
                    // Best practice with StreamBuilder generic auth wrapper is usually just popping 
                    // until first route if needed, but since AuthWrapper switches the entire widget tree 
                    // at the top, we just need to make sure we are not stuck in a sub-route.
                    
                    if (context.mounted) {
                       Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // Danger color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0066CC)),
        title: Text(
          label,
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
