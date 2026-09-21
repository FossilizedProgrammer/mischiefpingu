import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/app_provider.dart';
import 'mixins/window_close_handler.dart';
import 'widgets/main_screen_body.dart';
import 'widgets/main_app_bar.dart';
import 'widgets/snackbar_mixin.dart';
import 'widgets/snackbar_dispatcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with
        SingleTickerProviderStateMixin,
        WindowListener,
        SnackBarMixin,
        WindowCloseHandler {
  bool _showMore = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleShowMore() async {
    final bool willShowMore = !_showMore;
    setState(() => _showMore = willShowMore);
    if (willShowMore) {
      _animController.forward();
      await windowManager.setMinimumSize(const Size(680, 722));
      await windowManager.setSize(const Size(780, 902));
    } else {
      _animController.reverse();
      await windowManager.setMinimumSize(const Size(680, 420));
      await windowManager.setSize(const Size(780, 462));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final processService = provider.processService;

    dispatchPendingSnackBars(context, processService, this);

    return Scaffold(
      appBar: const MainAppBar(),
      body: MainScreenBody(
        showMore: _showMore,
        fadeAnim: _fadeAnim,
        slideAnim: _slideAnim,
        onToggleShowMore: _toggleShowMore,
      ),
    );
  }
}
