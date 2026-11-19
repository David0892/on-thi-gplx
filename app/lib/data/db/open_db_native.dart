import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'user_db.dart';

/// Application Support, not Documents: the file is not user-visible and is
/// removed on uninstall (the app's only data-deletion path besides "Xoá tiến độ").
Future<UserDb?> openUserDb() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'user.db'));
  return UserDb(NativeDatabase.createInBackground(file));
}
