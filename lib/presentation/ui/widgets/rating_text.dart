import 'package:flutter/material.dart';

// Star icon + rating number. Shows "N/A" when there is no rating.
// suffix example: "/10" -> 9.1/10
class RatingText extends StatelessWidget {
  final double? rating;
  final double fontSize;
  final String suffix;

  const RatingText({
    super.key,
    required this.rating,
    this.fontSize = 14,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: fontSize + 2),
        const SizedBox(width: 2),
        Text(
          rating == null ? 'N/A' : '$rating$suffix',
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }
}
