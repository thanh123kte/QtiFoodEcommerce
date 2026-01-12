import 'package:hive_flutter/hive_flutter.dart';

import '../../models/user_model.dart';

class UserLocal {
  static const String boxName = 'user_profiles';

  final Box<Map<dynamic, dynamic>> box;

  UserLocal(this.box);

  Future<void> saveUser(AppUserModel user) async {
    await box.put(user.id, user.toMap());
  }

  Future<AppUserModel?> getUser(String id) async {
    final data = box.get(id);
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data);
    return AppUserModel.fromJson(map);
  }

  Future<void> deleteUser(String id) async {
    await box.delete(id);
  }

  Future<void> clear() async {
    await box.clear();
  }
}
