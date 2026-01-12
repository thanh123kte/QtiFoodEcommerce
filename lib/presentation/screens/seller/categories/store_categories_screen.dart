import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../products/widgets/product_theme.dart';
import 'store_categories_view_model.dart';

class StoreCategoriesScreen extends StatefulWidget {
  final int storeId;

  const StoreCategoriesScreen({super.key, required this.storeId});

  @override
  State<StoreCategoriesScreen> createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  late final StoreCategoriesViewModel _viewModel = GetIt.I<StoreCategoriesViewModel>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.load(storeId: widget.storeId);
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChange)
      ..dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSearchChange() {
    _viewModel.search(_searchController.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreCategoriesViewModel>.value(
      value: _viewModel,
      child: Consumer<StoreCategoriesViewModel>(
        builder: (_, vm, __) {
          return Scaffold(
            backgroundColor: sellerBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: const Text('Danh mục cửa hàng'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: sellerAccent,
              foregroundColor: Colors.white,
              onPressed: vm.isProcessing ? null : () => _openCategoryForm(vm),
              icon: const Icon(Icons.add),
              label: const Text('Thêm danh mục'),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _HeaderBar(
                      total: vm.categories.length,
                      isLoading: vm.isLoading,
                      onAdd: vm.isProcessing ? null : () => _openCategoryForm(vm),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm danh mục',
                        prefixIcon: const Icon(Icons.search, color: sellerAccent),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: sellerTextMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  _viewModel.search('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: sellerBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (vm.error != null && !vm.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sellerAccentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: sellerAccent),
                            const SizedBox(width: 8),
                            Expanded(child: Text(vm.error!, style: const TextStyle(color: sellerAccent))),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, -2)),
                        ],
                      ),
                      child: _buildBody(vm),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(StoreCategoriesViewModel vm) {
    if (vm.isLoading && !vm.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = vm.categories;
    if (list.isEmpty) {
      return RefreshIndicator(
        color: sellerAccent,
        onRefresh: vm.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(Icons.inbox_outlined, size: 56, color: Colors.orange.shade200),
            const SizedBox(height: 12),
            const Center(child: Text('Chưa có danh mục nào')),
            const SizedBox(height: 6),
            const Center(child: Text('Nhấn "Thêm danh mục" để bắt đầu')),
            const SizedBox(height: 120),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: sellerAccent,
      onRefresh: vm.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = list[index];
          final parentName = vm.parentCategoryName(item.parentCategoryId);
          final parentDisplay = item.parentCategoryId == null || item.parentCategoryId == 0
              ? null
              : parentName == null
                  ? 'ID: ${item.parentCategoryId}'
                  : '$parentName (ID: ${item.parentCategoryId})';
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Colors.white, sellerBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: sellerBorder),
              boxShadow: const [
                BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(item.description!, style: const TextStyle(color: sellerTextMuted)),
                  if (parentDisplay != null)
                    Text('Danh mục sàn: $parentDisplay',
                        style: const TextStyle(color: sellerTextMuted)),
                ],
              ),
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: sellerAccent),
                    onPressed: vm.isProcessing ? null : () => _openCategoryForm(vm, initial: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: vm.isProcessing ? null : () => _confirmDelete(vm, item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCategoryForm(
    StoreCategoriesViewModel vm, {
    StoreCategoryViewData? initial,
  }) async {
    FocusScope.of(context).unfocus();
    await vm.ensureParentCategoriesLoaded();

    if (vm.parentCategoriesError != null && vm.parentCategories.isEmpty) {
      _showSnackBar('Không tải được danh sách danh mục: ${vm.parentCategoriesError}');
      return;
    }

    final List<_ParentCategoryOption> parentOptions = vm.parentCategories
        .map<_ParentCategoryOption>(
          (category) => _ParentCategoryOption(id: category.id, name: category.name),
        )
        .toList();

    final result = await showModalBottomSheet<_CategoryFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(
        initial: initial,
        parentOptions: parentOptions,
      ),
    );

    if (result == null) return;
    if (result.name.isEmpty) {
      _showSnackBar('Tên danh mục không được để trống');
      return;
    }

    await _executeWithLoading(() async {
        final updateResult = await vm.updateCategory(
          id: result.id,
          name: result.name,
          description: result.description?.isEmpty == true ? null : result.description,
          parentCategoryId: result.parentCategoryId,
        );
        updateResult.when(
          ok: (_) => _showSnackBar('Cập nhật danh mục thành công'),
          err: _showSnackBar,
        );
    });
  }

  Future<void> _confirmDelete(
    StoreCategoriesViewModel vm,
    StoreCategoryViewData item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn chắc chắn muốn xóa \"${item.name}\"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true) return;

    await _executeWithLoading(() async {
      final deleteResult = await vm.deleteCategory(item.id);
      deleteResult.when(
        ok: (_) => _showSnackBar('Đã xóa danh mục'),
        err: _showSnackBar,
      );
    });
  }

  Future<void> _executeWithLoading(Future<void> Function() action) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: sellerAccent)),
    );
    try {
      await action();
    } finally {
      if (mounted && navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CategoryFormResult {
  final int id;
  final String name;
  final String? description;
  final int parentCategoryId;

  _CategoryFormResult({
    required this.id,
    required this.name,
    this.description,
    required this.parentCategoryId,
  });
}

class _ParentCategoryOption {
  final int id;
  final String name;

  const _ParentCategoryOption({
    required this.id,
    required this.name,
  });
}

class _HeaderBar extends StatelessWidget {
  final int total;
  final bool isLoading;
  final VoidCallback? onAdd;

  const _HeaderBar({
    required this.total,
    required this.isLoading,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Colors.white, sellerBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: sellerBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý danh mục',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? 'Đang tải dữ liệu...' : 'Tổng $total danh mục',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: sellerAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Thêm mới'),
            ),
        ],
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final StoreCategoryViewData? initial;
  final List<_ParentCategoryOption> parentOptions;

  const _CategoryFormSheet({
    required this.initial,
    required this.parentOptions,
  });

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  int? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _selectedParentId = widget.initial?.parentCategoryId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final options = widget.parentOptions;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
                widget.initial == null ? 'Thêm danh mục' : 'Chỉnh sửa danh mục',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _nameCtrl,
                label: 'Tên danh mục',
                hint: 'Nhập tên danh mục',
              ),
              _InputField(
                controller: _descriptionCtrl,
                label: 'Mô tả danh mục',
                hint: 'Mô tả ngắn',
                maxLines: 2,
              ),
              DropdownButtonFormField<int?>(
                value: _selectedParentId,
                decoration: InputDecoration(
                  labelText: 'Danh mục sàn',
                  filled: true,
                  fillColor: sellerBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  ...options.map(
                    (option) => DropdownMenuItem<int?>(
                      value: option.id,
                      child: Text(option.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedParentId = value),
              ),
              if (options.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Hiện chưa có danh mục nào.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: sellerTextMuted),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sellerAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submit,
                  child: Text(widget.initial == null ? 'Tạo mới' : 'Cập nhật'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    Navigator.of(context).pop(
      _CategoryFormResult(
        id: widget.initial!.id,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        parentCategoryId: _selectedParentId!,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: sellerBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
