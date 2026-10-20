import 'package:flutter/material.dart';

import '../../../data/show_model.dart';
import '../app_colors.dart';
import 'open_show.dart';
import 'poster_image.dart';
import 'rating_text.dart';

// One show as a row (Search results, Watchlist, Similar tab).
// poster | title, years + rating, genres | trailing
// "trailing" is optional, e.g. hearts. Default is a ">" arrow.
class ShowTile extends StatelessWidget {
  final Show show;
  final Widget? trailing;

  const ShowTile({super.key, required this.show, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectShow(context, show),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 82,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PosterImage(url: show.imageUrl),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (show.years.isNotEmpty)
                        Text(
                          '${show.years}   ',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey),
                        ),
                      RatingText(rating: show.rating, fontSize: 12),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    show.genres.isEmpty ? 'No genre' : show.genres.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
