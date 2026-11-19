// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_db.dart';

// ignore_for_file: type=lint
class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final int updatedAt;
  const Setting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, int? updatedAt}) => Setting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class QuestionProgress extends Table
    with TableInfo<QuestionProgress, QuestionProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuestionProgress(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classCodeMeta = const VerificationMeta(
    'classCode',
  );
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _questionKeyMeta = const VerificationMeta(
    'questionKey',
  );
  late final GeneratedColumn<String> questionKey = GeneratedColumn<String>(
    'question_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _timesSeenMeta = const VerificationMeta(
    'timesSeen',
  );
  late final GeneratedColumn<int> timesSeen = GeneratedColumn<int>(
    'times_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _timesWrongMeta = const VerificationMeta(
    'timesWrong',
  );
  late final GeneratedColumn<int> timesWrong = GeneratedColumn<int>(
    'times_wrong',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastCorrectMeta = const VerificationMeta(
    'lastCorrect',
  );
  late final GeneratedColumn<int> lastCorrect = GeneratedColumn<int>(
    'last_correct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (last_correct IN (0, 1))',
  );
  static const VerificationMeta _inWrongListMeta = const VerificationMeta(
    'inWrongList',
  );
  late final GeneratedColumn<int> inWrongList = GeneratedColumn<int>(
    'in_wrong_list',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (in_wrong_list IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastAnsweredAtMeta = const VerificationMeta(
    'lastAnsweredAt',
  );
  late final GeneratedColumn<int> lastAnsweredAt = GeneratedColumn<int>(
    'last_answered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    classCode,
    questionKey,
    timesSeen,
    timesWrong,
    lastCorrect,
    inWrongList,
    lastAnsweredAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_code')) {
      context.handle(
        _classCodeMeta,
        classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_classCodeMeta);
    }
    if (data.containsKey('question_key')) {
      context.handle(
        _questionKeyMeta,
        questionKey.isAcceptableOrUnknown(
          data['question_key']!,
          _questionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionKeyMeta);
    }
    if (data.containsKey('times_seen')) {
      context.handle(
        _timesSeenMeta,
        timesSeen.isAcceptableOrUnknown(data['times_seen']!, _timesSeenMeta),
      );
    }
    if (data.containsKey('times_wrong')) {
      context.handle(
        _timesWrongMeta,
        timesWrong.isAcceptableOrUnknown(data['times_wrong']!, _timesWrongMeta),
      );
    }
    if (data.containsKey('last_correct')) {
      context.handle(
        _lastCorrectMeta,
        lastCorrect.isAcceptableOrUnknown(
          data['last_correct']!,
          _lastCorrectMeta,
        ),
      );
    }
    if (data.containsKey('in_wrong_list')) {
      context.handle(
        _inWrongListMeta,
        inWrongList.isAcceptableOrUnknown(
          data['in_wrong_list']!,
          _inWrongListMeta,
        ),
      );
    }
    if (data.containsKey('last_answered_at')) {
      context.handle(
        _lastAnsweredAtMeta,
        lastAnsweredAt.isAcceptableOrUnknown(
          data['last_answered_at']!,
          _lastAnsweredAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classCode, questionKey};
  @override
  QuestionProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionProgressData(
      classCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_code'],
      )!,
      questionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_key'],
      )!,
      timesSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_seen'],
      )!,
      timesWrong: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_wrong'],
      )!,
      lastCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_correct'],
      ),
      inWrongList: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}in_wrong_list'],
      )!,
      lastAnsweredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_answered_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  QuestionProgress createAlias(String alias) {
    return QuestionProgress(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(class_code, question_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class QuestionProgressData extends DataClass
    implements Insertable<QuestionProgressData> {
  final String classCode;
  final String questionKey;
  final int timesSeen;
  final int timesWrong;
  final int? lastCorrect;
  final int inWrongList;
  final int? lastAnsweredAt;
  final int updatedAt;
  const QuestionProgressData({
    required this.classCode,
    required this.questionKey,
    required this.timesSeen,
    required this.timesWrong,
    this.lastCorrect,
    required this.inWrongList,
    this.lastAnsweredAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_code'] = Variable<String>(classCode);
    map['question_key'] = Variable<String>(questionKey);
    map['times_seen'] = Variable<int>(timesSeen);
    map['times_wrong'] = Variable<int>(timesWrong);
    if (!nullToAbsent || lastCorrect != null) {
      map['last_correct'] = Variable<int>(lastCorrect);
    }
    map['in_wrong_list'] = Variable<int>(inWrongList);
    if (!nullToAbsent || lastAnsweredAt != null) {
      map['last_answered_at'] = Variable<int>(lastAnsweredAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  QuestionProgressCompanion toCompanion(bool nullToAbsent) {
    return QuestionProgressCompanion(
      classCode: Value(classCode),
      questionKey: Value(questionKey),
      timesSeen: Value(timesSeen),
      timesWrong: Value(timesWrong),
      lastCorrect: lastCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCorrect),
      inWrongList: Value(inWrongList),
      lastAnsweredAt: lastAnsweredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAnsweredAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionProgressData(
      classCode: serializer.fromJson<String>(json['class_code']),
      questionKey: serializer.fromJson<String>(json['question_key']),
      timesSeen: serializer.fromJson<int>(json['times_seen']),
      timesWrong: serializer.fromJson<int>(json['times_wrong']),
      lastCorrect: serializer.fromJson<int?>(json['last_correct']),
      inWrongList: serializer.fromJson<int>(json['in_wrong_list']),
      lastAnsweredAt: serializer.fromJson<int?>(json['last_answered_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'class_code': serializer.toJson<String>(classCode),
      'question_key': serializer.toJson<String>(questionKey),
      'times_seen': serializer.toJson<int>(timesSeen),
      'times_wrong': serializer.toJson<int>(timesWrong),
      'last_correct': serializer.toJson<int?>(lastCorrect),
      'in_wrong_list': serializer.toJson<int>(inWrongList),
      'last_answered_at': serializer.toJson<int?>(lastAnsweredAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  QuestionProgressData copyWith({
    String? classCode,
    String? questionKey,
    int? timesSeen,
    int? timesWrong,
    Value<int?> lastCorrect = const Value.absent(),
    int? inWrongList,
    Value<int?> lastAnsweredAt = const Value.absent(),
    int? updatedAt,
  }) => QuestionProgressData(
    classCode: classCode ?? this.classCode,
    questionKey: questionKey ?? this.questionKey,
    timesSeen: timesSeen ?? this.timesSeen,
    timesWrong: timesWrong ?? this.timesWrong,
    lastCorrect: lastCorrect.present ? lastCorrect.value : this.lastCorrect,
    inWrongList: inWrongList ?? this.inWrongList,
    lastAnsweredAt: lastAnsweredAt.present
        ? lastAnsweredAt.value
        : this.lastAnsweredAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuestionProgressData copyWithCompanion(QuestionProgressCompanion data) {
    return QuestionProgressData(
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      questionKey: data.questionKey.present
          ? data.questionKey.value
          : this.questionKey,
      timesSeen: data.timesSeen.present ? data.timesSeen.value : this.timesSeen,
      timesWrong: data.timesWrong.present
          ? data.timesWrong.value
          : this.timesWrong,
      lastCorrect: data.lastCorrect.present
          ? data.lastCorrect.value
          : this.lastCorrect,
      inWrongList: data.inWrongList.present
          ? data.inWrongList.value
          : this.inWrongList,
      lastAnsweredAt: data.lastAnsweredAt.present
          ? data.lastAnsweredAt.value
          : this.lastAnsweredAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionProgressData(')
          ..write('classCode: $classCode, ')
          ..write('questionKey: $questionKey, ')
          ..write('timesSeen: $timesSeen, ')
          ..write('timesWrong: $timesWrong, ')
          ..write('lastCorrect: $lastCorrect, ')
          ..write('inWrongList: $inWrongList, ')
          ..write('lastAnsweredAt: $lastAnsweredAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    classCode,
    questionKey,
    timesSeen,
    timesWrong,
    lastCorrect,
    inWrongList,
    lastAnsweredAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionProgressData &&
          other.classCode == this.classCode &&
          other.questionKey == this.questionKey &&
          other.timesSeen == this.timesSeen &&
          other.timesWrong == this.timesWrong &&
          other.lastCorrect == this.lastCorrect &&
          other.inWrongList == this.inWrongList &&
          other.lastAnsweredAt == this.lastAnsweredAt &&
          other.updatedAt == this.updatedAt);
}

class QuestionProgressCompanion extends UpdateCompanion<QuestionProgressData> {
  final Value<String> classCode;
  final Value<String> questionKey;
  final Value<int> timesSeen;
  final Value<int> timesWrong;
  final Value<int?> lastCorrect;
  final Value<int> inWrongList;
  final Value<int?> lastAnsweredAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const QuestionProgressCompanion({
    this.classCode = const Value.absent(),
    this.questionKey = const Value.absent(),
    this.timesSeen = const Value.absent(),
    this.timesWrong = const Value.absent(),
    this.lastCorrect = const Value.absent(),
    this.inWrongList = const Value.absent(),
    this.lastAnsweredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionProgressCompanion.insert({
    required String classCode,
    required String questionKey,
    this.timesSeen = const Value.absent(),
    this.timesWrong = const Value.absent(),
    this.lastCorrect = const Value.absent(),
    this.inWrongList = const Value.absent(),
    this.lastAnsweredAt = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : classCode = Value(classCode),
       questionKey = Value(questionKey),
       updatedAt = Value(updatedAt);
  static Insertable<QuestionProgressData> custom({
    Expression<String>? classCode,
    Expression<String>? questionKey,
    Expression<int>? timesSeen,
    Expression<int>? timesWrong,
    Expression<int>? lastCorrect,
    Expression<int>? inWrongList,
    Expression<int>? lastAnsweredAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classCode != null) 'class_code': classCode,
      if (questionKey != null) 'question_key': questionKey,
      if (timesSeen != null) 'times_seen': timesSeen,
      if (timesWrong != null) 'times_wrong': timesWrong,
      if (lastCorrect != null) 'last_correct': lastCorrect,
      if (inWrongList != null) 'in_wrong_list': inWrongList,
      if (lastAnsweredAt != null) 'last_answered_at': lastAnsweredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionProgressCompanion copyWith({
    Value<String>? classCode,
    Value<String>? questionKey,
    Value<int>? timesSeen,
    Value<int>? timesWrong,
    Value<int?>? lastCorrect,
    Value<int>? inWrongList,
    Value<int?>? lastAnsweredAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuestionProgressCompanion(
      classCode: classCode ?? this.classCode,
      questionKey: questionKey ?? this.questionKey,
      timesSeen: timesSeen ?? this.timesSeen,
      timesWrong: timesWrong ?? this.timesWrong,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      inWrongList: inWrongList ?? this.inWrongList,
      lastAnsweredAt: lastAnsweredAt ?? this.lastAnsweredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (questionKey.present) {
      map['question_key'] = Variable<String>(questionKey.value);
    }
    if (timesSeen.present) {
      map['times_seen'] = Variable<int>(timesSeen.value);
    }
    if (timesWrong.present) {
      map['times_wrong'] = Variable<int>(timesWrong.value);
    }
    if (lastCorrect.present) {
      map['last_correct'] = Variable<int>(lastCorrect.value);
    }
    if (inWrongList.present) {
      map['in_wrong_list'] = Variable<int>(inWrongList.value);
    }
    if (lastAnsweredAt.present) {
      map['last_answered_at'] = Variable<int>(lastAnsweredAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionProgressCompanion(')
          ..write('classCode: $classCode, ')
          ..write('questionKey: $questionKey, ')
          ..write('timesSeen: $timesSeen, ')
          ..write('timesWrong: $timesWrong, ')
          ..write('lastCorrect: $lastCorrect, ')
          ..write('inWrongList: $inWrongList, ')
          ..write('lastAnsweredAt: $lastAnsweredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Bookmarks extends Table with TableInfo<Bookmarks, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Bookmarks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionKeyMeta = const VerificationMeta(
    'questionKey',
  );
  late final GeneratedColumn<String> questionKey = GeneratedColumn<String>(
    'question_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [questionKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_key')) {
      context.handle(
        _questionKeyMeta,
        questionKey.isAcceptableOrUnknown(
          data['question_key']!,
          _questionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionKey};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      questionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Bookmarks createAlias(String alias) {
    return Bookmarks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String questionKey;
  final int createdAt;
  const Bookmark({required this.questionKey, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_key'] = Variable<String>(questionKey);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      questionKey: Value(questionKey),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      questionKey: serializer.fromJson<String>(json['question_key']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'question_key': serializer.toJson<String>(questionKey),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Bookmark copyWith({String? questionKey, int? createdAt}) => Bookmark(
    questionKey: questionKey ?? this.questionKey,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      questionKey: data.questionKey.present
          ? data.questionKey.value
          : this.questionKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('questionKey: $questionKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.questionKey == this.questionKey &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> questionKey;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.questionKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String questionKey,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : questionKey = Value(questionKey),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<String>? questionKey,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionKey != null) 'question_key': questionKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? questionKey,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      questionKey: questionKey ?? this.questionKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionKey.present) {
      map['question_key'] = Variable<String>(questionKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('questionKey: $questionKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TopicCursor extends Table with TableInfo<TopicCursor, TopicCursorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TopicCursor(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classCodeMeta = const VerificationMeta(
    'classCode',
  );
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    classCode,
    topicId,
    position,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_cursor';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicCursorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_code')) {
      context.handle(
        _classCodeMeta,
        classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_classCodeMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classCode, topicId};
  @override
  TopicCursorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicCursorData(
      classCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_code'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  TopicCursor createAlias(String alias) {
    return TopicCursor(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(class_code, topic_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TopicCursorData extends DataClass implements Insertable<TopicCursorData> {
  final String classCode;
  final int topicId;
  final int position;
  final int updatedAt;
  const TopicCursorData({
    required this.classCode,
    required this.topicId,
    required this.position,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_code'] = Variable<String>(classCode);
    map['topic_id'] = Variable<int>(topicId);
    map['position'] = Variable<int>(position);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TopicCursorCompanion toCompanion(bool nullToAbsent) {
    return TopicCursorCompanion(
      classCode: Value(classCode),
      topicId: Value(topicId),
      position: Value(position),
      updatedAt: Value(updatedAt),
    );
  }

  factory TopicCursorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicCursorData(
      classCode: serializer.fromJson<String>(json['class_code']),
      topicId: serializer.fromJson<int>(json['topic_id']),
      position: serializer.fromJson<int>(json['position']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'class_code': serializer.toJson<String>(classCode),
      'topic_id': serializer.toJson<int>(topicId),
      'position': serializer.toJson<int>(position),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  TopicCursorData copyWith({
    String? classCode,
    int? topicId,
    int? position,
    int? updatedAt,
  }) => TopicCursorData(
    classCode: classCode ?? this.classCode,
    topicId: topicId ?? this.topicId,
    position: position ?? this.position,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TopicCursorData copyWithCompanion(TopicCursorCompanion data) {
    return TopicCursorData(
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      position: data.position.present ? data.position.value : this.position,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicCursorData(')
          ..write('classCode: $classCode, ')
          ..write('topicId: $topicId, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(classCode, topicId, position, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicCursorData &&
          other.classCode == this.classCode &&
          other.topicId == this.topicId &&
          other.position == this.position &&
          other.updatedAt == this.updatedAt);
}

class TopicCursorCompanion extends UpdateCompanion<TopicCursorData> {
  final Value<String> classCode;
  final Value<int> topicId;
  final Value<int> position;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TopicCursorCompanion({
    this.classCode = const Value.absent(),
    this.topicId = const Value.absent(),
    this.position = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicCursorCompanion.insert({
    required String classCode,
    required int topicId,
    this.position = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : classCode = Value(classCode),
       topicId = Value(topicId),
       updatedAt = Value(updatedAt);
  static Insertable<TopicCursorData> custom({
    Expression<String>? classCode,
    Expression<int>? topicId,
    Expression<int>? position,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classCode != null) 'class_code': classCode,
      if (topicId != null) 'topic_id': topicId,
      if (position != null) 'position': position,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicCursorCompanion copyWith({
    Value<String>? classCode,
    Value<int>? topicId,
    Value<int>? position,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TopicCursorCompanion(
      classCode: classCode ?? this.classCode,
      topicId: topicId ?? this.topicId,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicCursorCompanion(')
          ..write('classCode: $classCode, ')
          ..write('topicId: $topicId, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ExamAttempts extends Table with TableInfo<ExamAttempts, ExamAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExamAttempts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _classCodeMeta = const VerificationMeta(
    'classCode',
  );
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _examSetNumberMeta = const VerificationMeta(
    'examSetNumber',
  );
  late final GeneratedColumn<int> examSetNumber = GeneratedColumn<int>(
    'exam_set_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'in_progress\' CHECK (status IN (\'in_progress\', \'submitted\', \'timed_out\', \'abandoned\'))',
    defaultValue: const CustomExpression('\'in_progress\''),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deadlineAtMeta = const VerificationMeta(
    'deadlineAt',
  );
  late final GeneratedColumn<int> deadlineAt = GeneratedColumn<int>(
    'deadline_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _passMarkMeta = const VerificationMeta(
    'passMark',
  );
  late final GeneratedColumn<int> passMark = GeneratedColumn<int>(
    'pass_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _passedMeta = const VerificationMeta('passed');
  late final GeneratedColumn<int> passed = GeneratedColumn<int>(
    'passed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (passed IN (0, 1))',
  );
  static const VerificationMeta _failedOnCriticalMeta = const VerificationMeta(
    'failedOnCritical',
  );
  late final GeneratedColumn<int> failedOnCritical = GeneratedColumn<int>(
    'failed_on_critical',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (failed_on_critical IN (0, 1))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classCode,
    examSetNumber,
    contentVersion,
    status,
    startedAt,
    deadlineAt,
    finishedAt,
    questionCount,
    passMark,
    score,
    passed,
    failedOnCritical,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_code')) {
      context.handle(
        _classCodeMeta,
        classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_classCodeMeta);
    }
    if (data.containsKey('exam_set_number')) {
      context.handle(
        _examSetNumberMeta,
        examSetNumber.isAcceptableOrUnknown(
          data['exam_set_number']!,
          _examSetNumberMeta,
        ),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
        _deadlineAtMeta,
        deadlineAt.isAcceptableOrUnknown(data['deadline_at']!, _deadlineAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCountMeta);
    }
    if (data.containsKey('pass_mark')) {
      context.handle(
        _passMarkMeta,
        passMark.isAcceptableOrUnknown(data['pass_mark']!, _passMarkMeta),
      );
    } else if (isInserting) {
      context.missing(_passMarkMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('passed')) {
      context.handle(
        _passedMeta,
        passed.isAcceptableOrUnknown(data['passed']!, _passedMeta),
      );
    }
    if (data.containsKey('failed_on_critical')) {
      context.handle(
        _failedOnCriticalMeta,
        failedOnCritical.isAcceptableOrUnknown(
          data['failed_on_critical']!,
          _failedOnCriticalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      classCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_code'],
      )!,
      examSetNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_set_number'],
      ),
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      deadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      passMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_mark'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      passed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passed'],
      ),
      failedOnCritical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_on_critical'],
      ),
    );
  }

  @override
  ExamAttempts createAlias(String alias) {
    return ExamAttempts(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(deadline_at > started_at)',
    'CHECK(status = \'in_progress\' OR finished_at IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ExamAttempt extends DataClass implements Insertable<ExamAttempt> {
  final int id;
  final String classCode;
  final int? examSetNumber;
  final int contentVersion;
  final String status;
  final int startedAt;
  final int deadlineAt;
  final int? finishedAt;
  final int questionCount;
  final int passMark;
  final int? score;
  final int? passed;
  final int? failedOnCritical;
  const ExamAttempt({
    required this.id,
    required this.classCode,
    this.examSetNumber,
    required this.contentVersion,
    required this.status,
    required this.startedAt,
    required this.deadlineAt,
    this.finishedAt,
    required this.questionCount,
    required this.passMark,
    this.score,
    this.passed,
    this.failedOnCritical,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_code'] = Variable<String>(classCode);
    if (!nullToAbsent || examSetNumber != null) {
      map['exam_set_number'] = Variable<int>(examSetNumber);
    }
    map['content_version'] = Variable<int>(contentVersion);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    map['deadline_at'] = Variable<int>(deadlineAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['pass_mark'] = Variable<int>(passMark);
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || passed != null) {
      map['passed'] = Variable<int>(passed);
    }
    if (!nullToAbsent || failedOnCritical != null) {
      map['failed_on_critical'] = Variable<int>(failedOnCritical);
    }
    return map;
  }

  ExamAttemptsCompanion toCompanion(bool nullToAbsent) {
    return ExamAttemptsCompanion(
      id: Value(id),
      classCode: Value(classCode),
      examSetNumber: examSetNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(examSetNumber),
      contentVersion: Value(contentVersion),
      status: Value(status),
      startedAt: Value(startedAt),
      deadlineAt: Value(deadlineAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      questionCount: Value(questionCount),
      passMark: Value(passMark),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      passed: passed == null && nullToAbsent
          ? const Value.absent()
          : Value(passed),
      failedOnCritical: failedOnCritical == null && nullToAbsent
          ? const Value.absent()
          : Value(failedOnCritical),
    );
  }

  factory ExamAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamAttempt(
      id: serializer.fromJson<int>(json['id']),
      classCode: serializer.fromJson<String>(json['class_code']),
      examSetNumber: serializer.fromJson<int?>(json['exam_set_number']),
      contentVersion: serializer.fromJson<int>(json['content_version']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      deadlineAt: serializer.fromJson<int>(json['deadline_at']),
      finishedAt: serializer.fromJson<int?>(json['finished_at']),
      questionCount: serializer.fromJson<int>(json['question_count']),
      passMark: serializer.fromJson<int>(json['pass_mark']),
      score: serializer.fromJson<int?>(json['score']),
      passed: serializer.fromJson<int?>(json['passed']),
      failedOnCritical: serializer.fromJson<int?>(json['failed_on_critical']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'class_code': serializer.toJson<String>(classCode),
      'exam_set_number': serializer.toJson<int?>(examSetNumber),
      'content_version': serializer.toJson<int>(contentVersion),
      'status': serializer.toJson<String>(status),
      'started_at': serializer.toJson<int>(startedAt),
      'deadline_at': serializer.toJson<int>(deadlineAt),
      'finished_at': serializer.toJson<int?>(finishedAt),
      'question_count': serializer.toJson<int>(questionCount),
      'pass_mark': serializer.toJson<int>(passMark),
      'score': serializer.toJson<int?>(score),
      'passed': serializer.toJson<int?>(passed),
      'failed_on_critical': serializer.toJson<int?>(failedOnCritical),
    };
  }

  ExamAttempt copyWith({
    int? id,
    String? classCode,
    Value<int?> examSetNumber = const Value.absent(),
    int? contentVersion,
    String? status,
    int? startedAt,
    int? deadlineAt,
    Value<int?> finishedAt = const Value.absent(),
    int? questionCount,
    int? passMark,
    Value<int?> score = const Value.absent(),
    Value<int?> passed = const Value.absent(),
    Value<int?> failedOnCritical = const Value.absent(),
  }) => ExamAttempt(
    id: id ?? this.id,
    classCode: classCode ?? this.classCode,
    examSetNumber: examSetNumber.present
        ? examSetNumber.value
        : this.examSetNumber,
    contentVersion: contentVersion ?? this.contentVersion,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    deadlineAt: deadlineAt ?? this.deadlineAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    questionCount: questionCount ?? this.questionCount,
    passMark: passMark ?? this.passMark,
    score: score.present ? score.value : this.score,
    passed: passed.present ? passed.value : this.passed,
    failedOnCritical: failedOnCritical.present
        ? failedOnCritical.value
        : this.failedOnCritical,
  );
  ExamAttempt copyWithCompanion(ExamAttemptsCompanion data) {
    return ExamAttempt(
      id: data.id.present ? data.id.value : this.id,
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      examSetNumber: data.examSetNumber.present
          ? data.examSetNumber.value
          : this.examSetNumber,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      deadlineAt: data.deadlineAt.present
          ? data.deadlineAt.value
          : this.deadlineAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      passMark: data.passMark.present ? data.passMark.value : this.passMark,
      score: data.score.present ? data.score.value : this.score,
      passed: data.passed.present ? data.passed.value : this.passed,
      failedOnCritical: data.failedOnCritical.present
          ? data.failedOnCritical.value
          : this.failedOnCritical,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamAttempt(')
          ..write('id: $id, ')
          ..write('classCode: $classCode, ')
          ..write('examSetNumber: $examSetNumber, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('questionCount: $questionCount, ')
          ..write('passMark: $passMark, ')
          ..write('score: $score, ')
          ..write('passed: $passed, ')
          ..write('failedOnCritical: $failedOnCritical')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    classCode,
    examSetNumber,
    contentVersion,
    status,
    startedAt,
    deadlineAt,
    finishedAt,
    questionCount,
    passMark,
    score,
    passed,
    failedOnCritical,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamAttempt &&
          other.id == this.id &&
          other.classCode == this.classCode &&
          other.examSetNumber == this.examSetNumber &&
          other.contentVersion == this.contentVersion &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.deadlineAt == this.deadlineAt &&
          other.finishedAt == this.finishedAt &&
          other.questionCount == this.questionCount &&
          other.passMark == this.passMark &&
          other.score == this.score &&
          other.passed == this.passed &&
          other.failedOnCritical == this.failedOnCritical);
}

class ExamAttemptsCompanion extends UpdateCompanion<ExamAttempt> {
  final Value<int> id;
  final Value<String> classCode;
  final Value<int?> examSetNumber;
  final Value<int> contentVersion;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int> deadlineAt;
  final Value<int?> finishedAt;
  final Value<int> questionCount;
  final Value<int> passMark;
  final Value<int?> score;
  final Value<int?> passed;
  final Value<int?> failedOnCritical;
  const ExamAttemptsCompanion({
    this.id = const Value.absent(),
    this.classCode = const Value.absent(),
    this.examSetNumber = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.passMark = const Value.absent(),
    this.score = const Value.absent(),
    this.passed = const Value.absent(),
    this.failedOnCritical = const Value.absent(),
  });
  ExamAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String classCode,
    this.examSetNumber = const Value.absent(),
    required int contentVersion,
    this.status = const Value.absent(),
    required int startedAt,
    required int deadlineAt,
    this.finishedAt = const Value.absent(),
    required int questionCount,
    required int passMark,
    this.score = const Value.absent(),
    this.passed = const Value.absent(),
    this.failedOnCritical = const Value.absent(),
  }) : classCode = Value(classCode),
       contentVersion = Value(contentVersion),
       startedAt = Value(startedAt),
       deadlineAt = Value(deadlineAt),
       questionCount = Value(questionCount),
       passMark = Value(passMark);
  static Insertable<ExamAttempt> custom({
    Expression<int>? id,
    Expression<String>? classCode,
    Expression<int>? examSetNumber,
    Expression<int>? contentVersion,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? deadlineAt,
    Expression<int>? finishedAt,
    Expression<int>? questionCount,
    Expression<int>? passMark,
    Expression<int>? score,
    Expression<int>? passed,
    Expression<int>? failedOnCritical,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classCode != null) 'class_code': classCode,
      if (examSetNumber != null) 'exam_set_number': examSetNumber,
      if (contentVersion != null) 'content_version': contentVersion,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (questionCount != null) 'question_count': questionCount,
      if (passMark != null) 'pass_mark': passMark,
      if (score != null) 'score': score,
      if (passed != null) 'passed': passed,
      if (failedOnCritical != null) 'failed_on_critical': failedOnCritical,
    });
  }

  ExamAttemptsCompanion copyWith({
    Value<int>? id,
    Value<String>? classCode,
    Value<int?>? examSetNumber,
    Value<int>? contentVersion,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int>? deadlineAt,
    Value<int?>? finishedAt,
    Value<int>? questionCount,
    Value<int>? passMark,
    Value<int?>? score,
    Value<int?>? passed,
    Value<int?>? failedOnCritical,
  }) {
    return ExamAttemptsCompanion(
      id: id ?? this.id,
      classCode: classCode ?? this.classCode,
      examSetNumber: examSetNumber ?? this.examSetNumber,
      contentVersion: contentVersion ?? this.contentVersion,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      finishedAt: finishedAt ?? this.finishedAt,
      questionCount: questionCount ?? this.questionCount,
      passMark: passMark ?? this.passMark,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      failedOnCritical: failedOnCritical ?? this.failedOnCritical,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (examSetNumber.present) {
      map['exam_set_number'] = Variable<int>(examSetNumber.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<int>(deadlineAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (passMark.present) {
      map['pass_mark'] = Variable<int>(passMark.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (passed.present) {
      map['passed'] = Variable<int>(passed.value);
    }
    if (failedOnCritical.present) {
      map['failed_on_critical'] = Variable<int>(failedOnCritical.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('classCode: $classCode, ')
          ..write('examSetNumber: $examSetNumber, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('questionCount: $questionCount, ')
          ..write('passMark: $passMark, ')
          ..write('score: $score, ')
          ..write('passed: $passed, ')
          ..write('failedOnCritical: $failedOnCritical')
          ..write(')'))
        .toString();
  }
}

class AttemptAnswers extends Table
    with TableInfo<AttemptAnswers, AttemptAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AttemptAnswers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES exam_attempts(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _questionKeyMeta = const VerificationMeta(
    'questionKey',
  );
  late final GeneratedColumn<String> questionKey = GeneratedColumn<String>(
    'question_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isCriticalMeta = const VerificationMeta(
    'isCritical',
  );
  late final GeneratedColumn<int> isCritical = GeneratedColumn<int>(
    'is_critical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_critical IN (0, 1))',
  );
  static const VerificationMeta _chosenPositionMeta = const VerificationMeta(
    'chosenPosition',
  );
  late final GeneratedColumn<int> chosenPosition = GeneratedColumn<int>(
    'chosen_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (chosen_position BETWEEN 1 AND 4)',
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  late final GeneratedColumn<int> isCorrect = GeneratedColumn<int>(
    'is_correct',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (is_correct IN (0, 1))',
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    position,
    questionKey,
    isCritical,
    chosenPosition,
    isCorrect,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('question_key')) {
      context.handle(
        _questionKeyMeta,
        questionKey.isAcceptableOrUnknown(
          data['question_key']!,
          _questionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionKeyMeta);
    }
    if (data.containsKey('is_critical')) {
      context.handle(
        _isCriticalMeta,
        isCritical.isAcceptableOrUnknown(data['is_critical']!, _isCriticalMeta),
      );
    } else if (isInserting) {
      context.missing(_isCriticalMeta);
    }
    if (data.containsKey('chosen_position')) {
      context.handle(
        _chosenPositionMeta,
        chosenPosition.isAcceptableOrUnknown(
          data['chosen_position']!,
          _chosenPositionMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId, position};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {attemptId, questionKey},
  ];
  @override
  AttemptAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptAnswer(
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      questionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_key'],
      )!,
      isCritical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_critical'],
      )!,
      chosenPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chosen_position'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_correct'],
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  AttemptAnswers createAlias(String alias) {
    return AttemptAnswers(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(attempt_id, position)',
    'UNIQUE(attempt_id, question_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class AttemptAnswer extends DataClass implements Insertable<AttemptAnswer> {
  final int attemptId;
  final int position;
  final String questionKey;
  final int isCritical;
  final int? chosenPosition;
  final int? isCorrect;
  final int? answeredAt;
  const AttemptAnswer({
    required this.attemptId,
    required this.position,
    required this.questionKey,
    required this.isCritical,
    this.chosenPosition,
    this.isCorrect,
    this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<int>(attemptId);
    map['position'] = Variable<int>(position);
    map['question_key'] = Variable<String>(questionKey);
    map['is_critical'] = Variable<int>(isCritical);
    if (!nullToAbsent || chosenPosition != null) {
      map['chosen_position'] = Variable<int>(chosenPosition);
    }
    if (!nullToAbsent || isCorrect != null) {
      map['is_correct'] = Variable<int>(isCorrect);
    }
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<int>(answeredAt);
    }
    return map;
  }

  AttemptAnswersCompanion toCompanion(bool nullToAbsent) {
    return AttemptAnswersCompanion(
      attemptId: Value(attemptId),
      position: Value(position),
      questionKey: Value(questionKey),
      isCritical: Value(isCritical),
      chosenPosition: chosenPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(chosenPosition),
      isCorrect: isCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(isCorrect),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory AttemptAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptAnswer(
      attemptId: serializer.fromJson<int>(json['attempt_id']),
      position: serializer.fromJson<int>(json['position']),
      questionKey: serializer.fromJson<String>(json['question_key']),
      isCritical: serializer.fromJson<int>(json['is_critical']),
      chosenPosition: serializer.fromJson<int?>(json['chosen_position']),
      isCorrect: serializer.fromJson<int?>(json['is_correct']),
      answeredAt: serializer.fromJson<int?>(json['answered_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attempt_id': serializer.toJson<int>(attemptId),
      'position': serializer.toJson<int>(position),
      'question_key': serializer.toJson<String>(questionKey),
      'is_critical': serializer.toJson<int>(isCritical),
      'chosen_position': serializer.toJson<int?>(chosenPosition),
      'is_correct': serializer.toJson<int?>(isCorrect),
      'answered_at': serializer.toJson<int?>(answeredAt),
    };
  }

  AttemptAnswer copyWith({
    int? attemptId,
    int? position,
    String? questionKey,
    int? isCritical,
    Value<int?> chosenPosition = const Value.absent(),
    Value<int?> isCorrect = const Value.absent(),
    Value<int?> answeredAt = const Value.absent(),
  }) => AttemptAnswer(
    attemptId: attemptId ?? this.attemptId,
    position: position ?? this.position,
    questionKey: questionKey ?? this.questionKey,
    isCritical: isCritical ?? this.isCritical,
    chosenPosition: chosenPosition.present
        ? chosenPosition.value
        : this.chosenPosition,
    isCorrect: isCorrect.present ? isCorrect.value : this.isCorrect,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  AttemptAnswer copyWithCompanion(AttemptAnswersCompanion data) {
    return AttemptAnswer(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      position: data.position.present ? data.position.value : this.position,
      questionKey: data.questionKey.present
          ? data.questionKey.value
          : this.questionKey,
      isCritical: data.isCritical.present
          ? data.isCritical.value
          : this.isCritical,
      chosenPosition: data.chosenPosition.present
          ? data.chosenPosition.value
          : this.chosenPosition,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswer(')
          ..write('attemptId: $attemptId, ')
          ..write('position: $position, ')
          ..write('questionKey: $questionKey, ')
          ..write('isCritical: $isCritical, ')
          ..write('chosenPosition: $chosenPosition, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attemptId,
    position,
    questionKey,
    isCritical,
    chosenPosition,
    isCorrect,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptAnswer &&
          other.attemptId == this.attemptId &&
          other.position == this.position &&
          other.questionKey == this.questionKey &&
          other.isCritical == this.isCritical &&
          other.chosenPosition == this.chosenPosition &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class AttemptAnswersCompanion extends UpdateCompanion<AttemptAnswer> {
  final Value<int> attemptId;
  final Value<int> position;
  final Value<String> questionKey;
  final Value<int> isCritical;
  final Value<int?> chosenPosition;
  final Value<int?> isCorrect;
  final Value<int?> answeredAt;
  final Value<int> rowid;
  const AttemptAnswersCompanion({
    this.attemptId = const Value.absent(),
    this.position = const Value.absent(),
    this.questionKey = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.chosenPosition = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptAnswersCompanion.insert({
    required int attemptId,
    required int position,
    required String questionKey,
    required int isCritical,
    this.chosenPosition = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : attemptId = Value(attemptId),
       position = Value(position),
       questionKey = Value(questionKey),
       isCritical = Value(isCritical);
  static Insertable<AttemptAnswer> custom({
    Expression<int>? attemptId,
    Expression<int>? position,
    Expression<String>? questionKey,
    Expression<int>? isCritical,
    Expression<int>? chosenPosition,
    Expression<int>? isCorrect,
    Expression<int>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (position != null) 'position': position,
      if (questionKey != null) 'question_key': questionKey,
      if (isCritical != null) 'is_critical': isCritical,
      if (chosenPosition != null) 'chosen_position': chosenPosition,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptAnswersCompanion copyWith({
    Value<int>? attemptId,
    Value<int>? position,
    Value<String>? questionKey,
    Value<int>? isCritical,
    Value<int?>? chosenPosition,
    Value<int?>? isCorrect,
    Value<int?>? answeredAt,
    Value<int>? rowid,
  }) {
    return AttemptAnswersCompanion(
      attemptId: attemptId ?? this.attemptId,
      position: position ?? this.position,
      questionKey: questionKey ?? this.questionKey,
      isCritical: isCritical ?? this.isCritical,
      chosenPosition: chosenPosition ?? this.chosenPosition,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (questionKey.present) {
      map['question_key'] = Variable<String>(questionKey.value);
    }
    if (isCritical.present) {
      map['is_critical'] = Variable<int>(isCritical.value);
    }
    if (chosenPosition.present) {
      map['chosen_position'] = Variable<int>(chosenPosition.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<int>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswersCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('position: $position, ')
          ..write('questionKey: $questionKey, ')
          ..write('isCritical: $isCritical, ')
          ..write('chosenPosition: $chosenPosition, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDb extends GeneratedDatabase {
  _$UserDb(QueryExecutor e) : super(e);
  $UserDbManager get managers => $UserDbManager(this);
  late final Settings settings = Settings(this);
  late final QuestionProgress questionProgress = QuestionProgress(this);
  late final Index progressWrong = Index(
    'progress_wrong',
    'CREATE INDEX progress_wrong ON question_progress (class_code, last_answered_at) WHERE in_wrong_list = 1',
  );
  late final Bookmarks bookmarks = Bookmarks(this);
  late final TopicCursor topicCursor = TopicCursor(this);
  late final ExamAttempts examAttempts = ExamAttempts(this);
  late final Index attemptsHistory = Index(
    'attempts_history',
    'CREATE INDEX attempts_history ON exam_attempts (class_code, started_at DESC)',
  );
  late final Index oneRunningExam = Index(
    'one_running_exam',
    'CREATE UNIQUE INDEX one_running_exam ON exam_attempts (status) WHERE status = \'in_progress\'',
  );
  late final AttemptAnswers attemptAnswers = AttemptAnswers(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    questionProgress,
    progressWrong,
    bookmarks,
    topicCursor,
    examAttempts,
    attemptsHistory,
    oneRunningExam,
    attemptAnswers,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_attempts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempt_answers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $SettingsCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required int updatedAt,
  Value<int> rowid,
});
typedef $SettingsUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $SettingsFilterComposer extends Composer<_$UserDb, Settings> {
  $SettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingsOrderingComposer extends Composer<_$UserDb, Settings> {
  $SettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingsAnnotationComposer extends Composer<_$UserDb, Settings> {
  $SettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$UserDb,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$UserDb, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$UserDb db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settings, Setting>(table),
                  BaseReferences<_$UserDb, Settings, Setting>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$UserDb, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $QuestionProgressCreateCompanionBuilder =
    QuestionProgressCompanion Function({
      required String classCode,
      required String questionKey,
      Value<int> timesSeen,
      Value<int> timesWrong,
      Value<int?> lastCorrect,
      Value<int> inWrongList,
      Value<int?> lastAnsweredAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $QuestionProgressUpdateCompanionBuilder =
    QuestionProgressCompanion Function({
      Value<String> classCode,
      Value<String> questionKey,
      Value<int> timesSeen,
      Value<int> timesWrong,
      Value<int?> lastCorrect,
      Value<int> inWrongList,
      Value<int?> lastAnsweredAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $QuestionProgressFilterComposer
    extends Composer<_$UserDb, QuestionProgress> {
  $QuestionProgressFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesSeen => $composableBuilder(
    column: $table.timesSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesWrong => $composableBuilder(
    column: $table.timesWrong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCorrect => $composableBuilder(
    column: $table.lastCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inWrongList => $composableBuilder(
    column: $table.inWrongList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $QuestionProgressOrderingComposer
    extends Composer<_$UserDb, QuestionProgress> {
  $QuestionProgressOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesSeen => $composableBuilder(
    column: $table.timesSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesWrong => $composableBuilder(
    column: $table.timesWrong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCorrect => $composableBuilder(
    column: $table.lastCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inWrongList => $composableBuilder(
    column: $table.inWrongList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $QuestionProgressAnnotationComposer
    extends Composer<_$UserDb, QuestionProgress> {
  $QuestionProgressAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesSeen =>
      $composableBuilder(column: $table.timesSeen, builder: (column) => column);

  GeneratedColumn<int> get timesWrong => $composableBuilder(
    column: $table.timesWrong,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCorrect => $composableBuilder(
    column: $table.lastCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inWrongList => $composableBuilder(
    column: $table.inWrongList,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $QuestionProgressTableManager
    extends
        RootTableManager<
          _$UserDb,
          QuestionProgress,
          QuestionProgressData,
          $QuestionProgressFilterComposer,
          $QuestionProgressOrderingComposer,
          $QuestionProgressAnnotationComposer,
          $QuestionProgressCreateCompanionBuilder,
          $QuestionProgressUpdateCompanionBuilder,
          (
            QuestionProgressData,
            BaseReferences<_$UserDb, QuestionProgress, QuestionProgressData>,
          ),
          QuestionProgressData,
          PrefetchHooks Function()
        > {
  $QuestionProgressTableManager(_$UserDb db, QuestionProgress table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuestionProgressFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuestionProgressOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuestionProgressAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> classCode = const Value.absent(),
                Value<String> questionKey = const Value.absent(),
                Value<int> timesSeen = const Value.absent(),
                Value<int> timesWrong = const Value.absent(),
                Value<int?> lastCorrect = const Value.absent(),
                Value<int> inWrongList = const Value.absent(),
                Value<int?> lastAnsweredAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionProgressCompanion(
                classCode: classCode,
                questionKey: questionKey,
                timesSeen: timesSeen,
                timesWrong: timesWrong,
                lastCorrect: lastCorrect,
                inWrongList: inWrongList,
                lastAnsweredAt: lastAnsweredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String classCode,
                required String questionKey,
                Value<int> timesSeen = const Value.absent(),
                Value<int> timesWrong = const Value.absent(),
                Value<int?> lastCorrect = const Value.absent(),
                Value<int> inWrongList = const Value.absent(),
                Value<int?> lastAnsweredAt = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuestionProgressCompanion.insert(
                classCode: classCode,
                questionKey: questionKey,
                timesSeen: timesSeen,
                timesWrong: timesWrong,
                lastCorrect: lastCorrect,
                inWrongList: inWrongList,
                lastAnsweredAt: lastAnsweredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuestionProgress, QuestionProgressData>(table),
                  BaseReferences<
                    _$UserDb,
                    QuestionProgress,
                    QuestionProgressData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $QuestionProgressProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      QuestionProgress,
      QuestionProgressData,
      $QuestionProgressFilterComposer,
      $QuestionProgressOrderingComposer,
      $QuestionProgressAnnotationComposer,
      $QuestionProgressCreateCompanionBuilder,
      $QuestionProgressUpdateCompanionBuilder,
      (
        QuestionProgressData,
        BaseReferences<_$UserDb, QuestionProgress, QuestionProgressData>,
      ),
      QuestionProgressData,
      PrefetchHooks Function()
    >;
typedef $BookmarksCreateCompanionBuilder = BookmarksCompanion Function({
  required String questionKey,
  required int createdAt,
  Value<int> rowid,
});
typedef $BookmarksUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> questionKey,
  Value<int> createdAt,
  Value<int> rowid,
});

class $BookmarksFilterComposer extends Composer<_$UserDb, Bookmarks> {
  $BookmarksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $BookmarksOrderingComposer extends Composer<_$UserDb, Bookmarks> {
  $BookmarksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BookmarksAnnotationComposer extends Composer<_$UserDb, Bookmarks> {
  $BookmarksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $BookmarksTableManager
    extends
        RootTableManager<
          _$UserDb,
          Bookmarks,
          Bookmark,
          $BookmarksFilterComposer,
          $BookmarksOrderingComposer,
          $BookmarksAnnotationComposer,
          $BookmarksCreateCompanionBuilder,
          $BookmarksUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$UserDb, Bookmarks, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $BookmarksTableManager(_$UserDb db, Bookmarks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BookmarksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BookmarksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BookmarksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionKey = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                questionKey: questionKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionKey,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                questionKey: questionKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Bookmarks, Bookmark>(table),
                  BaseReferences<_$UserDb, Bookmarks, Bookmark>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BookmarksProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      Bookmarks,
      Bookmark,
      $BookmarksFilterComposer,
      $BookmarksOrderingComposer,
      $BookmarksAnnotationComposer,
      $BookmarksCreateCompanionBuilder,
      $BookmarksUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$UserDb, Bookmarks, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $TopicCursorCreateCompanionBuilder = TopicCursorCompanion Function({
  required String classCode,
  required int topicId,
  Value<int> position,
  required int updatedAt,
  Value<int> rowid,
});
typedef $TopicCursorUpdateCompanionBuilder = TopicCursorCompanion Function({
  Value<String> classCode,
  Value<int> topicId,
  Value<int> position,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $TopicCursorFilterComposer extends Composer<_$UserDb, TopicCursor> {
  $TopicCursorFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TopicCursorOrderingComposer extends Composer<_$UserDb, TopicCursor> {
  $TopicCursorOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TopicCursorAnnotationComposer extends Composer<_$UserDb, TopicCursor> {
  $TopicCursorAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<int> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $TopicCursorTableManager
    extends
        RootTableManager<
          _$UserDb,
          TopicCursor,
          TopicCursorData,
          $TopicCursorFilterComposer,
          $TopicCursorOrderingComposer,
          $TopicCursorAnnotationComposer,
          $TopicCursorCreateCompanionBuilder,
          $TopicCursorUpdateCompanionBuilder,
          (
            TopicCursorData,
            BaseReferences<_$UserDb, TopicCursor, TopicCursorData>,
          ),
          TopicCursorData,
          PrefetchHooks Function()
        > {
  $TopicCursorTableManager(_$UserDb db, TopicCursor table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TopicCursorFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TopicCursorOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TopicCursorAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> classCode = const Value.absent(),
                Value<int> topicId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicCursorCompanion(
                classCode: classCode,
                topicId: topicId,
                position: position,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String classCode,
                required int topicId,
                Value<int> position = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicCursorCompanion.insert(
                classCode: classCode,
                topicId: topicId,
                position: position,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TopicCursor, TopicCursorData>(table),
                  BaseReferences<_$UserDb, TopicCursor, TopicCursorData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TopicCursorProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      TopicCursor,
      TopicCursorData,
      $TopicCursorFilterComposer,
      $TopicCursorOrderingComposer,
      $TopicCursorAnnotationComposer,
      $TopicCursorCreateCompanionBuilder,
      $TopicCursorUpdateCompanionBuilder,
      (TopicCursorData, BaseReferences<_$UserDb, TopicCursor, TopicCursorData>),
      TopicCursorData,
      PrefetchHooks Function()
    >;
typedef $ExamAttemptsCreateCompanionBuilder = ExamAttemptsCompanion Function({
  Value<int> id,
  required String classCode,
  Value<int?> examSetNumber,
  required int contentVersion,
  Value<String> status,
  required int startedAt,
  required int deadlineAt,
  Value<int?> finishedAt,
  required int questionCount,
  required int passMark,
  Value<int?> score,
  Value<int?> passed,
  Value<int?> failedOnCritical,
});
typedef $ExamAttemptsUpdateCompanionBuilder = ExamAttemptsCompanion Function({
  Value<int> id,
  Value<String> classCode,
  Value<int?> examSetNumber,
  Value<int> contentVersion,
  Value<String> status,
  Value<int> startedAt,
  Value<int> deadlineAt,
  Value<int?> finishedAt,
  Value<int> questionCount,
  Value<int> passMark,
  Value<int?> score,
  Value<int?> passed,
  Value<int?> failedOnCritical,
});

final class $ExamAttemptsReferences
    extends BaseReferences<_$UserDb, ExamAttempts, ExamAttempt> {
  $ExamAttemptsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<AttemptAnswers, List<AttemptAnswer>>
  _attemptAnswersRefsTable(_$UserDb db) => MultiTypedResultKey.fromTable(
    db.attemptAnswers,
    aliasName: 'exam_attempts__id__attempt_answers__attempt_id',
  );

  $AttemptAnswersProcessedTableManager get attemptAnswersRefs {
    final manager = $AttemptAnswersTableManager(
      $_db,
      $_db.attemptAnswers,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptAnswersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ExamAttemptsFilterComposer extends Composer<_$UserDb, ExamAttempts> {
  $ExamAttemptsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get examSetNumber => $composableBuilder(
    column: $table.examSetNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedOnCritical => $composableBuilder(
    column: $table.failedOnCritical,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attemptAnswersRefs(
    Expression<bool> Function($AttemptAnswersFilterComposer f) f,
  ) {
    final $AttemptAnswersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttemptAnswersFilterComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ExamAttemptsOrderingComposer extends Composer<_$UserDb, ExamAttempts> {
  $ExamAttemptsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get examSetNumber => $composableBuilder(
    column: $table.examSetNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passed => $composableBuilder(
    column: $table.passed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedOnCritical => $composableBuilder(
    column: $table.failedOnCritical,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ExamAttemptsAnnotationComposer extends Composer<_$UserDb, ExamAttempts> {
  $ExamAttemptsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<int> get examSetNumber => $composableBuilder(
    column: $table.examSetNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passMark =>
      $composableBuilder(column: $table.passMark, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get passed =>
      $composableBuilder(column: $table.passed, builder: (column) => column);

  GeneratedColumn<int> get failedOnCritical => $composableBuilder(
    column: $table.failedOnCritical,
    builder: (column) => column,
  );

  Expression<T> attemptAnswersRefs<T extends Object>(
    Expression<T> Function($AttemptAnswersAnnotationComposer a) f,
  ) {
    final $AttemptAnswersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttemptAnswersAnnotationComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ExamAttemptsTableManager
    extends
        RootTableManager<
          _$UserDb,
          ExamAttempts,
          ExamAttempt,
          $ExamAttemptsFilterComposer,
          $ExamAttemptsOrderingComposer,
          $ExamAttemptsAnnotationComposer,
          $ExamAttemptsCreateCompanionBuilder,
          $ExamAttemptsUpdateCompanionBuilder,
          (ExamAttempt, $ExamAttemptsReferences),
          ExamAttempt,
          PrefetchHooks Function({bool attemptAnswersRefs})
        > {
  $ExamAttemptsTableManager(_$UserDb db, ExamAttempts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ExamAttemptsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ExamAttemptsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ExamAttemptsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> classCode = const Value.absent(),
                Value<int?> examSetNumber = const Value.absent(),
                Value<int> contentVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> deadlineAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> passMark = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int?> passed = const Value.absent(),
                Value<int?> failedOnCritical = const Value.absent(),
              }) => ExamAttemptsCompanion(
                id: id,
                classCode: classCode,
                examSetNumber: examSetNumber,
                contentVersion: contentVersion,
                status: status,
                startedAt: startedAt,
                deadlineAt: deadlineAt,
                finishedAt: finishedAt,
                questionCount: questionCount,
                passMark: passMark,
                score: score,
                passed: passed,
                failedOnCritical: failedOnCritical,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String classCode,
                Value<int?> examSetNumber = const Value.absent(),
                required int contentVersion,
                Value<String> status = const Value.absent(),
                required int startedAt,
                required int deadlineAt,
                Value<int?> finishedAt = const Value.absent(),
                required int questionCount,
                required int passMark,
                Value<int?> score = const Value.absent(),
                Value<int?> passed = const Value.absent(),
                Value<int?> failedOnCritical = const Value.absent(),
              }) => ExamAttemptsCompanion.insert(
                id: id,
                classCode: classCode,
                examSetNumber: examSetNumber,
                contentVersion: contentVersion,
                status: status,
                startedAt: startedAt,
                deadlineAt: deadlineAt,
                finishedAt: finishedAt,
                questionCount: questionCount,
                passMark: passMark,
                score: score,
                passed: passed,
                failedOnCritical: failedOnCritical,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ExamAttempts, ExamAttempt>(table),
                  $ExamAttemptsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attemptAnswersRefs) db.attemptAnswers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attemptAnswersRefs)
                    await $_getPrefetchedDataByColumns<
                      ExamAttempt,
                      ExamAttempts,
                      AttemptAnswer,
                      AttemptAnswers
                    >(
                      currentTable: table,
                      referencedTable: $ExamAttemptsReferences
                          ._attemptAnswersRefsTable(db),
                      managerFromTypedResult: (p0) => $ExamAttemptsReferences(
                        db,
                        table,
                        p0,
                      ).attemptAnswersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'attempt_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ExamAttemptsProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      ExamAttempts,
      ExamAttempt,
      $ExamAttemptsFilterComposer,
      $ExamAttemptsOrderingComposer,
      $ExamAttemptsAnnotationComposer,
      $ExamAttemptsCreateCompanionBuilder,
      $ExamAttemptsUpdateCompanionBuilder,
      (ExamAttempt, $ExamAttemptsReferences),
      ExamAttempt,
      PrefetchHooks Function({bool attemptAnswersRefs})
    >;
typedef $AttemptAnswersCreateCompanionBuilder =
    AttemptAnswersCompanion Function({
      required int attemptId,
      required int position,
      required String questionKey,
      required int isCritical,
      Value<int?> chosenPosition,
      Value<int?> isCorrect,
      Value<int?> answeredAt,
      Value<int> rowid,
    });
typedef $AttemptAnswersUpdateCompanionBuilder =
    AttemptAnswersCompanion Function({
      Value<int> attemptId,
      Value<int> position,
      Value<String> questionKey,
      Value<int> isCritical,
      Value<int?> chosenPosition,
      Value<int?> isCorrect,
      Value<int?> answeredAt,
      Value<int> rowid,
    });

final class $AttemptAnswersReferences
    extends BaseReferences<_$UserDb, AttemptAnswers, AttemptAnswer> {
  $AttemptAnswersReferences(super.$_db, super.$_table, super.$_typedResult);

  static ExamAttempts _attemptIdTable(_$UserDb db) => db.examAttempts
      .createAlias('attempt_answers__attempt_id__exam_attempts__id');

  $ExamAttemptsProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $ExamAttemptsTableManager(
      $_db,
      $_db.examAttempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $AttemptAnswersFilterComposer extends Composer<_$UserDb, AttemptAnswers> {
  $AttemptAnswersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chosenPosition => $composableBuilder(
    column: $table.chosenPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $ExamAttemptsFilterComposer get attemptId {
    final $ExamAttemptsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.examAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExamAttemptsFilterComposer(
            $db: $db,
            $table: $db.examAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttemptAnswersOrderingComposer
    extends Composer<_$UserDb, AttemptAnswers> {
  $AttemptAnswersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chosenPosition => $composableBuilder(
    column: $table.chosenPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ExamAttemptsOrderingComposer get attemptId {
    final $ExamAttemptsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.examAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExamAttemptsOrderingComposer(
            $db: $db,
            $table: $db.examAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttemptAnswersAnnotationComposer
    extends Composer<_$UserDb, AttemptAnswers> {
  $AttemptAnswersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get questionKey => $composableBuilder(
    column: $table.questionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chosenPosition => $composableBuilder(
    column: $table.chosenPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $ExamAttemptsAnnotationComposer get attemptId {
    final $ExamAttemptsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.examAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExamAttemptsAnnotationComposer(
            $db: $db,
            $table: $db.examAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttemptAnswersTableManager
    extends
        RootTableManager<
          _$UserDb,
          AttemptAnswers,
          AttemptAnswer,
          $AttemptAnswersFilterComposer,
          $AttemptAnswersOrderingComposer,
          $AttemptAnswersAnnotationComposer,
          $AttemptAnswersCreateCompanionBuilder,
          $AttemptAnswersUpdateCompanionBuilder,
          (AttemptAnswer, $AttemptAnswersReferences),
          AttemptAnswer,
          PrefetchHooks Function({bool attemptId})
        > {
  $AttemptAnswersTableManager(_$UserDb db, AttemptAnswers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AttemptAnswersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AttemptAnswersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AttemptAnswersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> attemptId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> questionKey = const Value.absent(),
                Value<int> isCritical = const Value.absent(),
                Value<int?> chosenPosition = const Value.absent(),
                Value<int?> isCorrect = const Value.absent(),
                Value<int?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptAnswersCompanion(
                attemptId: attemptId,
                position: position,
                questionKey: questionKey,
                isCritical: isCritical,
                chosenPosition: chosenPosition,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int attemptId,
                required int position,
                required String questionKey,
                required int isCritical,
                Value<int?> chosenPosition = const Value.absent(),
                Value<int?> isCorrect = const Value.absent(),
                Value<int?> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptAnswersCompanion.insert(
                attemptId: attemptId,
                position: position,
                questionKey: questionKey,
                isCritical: isCritical,
                chosenPosition: chosenPosition,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AttemptAnswers, AttemptAnswer>(table),
                  $AttemptAnswersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attemptId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attemptId,
                        referencedTable: $AttemptAnswersReferences
                            ._attemptIdTable(db),
                        referencedColumn: $AttemptAnswersReferences
                            ._attemptIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $AttemptAnswersProcessedTableManager =
    ProcessedTableManager<
      _$UserDb,
      AttemptAnswers,
      AttemptAnswer,
      $AttemptAnswersFilterComposer,
      $AttemptAnswersOrderingComposer,
      $AttemptAnswersAnnotationComposer,
      $AttemptAnswersCreateCompanionBuilder,
      $AttemptAnswersUpdateCompanionBuilder,
      (AttemptAnswer, $AttemptAnswersReferences),
      AttemptAnswer,
      PrefetchHooks Function({bool attemptId})
    >;

class $UserDbManager {
  final _$UserDb _db;
  $UserDbManager(this._db);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
  $QuestionProgressTableManager get questionProgress =>
      $QuestionProgressTableManager(_db, _db.questionProgress);
  $BookmarksTableManager get bookmarks =>
      $BookmarksTableManager(_db, _db.bookmarks);
  $TopicCursorTableManager get topicCursor =>
      $TopicCursorTableManager(_db, _db.topicCursor);
  $ExamAttemptsTableManager get examAttempts =>
      $ExamAttemptsTableManager(_db, _db.examAttempts);
  $AttemptAnswersTableManager get attemptAnswers =>
      $AttemptAnswersTableManager(_db, _db.attemptAnswers);
}
