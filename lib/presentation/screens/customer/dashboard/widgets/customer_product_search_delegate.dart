import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../customer_dashboard_view_model.dart';
import '../customer_product_detail_screen.dart';

class CustomerProductSearchDelegate extends SearchDelegate<void> {
  final CustomerDashboardViewModel viewModel;
  final BuildContext parentContext;
  final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();

  CustomerProductSearchDelegate({
    required this.viewModel,
    required this.parentContext,
  }) {
    query = viewModel.query;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            viewModel.updateSearchQuery('');
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        viewModel.updateSearchQuery(query);
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    viewModel.updateSearchQuery(query);
    return _buildSuggestionList(context);
  }

  Widget _buildSuggestionList(BuildContext context) {
    final items = viewModel.visibleProducts;
    if (items.isEmpty) {
      return const Center(child: Text('No products found.'));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = items[index];
        return ListTile(
          leading: item.imageUrl == null
              ? const CircleAvatar(child: Icon(Icons.image_not_supported))
              : CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!)),
          title: Text(item.name),
          subtitle: Text(item.description ?? 'No description'),
          onTap: () {
            final userId = _firebaseAuth.currentUser?.uid;
            Navigator.of(parentContext).push(
              MaterialPageRoute(
                builder: (_) => CustomerProductDetailScreen(
                  product: item,
                  customerId: userId,
                ),
              ),
            );
            close(context, null);
          },
        );
      },
    );
  }
}
