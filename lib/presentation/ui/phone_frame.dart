import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'see_all_screen.dart';

// A phone-shaped window. Inside it there is a small app with its own
// Navigator, so every window works on its own (scroll, tap, open "See All"...).
class PhoneFrame extends StatelessWidget {
  static const double width = 320;
  static const double height = 640;
  static const double statusBarHeight = 26;

  final String label; // text under the phone, e.g. "1. Discover / Home"
  final Widget child;

  const PhoneFrame({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    // The app inside thinks the screen is as big as the phone, not the browser.
    final mediaQuery = MediaQuery.of(context).copyWith(
      size: const Size(width, height - statusBarHeight),
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            children: [
              _buildStatusBar(),
              Expanded(
                child: MediaQuery(
                  data: mediaQuery,
                  // own ScaffoldMessenger = snack bars stay inside this phone
                  child: ScaffoldMessenger(
                    child: Navigator(
                      onGenerateRoute: (settings) {
                        // "See All" screen opens inside the same phone
                        if (settings.name == AppRoutes.seeAll) {
                          return MaterialPageRoute(
                            settings: settings,
                            builder: (_) => const SeeAllScreen(),
                          );
                        }
                        return MaterialPageRoute(
                          settings: settings,
                          builder: (_) => child,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }

  // fake phone status bar (time, signal, wifi, battery)
  Widget _buildStatusBar() {
    return const SizedBox(
      height: statusBarHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('9:41',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 13),
                SizedBox(width: 4),
                Icon(Icons.wifi, size: 13),
                SizedBox(width: 4),
                Icon(Icons.battery_full, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
