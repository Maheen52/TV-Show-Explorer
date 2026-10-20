import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'poster_image.dart';

// Bottom sheet with details of a person (opens when a cast member
// or a People search result is tapped).
void showPersonSheet(
  BuildContext context, {
  required String name,
  required String? imageUrl,
  String? subtitle,
  String? country,
  String? birthday,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: false, // stay inside the phone frame
    backgroundColor: AppColors.card,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PosterImage(url: imageUrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 12),
                  Text('Country: ${country ?? 'N/A'}'),
                  const SizedBox(height: 4),
                  Text('Born: ${birthday ?? 'N/A'}'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
