import 'package:flutter/material.dart';

import '../app_colors.dart';

// Shows a poster from the internet.
// If the show has no image or the image fails, a placeholder icon is shown.
class PosterImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const PosterImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _placeholder();
    }

    return Image.network(
      url!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      // while the image is downloading
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.card,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      // if the image fails to download
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.card,
      child: const Center(
        child: Icon(Icons.movie, size: 36, color: AppColors.grey),
      ),
    );
  }
}
