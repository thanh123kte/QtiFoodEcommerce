import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../../config/server_config.dart';
import '../../../../domain/entities/store.dart';
import '../../seller/products/widgets/product_theme.dart';
import 'seller_profile_overview_state.dart';
import 'seller_profile_overview_view_model.dart';
import 'seller_store_info_screen.dart';

class SellerProfileOverviewScreen extends StatefulWidget {
  final String ownerId;
  const SellerProfileOverviewScreen({super.key, required this.ownerId});

  @override
  State<SellerProfileOverviewScreen> createState() => _SellerProfileOverviewScreenState();
}

class _SellerProfileOverviewScreenState extends State<SellerProfileOverviewScreen> {
  late final SellerProfileOverviewViewModel _viewModel = GetIt.I<SellerProfileOverviewViewModel>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadStore(ownerId: widget.ownerId);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openStoreInfo(SellerProfileViewData data) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SellerStoreInfoScreen(data: data),
      ),
    );
    if (updated == true) {
      await _viewModel.retry();
    }
  }

  Future<void> _openReplySheet(
    SellerStoreReviewViewData review,
    SellerProfileOverviewViewModel vm,
  ) async {
    final reply = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReplySheet(initialReply: review.reply),
    );
    if (reply == null) return;

    final result = await vm.replyToReview(reviewId: review.id, reply: reply);
    if (!mounted) return;
    result.when(
      ok: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui .')),
      ),
      err: (message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SellerProfileOverviewViewModel>.value(
      value: _viewModel,
      child: Consumer<SellerProfileOverviewViewModel>(
        builder: (_, vm, __) {
          final state = vm.state;
          final storeName = switch (state) {
              SellerProfileOverviewLoaded(:final data) => data.name,
              _ => 'Đang tải thông tin cửa hàng...',
            };
          final storeData = switch (state) {
            SellerProfileOverviewLoaded(:final data) => data,
            _ => null,
          };
          return Scaffold(
              backgroundColor: sellerBackground,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(96),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7A30), Color(0xFFFFA852)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hồ sơ cửa hàng',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                Text(
                                  storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: storeData == null ? null : () => _openStoreInfo(storeData),
                            tooltip: 'Cập nhật cửa hàng',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: SafeArea(
              child: switch (state) {
                SellerProfileOverviewLoading() => const Center(child: CircularProgressIndicator()),
                SellerProfileOverviewError(:final message) => _ErrorView(
                    message: message,
                    onRetry: vm.retry,
                  ),
                SellerProfileOverviewLoaded(:final data, :final reviews) => RefreshIndicator(
                    color: sellerAccent,
                    onRefresh: vm.retry,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _ProfileHero(data: data),
                        const SizedBox(height: 16),
                        _QuickInfoCard(data: data),
                        const SizedBox(height: 16),
                        _StoreDetailsCard(data: data),
                        const SizedBox(height: 16),
                        _ReviewsSection(
                          reviews: reviews,
                          isLoading: vm.isLoadingReviews,
                          replyingIds: vm.replyingReviewIds,
                          onReply: (review) => _openReplySheet(review, vm),
                        ),
                      ],
                    ),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          );
        },
      ),
    );
  }

}

class _ProfileHero extends StatelessWidget {
  final SellerProfileViewData data;

  const _ProfileHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final avatar = resolveServerAssetUrl(data.avatarUrl);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? const Icon(Icons.storefront, size: 36, color: sellerAccent) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (data.email != null) _ChipTag(icon: Icons.email_outlined, label: data.email!),
                    if (data.phone != null) _ChipTag(icon: Icons.phone_outlined, label: data.phone!),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data.description?.isNotEmpty == true
                      ? data.description!
                      : 'Cap nhat mo ta ngan de khach biet ve cua hang ban.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final SellerProfileViewData data;

  const _QuickInfoCard({required this.data});

  String _formatTime(StoreDayTime? time) {
    return time?.toLocalTimeString() ?? 'Chua cap nhat';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin liên hệ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Địa chỉ',
            value: data.address?.isNotEmpty == true ? data.address! : 'Chưa cập nhật địa chỉ',
          ),
          _InfoRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Giờ mở cửa',
            value: _formatTime(data.openTime),
          ),
          _InfoRow(
            icon: Icons.nightlight_outlined,
            label: 'Giờ đóng cửa',
            value: _formatTime(data.closeTime),
          ),
        ],
      ),
    );
  }
}

class _StoreDetailsCard extends StatelessWidget {
  final SellerProfileViewData data;

  const _StoreDetailsCard({required this.data});

