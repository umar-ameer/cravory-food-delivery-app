import 'package:flutter/material.dart';

import '../app/theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final IconData fallbackIcon;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fallbackIcon,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      child: Container(
        height: height,
        width: width,
        color: AppTheme.primary.withOpacity(0.12),
        child: hasImage
            ? Image.network(
                imageUrl,
                height: height,
                width: width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackIcon(icon: fallbackIcon);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                },
              )
            : _FallbackIcon(icon: fallbackIcon),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final IconData icon;

  const _FallbackIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        icon,
        size: 42,
        color: AppTheme.primary,
      ),
    );
  }
}