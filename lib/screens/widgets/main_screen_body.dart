import 'package:flutter/material.dart';

import '../../widgets/connection_buttons.dart';
import 'suggested_presets.dart';
import 'show_more_button.dart';
import 'advanced_settings_column.dart';

class MainScreenBody extends StatelessWidget {
  final bool showMore;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final VoidCallback onToggleShowMore;

  const MainScreenBody({
    super.key,
    required this.showMore,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onToggleShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SuggestedPresets(),
        const ConnectionButtons(),
        ShowMoreButton(showMore: showMore, onTap: onToggleShowMore),
        if (showMore)
          FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: const AdvancedSettingsColumn(),
            ),
          ),
      ],
    );
  }
}
