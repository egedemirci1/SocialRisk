import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_provider.dart';

class ReportedPhotosScreen extends ConsumerWidget {
  const ReportedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(watchReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Raporlanan Fotoğraflar')),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Text('Hiç rapor yok 🎉', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                color: AppColors.surfaceElevated,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Raporlanan avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: report.targetUserAvatar,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80, height: 80, color: Colors.grey[800],
                            child: const Icon(Icons.person, color: Colors.white30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bilgiler
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.targetUserName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Sebep: ${report.reason}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      // Aksiyonlar
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: 'Fotoğrafı Onayla (Raporu Sil)',
                            onPressed: () {
                              ref.read(adminControllerProvider.notifier).approvePhoto(report.targetUserId, report.id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.red),
                            tooltip: 'Fotoğrafı Kaldır & Kullanıcıyı Banla',
                            onPressed: () {
                              ref.read(adminControllerProvider.notifier).banPhoto(report.targetUserId, report.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }
}
