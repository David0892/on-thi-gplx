// Opens user.db on Android/iOS/desktop. On web (the dev preview only) there is
// no SQLite file, so openUserDb returns null and the app uses memory repos.
export 'open_db_stub.dart' if (dart.library.ffi) 'open_db_native.dart';
