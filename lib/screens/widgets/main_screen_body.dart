import 'package:flutter/material.dart';
import '../../widgets/connection_buttons.dart';
import '../../widgets/cdn_scanner_section.dart';
import 'theme_selector_tile.dart';
import 'suggested_presets.dart';
import 'aether_settings_tile.dart';
import 'psiphon_settings_tile.dart';
import 'tor_settings_tile.dart';
import 'sstp_settings_tile.dart';
import 'sstp_fetcher_section.dart';
import 'core_update_tile.dart';
import 'log_tile.dart';
import 'show_more_button.dart';

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
              child: const Column(children: [
                ThemeSelectorTile(),
                AetherSettingsTile(),
                PsiphonSettingsTile(),
                TorSettingsTile(),
                SstpSettingsTile(),
                CdnScannerSection(),
                SstpFetcherSection(),
                CoreUpdateTile(),
                LogTile(),
              ]),
            ),
          ),
      ],
    );
  }
}
