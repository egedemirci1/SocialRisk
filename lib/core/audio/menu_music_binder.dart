import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import 'audio_service.dart';
import 'menu_music_sync.dart';

/// GoRouter geçişlerinde menü müziğini senkronize eder.
class MenuMusicBinder extends ConsumerStatefulWidget {
  const MenuMusicBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MenuMusicBinder> createState() => _MenuMusicBinderState();
}

class _MenuMusicBinderState extends ConsumerState<MenuMusicBinder> {
  String? _lastLocation;

  @override
  void initState() {
    super.initState();
    appRouter.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onRouteChanged());
  }

  @override
  void dispose() {
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final location = appRouter.routerDelegate.currentConfiguration.fullPath;
    if (location == _lastLocation) return;
    _lastLocation = location;
    syncMenuMusicForRoute(ref.read(audioServiceProvider), location);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
