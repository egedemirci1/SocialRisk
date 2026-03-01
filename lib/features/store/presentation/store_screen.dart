import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/common/gradient_container.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  // Temporary mock data for the store
  final List<Map<String, dynamic>> _mockItems = [
    {
      'id': 'frame_fire',
      'name': 'Ateş Çerçevesi',
      'type': 'frame',
      'price': 1500,
      'icon': '🔥',
      'color': AppColors.fire,
    },
    {
      'id': 'frame_ice',
      'name': 'Buz Çerçevesi',
      'type': 'frame',
      'price': 500,
      'icon': '❄️',
      'color': AppColors.ice,
    },
    {
      'id': 'title_legend',
      'name': 'Efsane',
      'type': 'title',
      'price': 3000,
      'icon': '👑',
      'color': Colors.amber,
    },
    {
      'id': 'title_joker',
      'name': 'Şakacı',
      'type': 'title',
      'price': 800,
      'icon': '🤡',
      'color': AppColors.accent,
    },
  ];

  void _buyItem(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} satın alındı! (Mock)'),
        backgroundColor: AppColors.votePositive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '5000', // Mock coin balance
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: GradientContainer(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _mockItems.length,
          itemBuilder: (context, index) {
            final item = _mockItems[index];
            final Color itemColor = item['color'];

            return Card(
              color: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: itemColor.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: itemColor.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        item['icon'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['name'],
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item['type'] == 'frame' ? 'Çerçeve' : 'Unvan',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: itemColor.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => _buyItem(item),
                    icon: const Icon(Icons.monetization_on_rounded, size: 16),
                    label: Text(item['price'].toString()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
