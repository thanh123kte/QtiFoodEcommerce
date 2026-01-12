import 'package:datn_foodecommerce_flutter_app/presentation/common/acction_title.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/date_picker.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/dropdown_title.dart';
import 'package:datn_foodecommerce_flutter_app/presentation/common/editable_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'profile_ui_state.dart';
import 'profile_view_model.dart';

class ProfileDetailScreen extends StatefulWidget {
  final ProfileViewData? data;

  const ProfileDetailScreen({super.key, this.data});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  String? _gender;
  DateTime? _birthDate;
  bool _saving = false;
  String? _error;

  bool _hasChanged = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    _nameController = TextEditingController(text: data?.displayName ?? '');
    _emailController = TextEditingController(text: data?.email ?? '');
    _phoneController = TextEditingController(text: data?.phone ?? '');
    _gender = _normalizeGender(data?.gender);
    _birthDate = data?.birthDate;
    _avatarUrl = data?.avatarUrl;

    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _checkForChanges() {
    final data = widget.data;

    final changed = _nameController.text.trim() != (data?.displayName ?? '') ||
        _emailController.text.trim() != (data?.email ?? '') ||
        _phoneController.text.trim() != (data?.phone ?? '') ||
        _gender != _normalizeGender(data?.gender) ||
        _birthDate != data?.birthDate;

    if (changed != _hasChanged) {
      setState(() => _hasChanged = changed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerData = _buildCurrentViewData();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hồ sơ của tôi'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (_saving || !_hasChanged) ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Luu',
                    style: TextStyle(
                      color: _hasChanged ? Colors.white : Colors.white54,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          children: [
            _HeaderSection(
              data: headerData,
              onEditAvatar: _changeAvatar,
              uploadingAvatar: _uploadingAvatar,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  EditableTile(
                    label: 'Họ và tên',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    showLabel: true,
                    useCard: true,
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Vui lòng nhập họ và tên'
                        : null,
                  ),
                  DropdownTile(
                    label: 'Giới tính',
                    hint: 'Chọn giới tính',
                    value: _gender,
                    items: const ['Nam', 'Nữ'],
                    onChanged: (value) {
                      setState(() => _gender = value);
                      _checkForChanges();
                    },
                  ),
                  DatePickerTile(
                    label: 'Ngày sinh',
                    value: _birthDate,
                    onTap: () async {
                      await _pickBirthDate();
                      _checkForChanges();
                    },
                  ),
                  EditableTile(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    showLabel: true,
                    useCard: true,
                  ),
                  EditableTile(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    showLabel: true,
                    useCard: true,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Vui lòng nhập email';
                      if (!text.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ActionTile(
              label: 'Đổi mật khẩu',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  ProfileViewData _buildCurrentViewData() {
    final base = widget.data;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    return ProfileViewData(
      displayName: name.isNotEmpty
          ? name
          : (email.isNotEmpty ? email : base?.displayName ?? 'Người dùng'),
      email: email.isNotEmpty ? email : null,
      phone: phone.isNotEmpty ? phone : null,
      avatarUrl: _avatarUrl ?? base?.avatarUrl,
      birthDate: _birthDate,
      gender: _gender,
    );
  }

  Future<void> _changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _uploadingAvatar = true;
      _error = null;
    });

    final vm = context.read<ProfileViewModel>();
    final result = await vm.uploadAvatar(picked.path);

    if (!mounted) return;
    result.when(
      ok: (data) {
        setState(() {
          _avatarUrl = data.avatarUrl ?? picked.path;
          _uploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh đại diện thành công')),
        );
      },
      err: (message) {
        setState(() {
          _uploadingAvatar = false;
          _error = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String? _normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    final lower = gender.toLowerCase();
    if (lower.contains('nữ') || lower.contains('female')) return 'Nữ';
    if (lower.contains('nam') || lower.contains('male')) return 'Nam';
    return gender;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });

    final vm = context.read<ProfileViewModel>();
    final result = await vm.submitProfileUpdate(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      gender: _gender,
      birthDate: _birthDate,
    );

    if (!mounted) return;

    result.when(
      ok: (_) {
        setState(() {
          _saving = false;
          _hasChanged = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')),
        );
        Navigator.of(context).pop();
      },
      err: (message) {
        setState(() {
          _saving = false;
          _error = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final ProfileViewData data;
  final VoidCallback onEditAvatar;
  final bool uploadingAvatar;

  const _HeaderSection({
    required this.data,
    required this.onEditAvatar,
    required this.uploadingAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 12 + topPadding, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF7F50),
            Color(0xFFFF4B2B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: uploadingAvatar ? null : onEditAvatar,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: (data.avatarUrl != null && data.avatarUrl!.isNotEmpty)
                      ? NetworkImage(data.avatarUrl!)
                      : null,
                  child: (data.avatarUrl == null || data.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 56, color: Colors.white)
                      : null,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: InkWell(
                  onTap: uploadingAvatar ? null : onEditAvatar,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: uploadingAvatar
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.black87,
                          ),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((data.email ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.email!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
