import 'package:flutter/material.dart';

import '../customer_dashboard_view_model.dart';

class DashboardBannerCarousel extends StatefulWidget {
  final List<DashboardBannerData> banners;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const DashboardBannerCarousel({
    super.key,
    required this.banners,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  State<DashboardBannerCarousel> createState() => _DashboardBannerCarouselState();
}

class _DashboardBannerCarouselState extends State<DashboardBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _current = 0;
  static const Color _primary = Color(0xFFFF7A45);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      if (widget.isLoading) {
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (widget.error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: _primary),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.error!)),
                TextButton(onPressed: widget.onRetry, child: const Text('Thu lai')),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _current = index),
            itemCount: widget.banners.length,
            itemBuilder: (_, index) {
              final banner = widget.banners[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.hasClients && _pageController.position.haveDimensions) {
                    value = (_pageController.page ?? _pageController.initialPage.toDouble()) - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.white70,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Text(
                            banner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(color: Colors.black45, blurRadius: 6),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: index == _current ? 18 : 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: index == _current ? _primary : Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
