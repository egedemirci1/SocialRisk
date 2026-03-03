import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_provider.dart';

/// Raporlanan Fotoğraflar — Tiyatro Temalı
class ReportedPhotosScreen extends ConsumerWidget {
  const ReportedPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(watchReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'RAPORLU SAHNE ADLARI',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TÜM SAHNELER TEMİZ 🎉',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: reports.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: report.targetUserAvatar,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.black26,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.targetUserName.toUpperCase(),
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'İHBAR: ${report.reason.toUpperCase()}',
                              style: GoogleFonts.libreBaskerville(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            tooltip: 'ONAYLA',
                            onPressed: () => ref
                                .read(adminControllerProvider.notifier)
                                .approvePhoto(report.targetUserId, report.id),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.block,
                              color: AppColors.primary,
                            ),
                            tooltip: 'YASAKLA',
                            onPressed: () => ref
                                .read(adminControllerProvider.notifier)
                                .banPhoto(report.targetUserId, report.id),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Hata: $e',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
