import 'package:cemas/features/admin/services/admin_service.dart'; // Import Admin Service
import 'package:cemas/features/admin/umkm_management_screen.dart';
import 'package:cemas/features/admin/verification_list_screen.dart';
import 'package:cemas/features/admin/account_screen.dart';
import 'package:cemas/features/admin/buyer_management_screen.dart';
import 'package:cemas/features/admin/complaint_list_screen.dart';
import 'package:cemas/features/admin/activity_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService adminService = AdminService();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF0066CC),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Admin',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Stats Section
            StreamBuilder<Map<String, int>>(
              stream: adminService.getDashboardStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {
                  'totalUmkm': 0,
                  'totalBuyers': 0,
                  'pendingVerification': 0,
                  'totalComplaints': 0,
                };
                
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Total UMKM',
                            '${stats['totalUmkm']}', 
                            Colors.blue,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UmkmManagementScreen())),
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Total Pembeli',
                            '${stats['totalBuyers']}', 
                            Colors.green,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BuyerManagementScreen())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildStatCard(
                            'Verifikasi',
                            '${stats['pendingVerification']}', 
                            Colors.orange,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationListScreen())),
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Total Aduan',
                            '${stats['totalComplaints']}', 
                            Colors.redAccent,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintListScreen())),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            _buildSectionHeader('Aktivitas Terbaru', context, () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityListScreen()),
              );
            }),
            
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: adminService.getActivityLogsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return const Center(child: Padding(
                     padding: EdgeInsets.all(16.0),
                     child: Text("Belum ada aktivitas"),
                   ));
                }
                
                final activities = snapshot.data!.take(3).toList();
                
                return Column(
                  children: activities.map((activity) {
                    IconData icon = Icons.info;
                    Color color = Colors.blue;
                    
                    if (activity['type'] == 'success') {
                      icon = Icons.check_circle;
                      color = Colors.green;
                    } else if (activity['type'] == 'warning') {
                       icon = Icons.warning;
                       color = Colors.orange;
                    } else if (activity['type'] == 'error') {
                       icon = Icons.error;
                       color = Colors.red;
                    }

                    return _buildActivityItem(
                      activity['text'], 
                      icon, 
                      color, 
                      activity['time']
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              bottom: BorderSide(color: color, width: 3),
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.mPlusRounded1c(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.mPlusRounded1c(
                fontSize: 12,
                color: const Color(0xFF0066CC),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, IconData icon, Color iconColor, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.mPlusRounded1c(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