  String _formatTime(StoreDayTime? time) {
    return time?.toLocalTimeString() ?? 'Chưa cập nhật';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Gioi thieu',
          // Vietnamese text kept simple ASCII for consistency
          icon: Icons.info_outline,
          child: Text(
            data.description?.isNotEmpty == true
                ? data.description!
                : 'Chưa có mô tả. Hãy chia sẻ điểm nổi bật để thu hút khách hàng.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted, height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Liên hệ',
          icon: Icons.call_outlined,
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Số điện thoại',
                value: data.phone?.isNotEmpty == true ? data.phone! : 'Chưa cập nhật',
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: data.email?.isNotEmpty == true ? data.email! : 'Chưa cập nhật',
              ),
              _InfoRow(
                icon: Icons.place_outlined,
                label: 'Địa chỉ',
                value: data.address?.isNotEmpty == true ? data.address! : 'Chưa cập nhật địa chỉ',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Giờ hoạt động',
          icon: Icons.schedule_rounded,
          child: Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Mở cửa',
                  value: _formatTime(data.openTime),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoRow(
                  icon: Icons.nightlight_outlined,
                  label: 'Đóng cửa',
                  value: _formatTime(data.closeTime),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sellerAccentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: sellerAccent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2A44)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final List<SellerStoreReviewViewData> reviews;
  final bool isLoading;
  final Set<int> replyingIds;
  final void Function(SellerStoreReviewViewData review) onReply;

  const _ReviewsSection({
    required this.reviews,
    required this.isLoading,
    required this.replyingIds,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final avg = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sellerBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: sellerAccentSoft, shape: BoxShape.circle),
                child: const Icon(Icons.reviews_outlined, color: sellerAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá gần đây',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1F2A44)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
                        const SizedBox(width: 4),
                        Text(avg.toStringAsFixed(1),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Text('(${reviews.length} đánh giá)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: sellerTextMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reviews.isEmpty)
            Text(
              'Chưa có đánh giá nào.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: sellerTextMuted),
            )
          else
            Column(
              children: [
                for (int i = 0; i < reviews.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                  _ReviewTile(
                    review: reviews[i],
                    isReplying: replyingIds.contains(reviews[i].id),
                    onReply: () => onReply(reviews[i]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final SellerStoreReviewViewData review;
  final VoidCallback onReply;
  final bool isReplying;

  const _ReviewTile({
    required this.review,
    required this.onReply,
    required this.isReplying,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = review.avatarUrl;
    final replyText = review.reply?.trim() ?? '';
    final hasReply = replyText.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: sellerAccentSoft,
          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
          child: avatar == null
              ? Text(
                  review.initials,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: sellerAccent),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.author,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1F2A44)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ..._buildStars(review.rating),
                            const SizedBox(width: 8),
                            Text(
                              review.dateLabel,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              if (review.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: review.imageUrls
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(url, width: 72, height: 72, fit: BoxFit.cover),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (hasReply) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sellerAccentSoft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sellerBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.reply_rounded, size: 16, color: sellerAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Phản hôi từ cửa hàng',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700, color: sellerAccent),
                          ),
                          if (review.replyDateLabel != null && review.replyDateLabel!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '• ${review.replyDateLabel}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: sellerTextMuted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        replyText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isReplying ? null : onReply,
                    icon: isReplying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: sellerAccent),
                          )
                        : const Icon(Icons.reply_rounded, size: 18),
                    label: Text(isReplying ? 'Đang gửi...' : 'Phản hồi'),
                    style: TextButton.styleFrom(foregroundColor: sellerAccent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStars(double rating) {
    final widgets = <Widget>[];
    for (int i = 1; i <= 5; i++) {
      final diff = rating - i;
      IconData icon;
      if (diff >= 0) {
        icon = Icons.star_rounded;
      } else if (diff >= -0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_border_rounded;
      }
      widgets.add(Icon(icon, size: 16, color: Colors.amber.shade600));
    }
    return widgets;
  }
}

class _ReplySheet extends StatefulWidget {
  final String? initialReply;

  const _ReplySheet({this.initialReply});

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialReply ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: sellerBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Phản hồi đánh giá',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung phản hồi...',
                  errorText: _error,
                  filled: true,
                  fillColor: sellerBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: sellerAccent),
                        foregroundColor: sellerAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Huy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sellerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submit,
                      child: const Text('Gửi phản hồi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Vui lòng nhập nội dung phản hồi.');
      return;
    }
    Navigator.of(context).pop(text);
  }
}

class _ChipTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChipTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: sellerAccentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: sellerAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: sellerBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: sellerAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: sellerAccent, foregroundColor: Colors.white),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
