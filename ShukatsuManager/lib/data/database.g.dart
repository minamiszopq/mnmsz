// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $StatusesTable extends Statuses with TableInfo<$StatusesTable, Status> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatusCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StatusCategory>($StatusesTable.$convertercategory);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, category, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Status> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Status map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Status(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $StatusesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $StatusesTable createAlias(String alias) {
    return $StatusesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatusCategory, int, int> $convertercategory =
      const EnumIndexConverter<StatusCategory>(StatusCategory.values);
}

class Status extends DataClass implements Insertable<Status> {
  final int id;
  final String name;
  final StatusCategory category;
  final int sortOrder;
  const Status({
    required this.id,
    required this.name,
    required this.category,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<int>(
        $StatusesTable.$convertercategory.toSql(category),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  StatusesCompanion toCompanion(bool nullToAbsent) {
    return StatusesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      sortOrder: Value(sortOrder),
    );
  }

  factory Status.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Status(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $StatusesTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<int>(
        $StatusesTable.$convertercategory.toJson(category),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Status copyWith({
    int? id,
    String? name,
    StatusCategory? category,
    int? sortOrder,
  }) => Status(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Status copyWithCompanion(StatusesCompanion data) {
    return Status(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Status(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Status &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.sortOrder == this.sortOrder);
}

class StatusesCompanion extends UpdateCompanion<Status> {
  final Value<int> id;
  final Value<String> name;
  final Value<StatusCategory> category;
  final Value<int> sortOrder;
  const StatusesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  StatusesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required StatusCategory category,
    required int sortOrder,
  }) : name = Value(name),
       category = Value(category),
       sortOrder = Value(sortOrder);
  static Insertable<Status> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? category,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  StatusesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<StatusCategory>? category,
    Value<int>? sortOrder,
  }) {
    return StatusesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $StatusesTable.$convertercategory.toSql(category.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatusesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $IndustriesTable extends Industries
    with TableInfo<$IndustriesTable, Industry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndustriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'industries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Industry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Industry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Industry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $IndustriesTable createAlias(String alias) {
    return $IndustriesTable(attachedDatabase, alias);
  }
}

class Industry extends DataClass implements Insertable<Industry> {
  final int id;
  final String name;

  /// v2 で追加
  final int sortOrder;
  const Industry({
    required this.id,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  IndustriesCompanion toCompanion(bool nullToAbsent) {
    return IndustriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Industry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Industry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Industry copyWith({int? id, String? name, int? sortOrder}) => Industry(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Industry copyWithCompanion(IndustriesCompanion data) {
    return Industry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Industry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Industry &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class IndustriesCompanion extends UpdateCompanion<Industry> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  const IndustriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  IndustriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Industry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  IndustriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return IndustriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndustriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusIdMeta = const VerificationMeta(
    'statusId',
  );
  @override
  late final GeneratedColumn<int> statusId = GeneratedColumn<int>(
    'status_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES statuses (id)',
    ),
  );
  static const VerificationMeta _mypageIdMeta = const VerificationMeta(
    'mypageId',
  );
  @override
  late final GeneratedColumn<String> mypageId = GeneratedColumn<String>(
    'mypage_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mypageUrlMeta = const VerificationMeta(
    'mypageUrl',
  );
  @override
  late final GeneratedColumn<String> mypageUrl = GeneratedColumn<String>(
    'mypage_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _useCustomRemindersMeta =
      const VerificationMeta('useCustomReminders');
  @override
  late final GeneratedColumn<bool> useCustomReminders = GeneratedColumn<bool>(
    'use_custom_reminders',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_custom_reminders" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    statusId,
    mypageId,
    mypageUrl,
    useCustomReminders,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status_id')) {
      context.handle(
        _statusIdMeta,
        statusId.isAcceptableOrUnknown(data['status_id']!, _statusIdMeta),
      );
    } else if (isInserting) {
      context.missing(_statusIdMeta);
    }
    if (data.containsKey('mypage_id')) {
      context.handle(
        _mypageIdMeta,
        mypageId.isAcceptableOrUnknown(data['mypage_id']!, _mypageIdMeta),
      );
    }
    if (data.containsKey('mypage_url')) {
      context.handle(
        _mypageUrlMeta,
        mypageUrl.isAcceptableOrUnknown(data['mypage_url']!, _mypageUrlMeta),
      );
    }
    if (data.containsKey('use_custom_reminders')) {
      context.handle(
        _useCustomRemindersMeta,
        useCustomReminders.isAcceptableOrUnknown(
          data['use_custom_reminders']!,
          _useCustomRemindersMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      statusId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_id'],
      )!,
      mypageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mypage_id'],
      ),
      mypageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mypage_url'],
      ),
      useCustomReminders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_custom_reminders'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final int id;
  final String name;
  final int statusId;
  final String? mypageId;
  final String? mypageUrl;

  /// true のとき CompanyReminders を全体設定より優先する
  final bool useCustomReminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Undo 用のソフトデリート。一定時間後に物理削除する。
  final DateTime? deletedAt;
  const Company({
    required this.id,
    required this.name,
    required this.statusId,
    this.mypageId,
    this.mypageUrl,
    required this.useCustomReminders,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['status_id'] = Variable<int>(statusId);
    if (!nullToAbsent || mypageId != null) {
      map['mypage_id'] = Variable<String>(mypageId);
    }
    if (!nullToAbsent || mypageUrl != null) {
      map['mypage_url'] = Variable<String>(mypageUrl);
    }
    map['use_custom_reminders'] = Variable<bool>(useCustomReminders);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      statusId: Value(statusId),
      mypageId: mypageId == null && nullToAbsent
          ? const Value.absent()
          : Value(mypageId),
      mypageUrl: mypageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mypageUrl),
      useCustomReminders: Value(useCustomReminders),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      statusId: serializer.fromJson<int>(json['statusId']),
      mypageId: serializer.fromJson<String?>(json['mypageId']),
      mypageUrl: serializer.fromJson<String?>(json['mypageUrl']),
      useCustomReminders: serializer.fromJson<bool>(json['useCustomReminders']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'statusId': serializer.toJson<int>(statusId),
      'mypageId': serializer.toJson<String?>(mypageId),
      'mypageUrl': serializer.toJson<String?>(mypageUrl),
      'useCustomReminders': serializer.toJson<bool>(useCustomReminders),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    int? statusId,
    Value<String?> mypageId = const Value.absent(),
    Value<String?> mypageUrl = const Value.absent(),
    bool? useCustomReminders,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Company(
    id: id ?? this.id,
    name: name ?? this.name,
    statusId: statusId ?? this.statusId,
    mypageId: mypageId.present ? mypageId.value : this.mypageId,
    mypageUrl: mypageUrl.present ? mypageUrl.value : this.mypageUrl,
    useCustomReminders: useCustomReminders ?? this.useCustomReminders,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      statusId: data.statusId.present ? data.statusId.value : this.statusId,
      mypageId: data.mypageId.present ? data.mypageId.value : this.mypageId,
      mypageUrl: data.mypageUrl.present ? data.mypageUrl.value : this.mypageUrl,
      useCustomReminders: data.useCustomReminders.present
          ? data.useCustomReminders.value
          : this.useCustomReminders,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('statusId: $statusId, ')
          ..write('mypageId: $mypageId, ')
          ..write('mypageUrl: $mypageUrl, ')
          ..write('useCustomReminders: $useCustomReminders, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    statusId,
    mypageId,
    mypageUrl,
    useCustomReminders,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.name == this.name &&
          other.statusId == this.statusId &&
          other.mypageId == this.mypageId &&
          other.mypageUrl == this.mypageUrl &&
          other.useCustomReminders == this.useCustomReminders &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> statusId;
  final Value<String?> mypageId;
  final Value<String?> mypageUrl;
  final Value<bool> useCustomReminders;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.statusId = const Value.absent(),
    this.mypageId = const Value.absent(),
    this.mypageUrl = const Value.absent(),
    this.useCustomReminders = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CompaniesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int statusId,
    this.mypageId = const Value.absent(),
    this.mypageUrl = const Value.absent(),
    this.useCustomReminders = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       statusId = Value(statusId);
  static Insertable<Company> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? statusId,
    Expression<String>? mypageId,
    Expression<String>? mypageUrl,
    Expression<bool>? useCustomReminders,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (statusId != null) 'status_id': statusId,
      if (mypageId != null) 'mypage_id': mypageId,
      if (mypageUrl != null) 'mypage_url': mypageUrl,
      if (useCustomReminders != null)
        'use_custom_reminders': useCustomReminders,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  CompaniesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? statusId,
    Value<String?>? mypageId,
    Value<String?>? mypageUrl,
    Value<bool>? useCustomReminders,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      statusId: statusId ?? this.statusId,
      mypageId: mypageId ?? this.mypageId,
      mypageUrl: mypageUrl ?? this.mypageUrl,
      useCustomReminders: useCustomReminders ?? this.useCustomReminders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (statusId.present) {
      map['status_id'] = Variable<int>(statusId.value);
    }
    if (mypageId.present) {
      map['mypage_id'] = Variable<String>(mypageId.value);
    }
    if (mypageUrl.present) {
      map['mypage_url'] = Variable<String>(mypageUrl.value);
    }
    if (useCustomReminders.present) {
      map['use_custom_reminders'] = Variable<bool>(useCustomReminders.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('statusId: $statusId, ')
          ..write('mypageId: $mypageId, ')
          ..write('mypageUrl: $mypageUrl, ')
          ..write('useCustomReminders: $useCustomReminders, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $CompanyIndustriesTable extends CompanyIndustries
    with TableInfo<$CompanyIndustriesTable, CompanyIndustry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyIndustriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _industryIdMeta = const VerificationMeta(
    'industryId',
  );
  @override
  late final GeneratedColumn<int> industryId = GeneratedColumn<int>(
    'industry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES industries (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [companyId, industryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_industries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyIndustry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('industry_id')) {
      context.handle(
        _industryIdMeta,
        industryId.isAcceptableOrUnknown(data['industry_id']!, _industryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_industryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {companyId, industryId};
  @override
  CompanyIndustry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyIndustry(
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      industryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}industry_id'],
      )!,
    );
  }

  @override
  $CompanyIndustriesTable createAlias(String alias) {
    return $CompanyIndustriesTable(attachedDatabase, alias);
  }
}

class CompanyIndustry extends DataClass implements Insertable<CompanyIndustry> {
  final int companyId;
  final int industryId;
  const CompanyIndustry({required this.companyId, required this.industryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['company_id'] = Variable<int>(companyId);
    map['industry_id'] = Variable<int>(industryId);
    return map;
  }

  CompanyIndustriesCompanion toCompanion(bool nullToAbsent) {
    return CompanyIndustriesCompanion(
      companyId: Value(companyId),
      industryId: Value(industryId),
    );
  }

  factory CompanyIndustry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyIndustry(
      companyId: serializer.fromJson<int>(json['companyId']),
      industryId: serializer.fromJson<int>(json['industryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companyId': serializer.toJson<int>(companyId),
      'industryId': serializer.toJson<int>(industryId),
    };
  }

  CompanyIndustry copyWith({int? companyId, int? industryId}) =>
      CompanyIndustry(
        companyId: companyId ?? this.companyId,
        industryId: industryId ?? this.industryId,
      );
  CompanyIndustry copyWithCompanion(CompanyIndustriesCompanion data) {
    return CompanyIndustry(
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      industryId: data.industryId.present
          ? data.industryId.value
          : this.industryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyIndustry(')
          ..write('companyId: $companyId, ')
          ..write('industryId: $industryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(companyId, industryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyIndustry &&
          other.companyId == this.companyId &&
          other.industryId == this.industryId);
}

class CompanyIndustriesCompanion extends UpdateCompanion<CompanyIndustry> {
  final Value<int> companyId;
  final Value<int> industryId;
  final Value<int> rowid;
  const CompanyIndustriesCompanion({
    this.companyId = const Value.absent(),
    this.industryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyIndustriesCompanion.insert({
    required int companyId,
    required int industryId,
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       industryId = Value(industryId);
  static Insertable<CompanyIndustry> custom({
    Expression<int>? companyId,
    Expression<int>? industryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (companyId != null) 'company_id': companyId,
      if (industryId != null) 'industry_id': industryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyIndustriesCompanion copyWith({
    Value<int>? companyId,
    Value<int>? industryId,
    Value<int>? rowid,
  }) {
    return CompanyIndustriesCompanion(
      companyId: companyId ?? this.companyId,
      industryId: industryId ?? this.industryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (industryId.present) {
      map['industry_id'] = Variable<int>(industryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyIndustriesCompanion(')
          ..write('companyId: $companyId, ')
          ..write('industryId: $industryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EventType>($EventsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, companyId, type, title, startsAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      type: $EventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EventType, int, int> $convertertype =
      const EnumIndexConverter<EventType>(EventType.values);
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final int companyId;
  final EventType type;
  final String? title;
  final DateTime startsAt;
  const Event({
    required this.id,
    required this.companyId,
    required this.type,
    this.title,
    required this.startsAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    {
      map['type'] = Variable<int>($EventsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['starts_at'] = Variable<DateTime>(startsAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      startsAt: Value(startsAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      type: $EventsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      title: serializer.fromJson<String?>(json['title']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'type': serializer.toJson<int>($EventsTable.$convertertype.toJson(type)),
      'title': serializer.toJson<String?>(title),
      'startsAt': serializer.toJson<DateTime>(startsAt),
    };
  }

  Event copyWith({
    int? id,
    int? companyId,
    EventType? type,
    Value<String?> title = const Value.absent(),
    DateTime? startsAt,
  }) => Event(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    startsAt: startsAt ?? this.startsAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('startsAt: $startsAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, companyId, type, title, startsAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.type == this.type &&
          other.title == this.title &&
          other.startsAt == this.startsAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<EventType> type;
  final Value<String?> title;
  final Value<DateTime> startsAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.startsAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required EventType type,
    this.title = const Value.absent(),
    required DateTime startsAt,
  }) : companyId = Value(companyId),
       type = Value(type),
       startsAt = Value(startsAt);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? type,
    Expression<String>? title,
    Expression<DateTime>? startsAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (startsAt != null) 'starts_at': startsAt,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<EventType>? type,
    Value<String?>? title,
    Value<DateTime>? startsAt,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $EventsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('startsAt: $startsAt')
          ..write(')'))
        .toString();
  }
}

class $CompanyRemindersTable extends CompanyReminders
    with TableInfo<$CompanyRemindersTable, CompanyReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _minutesBeforeMeta = const VerificationMeta(
    'minutesBefore',
  );
  @override
  late final GeneratedColumn<int> minutesBefore = GeneratedColumn<int>(
    'minutes_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [companyId, minutesBefore];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('minutes_before')) {
      context.handle(
        _minutesBeforeMeta,
        minutesBefore.isAcceptableOrUnknown(
          data['minutes_before']!,
          _minutesBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minutesBeforeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {companyId, minutesBefore};
  @override
  CompanyReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyReminder(
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      minutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_before'],
      )!,
    );
  }

  @override
  $CompanyRemindersTable createAlias(String alias) {
    return $CompanyRemindersTable(attachedDatabase, alias);
  }
}

class CompanyReminder extends DataClass implements Insertable<CompanyReminder> {
  final int companyId;
  final int minutesBefore;
  const CompanyReminder({required this.companyId, required this.minutesBefore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['company_id'] = Variable<int>(companyId);
    map['minutes_before'] = Variable<int>(minutesBefore);
    return map;
  }

  CompanyRemindersCompanion toCompanion(bool nullToAbsent) {
    return CompanyRemindersCompanion(
      companyId: Value(companyId),
      minutesBefore: Value(minutesBefore),
    );
  }

  factory CompanyReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyReminder(
      companyId: serializer.fromJson<int>(json['companyId']),
      minutesBefore: serializer.fromJson<int>(json['minutesBefore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'companyId': serializer.toJson<int>(companyId),
      'minutesBefore': serializer.toJson<int>(minutesBefore),
    };
  }

  CompanyReminder copyWith({int? companyId, int? minutesBefore}) =>
      CompanyReminder(
        companyId: companyId ?? this.companyId,
        minutesBefore: minutesBefore ?? this.minutesBefore,
      );
  CompanyReminder copyWithCompanion(CompanyRemindersCompanion data) {
    return CompanyReminder(
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      minutesBefore: data.minutesBefore.present
          ? data.minutesBefore.value
          : this.minutesBefore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyReminder(')
          ..write('companyId: $companyId, ')
          ..write('minutesBefore: $minutesBefore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(companyId, minutesBefore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyReminder &&
          other.companyId == this.companyId &&
          other.minutesBefore == this.minutesBefore);
}

class CompanyRemindersCompanion extends UpdateCompanion<CompanyReminder> {
  final Value<int> companyId;
  final Value<int> minutesBefore;
  final Value<int> rowid;
  const CompanyRemindersCompanion({
    this.companyId = const Value.absent(),
    this.minutesBefore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyRemindersCompanion.insert({
    required int companyId,
    required int minutesBefore,
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       minutesBefore = Value(minutesBefore);
  static Insertable<CompanyReminder> custom({
    Expression<int>? companyId,
    Expression<int>? minutesBefore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (companyId != null) 'company_id': companyId,
      if (minutesBefore != null) 'minutes_before': minutesBefore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyRemindersCompanion copyWith({
    Value<int>? companyId,
    Value<int>? minutesBefore,
    Value<int>? rowid,
  }) {
    return CompanyRemindersCompanion(
      companyId: companyId ?? this.companyId,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (minutesBefore.present) {
      map['minutes_before'] = Variable<int>(minutesBefore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyRemindersCompanion(')
          ..write('companyId: $companyId, ')
          ..write('minutesBefore: $minutesBefore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogsTable extends Logs with TableInfo<$LogsTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<int> companyId = GeneratedColumn<int>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<LogKind>($LogsTable.$converterkind);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fromStatusMeta = const VerificationMeta(
    'fromStatus',
  );
  @override
  late final GeneratedColumn<String> fromStatus = GeneratedColumn<String>(
    'from_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toStatusMeta = const VerificationMeta(
    'toStatus',
  );
  @override
  late final GeneratedColumn<String> toStatus = GeneratedColumn<String>(
    'to_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    kind,
    body,
    fromStatus,
    toStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Log> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('from_status')) {
      context.handle(
        _fromStatusMeta,
        fromStatus.isAcceptableOrUnknown(data['from_status']!, _fromStatusMeta),
      );
    }
    if (data.containsKey('to_status')) {
      context.handle(
        _toStatusMeta,
        toStatus.isAcceptableOrUnknown(data['to_status']!, _toStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}company_id'],
      )!,
      kind: $LogsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      fromStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_status'],
      ),
      toStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_status'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogKind, int, int> $converterkind =
      const EnumIndexConverter<LogKind>(LogKind.values);
}

class Log extends DataClass implements Insertable<Log> {
  final int id;
  final int companyId;
  final LogKind kind;
  final String body;

  /// 状態名はマスタ変更・削除後も読めるよう文字列で保持する
  final String? fromStatus;
  final String? toStatus;
  final DateTime createdAt;
  const Log({
    required this.id,
    required this.companyId,
    required this.kind,
    required this.body,
    this.fromStatus,
    this.toStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['company_id'] = Variable<int>(companyId);
    {
      map['kind'] = Variable<int>($LogsTable.$converterkind.toSql(kind));
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || fromStatus != null) {
      map['from_status'] = Variable<String>(fromStatus);
    }
    if (!nullToAbsent || toStatus != null) {
      map['to_status'] = Variable<String>(toStatus);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      kind: Value(kind),
      body: Value(body),
      fromStatus: fromStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fromStatus),
      toStatus: toStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(toStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Log.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<int>(json['id']),
      companyId: serializer.fromJson<int>(json['companyId']),
      kind: $LogsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      body: serializer.fromJson<String>(json['body']),
      fromStatus: serializer.fromJson<String?>(json['fromStatus']),
      toStatus: serializer.fromJson<String?>(json['toStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'companyId': serializer.toJson<int>(companyId),
      'kind': serializer.toJson<int>($LogsTable.$converterkind.toJson(kind)),
      'body': serializer.toJson<String>(body),
      'fromStatus': serializer.toJson<String?>(fromStatus),
      'toStatus': serializer.toJson<String?>(toStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Log copyWith({
    int? id,
    int? companyId,
    LogKind? kind,
    String? body,
    Value<String?> fromStatus = const Value.absent(),
    Value<String?> toStatus = const Value.absent(),
    DateTime? createdAt,
  }) => Log(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    kind: kind ?? this.kind,
    body: body ?? this.body,
    fromStatus: fromStatus.present ? fromStatus.value : this.fromStatus,
    toStatus: toStatus.present ? toStatus.value : this.toStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  Log copyWithCompanion(LogsCompanion data) {
    return Log(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, kind, body, fromStatus, toStatus, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.createdAt == this.createdAt);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<int> id;
  final Value<int> companyId;
  final Value<LogKind> kind;
  final Value<String> body;
  final Value<String?> fromStatus;
  final Value<String?> toStatus;
  final Value<DateTime> createdAt;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogsCompanion.insert({
    this.id = const Value.absent(),
    required int companyId,
    required LogKind kind,
    this.body = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : companyId = Value(companyId),
       kind = Value(kind);
  static Insertable<Log> custom({
    Expression<int>? id,
    Expression<int>? companyId,
    Expression<int>? kind,
    Expression<String>? body,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogsCompanion copyWith({
    Value<int>? id,
    Value<int>? companyId,
    Value<LogKind>? kind,
    Value<String>? body,
    Value<String?>? fromStatus,
    Value<String?>? toStatus,
    Value<DateTime>? createdAt,
  }) {
    return LogsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<int>(companyId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($LogsTable.$converterkind.toSql(kind.value));
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(fromStatus.value);
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(toStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StatusesTable statuses = $StatusesTable(this);
  late final $IndustriesTable industries = $IndustriesTable(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $CompanyIndustriesTable companyIndustries =
      $CompanyIndustriesTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $CompanyRemindersTable companyReminders = $CompanyRemindersTable(
    this,
  );
  late final $LogsTable logs = $LogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    statuses,
    industries,
    companies,
    companyIndustries,
    events,
    companyReminders,
    logs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('company_industries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'industries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('company_industries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('company_reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$StatusesTableCreateCompanionBuilder = StatusesCompanion Function({
  Value<int> id,
  required String name,
  required StatusCategory category,
  required int sortOrder,
});
typedef $$StatusesTableUpdateCompanionBuilder = StatusesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<StatusCategory> category,
  Value<int> sortOrder,
});

final class $$StatusesTableReferences
    extends BaseReferences<_$AppDatabase, $StatusesTable, Status> {
  $$StatusesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompaniesTable, List<Company>>
  _companiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companies,
    aliasName: 'statuses__id__companies__status_id',
  );

  $$CompaniesTableProcessedTableManager get companiesRefs {
    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.statusId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_companiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StatusesTableFilterComposer
    extends Composer<_$AppDatabase, $StatusesTable> {
  $$StatusesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusCategory, StatusCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> companiesRefs(
    Expression<bool> Function($$CompaniesTableFilterComposer f) f,
  ) {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.statusId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $StatusesTable> {
  $$StatusesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatusesTable> {
  $$StatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StatusCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> companiesRefs<T extends Object>(
    Expression<T> Function($$CompaniesTableAnnotationComposer a) f,
  ) {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.statusId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatusesTable,
          Status,
          $$StatusesTableFilterComposer,
          $$StatusesTableOrderingComposer,
          $$StatusesTableAnnotationComposer,
          $$StatusesTableCreateCompanionBuilder,
          $$StatusesTableUpdateCompanionBuilder,
          (Status, $$StatusesTableReferences),
          Status,
          PrefetchHooks Function({bool companiesRefs})
        > {
  $$StatusesTableTableManager(_$AppDatabase db, $StatusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<StatusCategory> category = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => StatusesCompanion(
                id: id,
                name: name,
                category: category,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required StatusCategory category,
                required int sortOrder,
              }) => StatusesCompanion.insert(
                id: id,
                name: name,
                category: category,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StatusesTable, Status>(table),
                  $$StatusesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (companiesRefs) db.companies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (companiesRefs)
                    await $_getPrefetchedData<Status, $StatusesTable, Company>(
                      currentTable: table,
                      referencedTable: $$StatusesTableReferences
                          ._companiesRefsTable(db),
                      managerFromTypedResult: (p0) => $$StatusesTableReferences(
                        db,
                        table,
                        p0,
                      ).companiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.statusId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatusesTable,
      Status,
      $$StatusesTableFilterComposer,
      $$StatusesTableOrderingComposer,
      $$StatusesTableAnnotationComposer,
      $$StatusesTableCreateCompanionBuilder,
      $$StatusesTableUpdateCompanionBuilder,
      (Status, $$StatusesTableReferences),
      Status,
      PrefetchHooks Function({bool companiesRefs})
    >;
typedef $$IndustriesTableCreateCompanionBuilder = IndustriesCompanion Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
});
typedef $$IndustriesTableUpdateCompanionBuilder = IndustriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
});

final class $$IndustriesTableReferences
    extends BaseReferences<_$AppDatabase, $IndustriesTable, Industry> {
  $$IndustriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompanyIndustriesTable, List<CompanyIndustry>>
  _companyIndustriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.companyIndustries,
        aliasName: 'industries__id__company_industries__industry_id',
      );

  $$CompanyIndustriesTableProcessedTableManager get companyIndustriesRefs {
    final manager = $$CompanyIndustriesTableTableManager(
      $_db,
      $_db.companyIndustries,
    ).filter((f) => f.industryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companyIndustriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IndustriesTableFilterComposer
    extends Composer<_$AppDatabase, $IndustriesTable> {
  $$IndustriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> companyIndustriesRefs(
    Expression<bool> Function($$CompanyIndustriesTableFilterComposer f) f,
  ) {
    final $$CompanyIndustriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyIndustries,
      getReferencedColumn: (t) => t.industryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyIndustriesTableFilterComposer(
            $db: $db,
            $table: $db.companyIndustries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IndustriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IndustriesTable> {
  $$IndustriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IndustriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IndustriesTable> {
  $$IndustriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> companyIndustriesRefs<T extends Object>(
    Expression<T> Function($$CompanyIndustriesTableAnnotationComposer a) f,
  ) {
    final $$CompanyIndustriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.companyIndustries,
          getReferencedColumn: (t) => t.industryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyIndustriesTableAnnotationComposer(
                $db: $db,
                $table: $db.companyIndustries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IndustriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IndustriesTable,
          Industry,
          $$IndustriesTableFilterComposer,
          $$IndustriesTableOrderingComposer,
          $$IndustriesTableAnnotationComposer,
          $$IndustriesTableCreateCompanionBuilder,
          $$IndustriesTableUpdateCompanionBuilder,
          (Industry, $$IndustriesTableReferences),
          Industry,
          PrefetchHooks Function({bool companyIndustriesRefs})
        > {
  $$IndustriesTableTableManager(_$AppDatabase db, $IndustriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IndustriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IndustriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IndustriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) => IndustriesCompanion(id: id, name: name, sortOrder: sortOrder),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => IndustriesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IndustriesTable, Industry>(table),
                  $$IndustriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyIndustriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (companyIndustriesRefs) db.companyIndustries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (companyIndustriesRefs)
                    await $_getPrefetchedData<
                      Industry,
                      $IndustriesTable,
                      CompanyIndustry
                    >(
                      currentTable: table,
                      referencedTable: $$IndustriesTableReferences
                          ._companyIndustriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IndustriesTableReferences(
                            db,
                            table,
                            p0,
                          ).companyIndustriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.industryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IndustriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IndustriesTable,
      Industry,
      $$IndustriesTableFilterComposer,
      $$IndustriesTableOrderingComposer,
      $$IndustriesTableAnnotationComposer,
      $$IndustriesTableCreateCompanionBuilder,
      $$IndustriesTableUpdateCompanionBuilder,
      (Industry, $$IndustriesTableReferences),
      Industry,
      PrefetchHooks Function({bool companyIndustriesRefs})
    >;
typedef $$CompaniesTableCreateCompanionBuilder = CompaniesCompanion Function({
  Value<int> id,
  required String name,
  required int statusId,
  Value<String?> mypageId,
  Value<String?> mypageUrl,
  Value<bool> useCustomReminders,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$CompaniesTableUpdateCompanionBuilder = CompaniesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> statusId,
  Value<String?> mypageId,
  Value<String?> mypageUrl,
  Value<bool> useCustomReminders,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StatusesTable _statusIdTable(_$AppDatabase db) =>
      db.statuses.createAlias('companies__status_id__statuses__id');

  $$StatusesTableProcessedTableManager get statusId {
    final $_column = $_itemColumn<int>('status_id')!;

    final manager = $$StatusesTableTableManager(
      $_db,
      $_db.statuses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_statusIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CompanyIndustriesTable, List<CompanyIndustry>>
  _companyIndustriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.companyIndustries,
        aliasName: 'companies__id__company_industries__company_id',
      );

  $$CompanyIndustriesTableProcessedTableManager get companyIndustriesRefs {
    final manager = $$CompanyIndustriesTableTableManager(
      $_db,
      $_db.companyIndustries,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companyIndustriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: 'companies__id__events__company_id',
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompanyRemindersTable, List<CompanyReminder>>
  _companyRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companyReminders,
    aliasName: 'companies__id__company_reminders__company_id',
  );

  $$CompanyRemindersTableProcessedTableManager get companyRemindersRefs {
    final manager = $$CompanyRemindersTableTableManager(
      $_db,
      $_db.companyReminders,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _companyRemindersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LogsTable, List<Log>> _logsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.logs,
    aliasName: 'companies__id__logs__company_id',
  );

  $$LogsTableProcessedTableManager get logsRefs {
    final manager = $$LogsTableTableManager(
      $_db,
      $_db.logs,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_logsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mypageId => $composableBuilder(
    column: $table.mypageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mypageUrl => $composableBuilder(
    column: $table.mypageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useCustomReminders => $composableBuilder(
    column: $table.useCustomReminders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StatusesTableFilterComposer get statusId {
    final $$StatusesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statusId,
      referencedTable: $db.statuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusesTableFilterComposer(
            $db: $db,
            $table: $db.statuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> companyIndustriesRefs(
    Expression<bool> Function($$CompanyIndustriesTableFilterComposer f) f,
  ) {
    final $$CompanyIndustriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyIndustries,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyIndustriesTableFilterComposer(
            $db: $db,
            $table: $db.companyIndustries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> companyRemindersRefs(
    Expression<bool> Function($$CompanyRemindersTableFilterComposer f) f,
  ) {
    final $$CompanyRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyReminders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyRemindersTableFilterComposer(
            $db: $db,
            $table: $db.companyReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logsRefs(
    Expression<bool> Function($$LogsTableFilterComposer f) f,
  ) {
    final $$LogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogsTableFilterComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mypageId => $composableBuilder(
    column: $table.mypageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mypageUrl => $composableBuilder(
    column: $table.mypageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useCustomReminders => $composableBuilder(
    column: $table.useCustomReminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StatusesTableOrderingComposer get statusId {
    final $$StatusesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statusId,
      referencedTable: $db.statuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusesTableOrderingComposer(
            $db: $db,
            $table: $db.statuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mypageId =>
      $composableBuilder(column: $table.mypageId, builder: (column) => column);

  GeneratedColumn<String> get mypageUrl =>
      $composableBuilder(column: $table.mypageUrl, builder: (column) => column);

  GeneratedColumn<bool> get useCustomReminders => $composableBuilder(
    column: $table.useCustomReminders,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$StatusesTableAnnotationComposer get statusId {
    final $$StatusesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statusId,
      referencedTable: $db.statuses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatusesTableAnnotationComposer(
            $db: $db,
            $table: $db.statuses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> companyIndustriesRefs<T extends Object>(
    Expression<T> Function($$CompanyIndustriesTableAnnotationComposer a) f,
  ) {
    final $$CompanyIndustriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.companyIndustries,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyIndustriesTableAnnotationComposer(
                $db: $db,
                $table: $db.companyIndustries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> companyRemindersRefs<T extends Object>(
    Expression<T> Function($$CompanyRemindersTableAnnotationComposer a) f,
  ) {
    final $$CompanyRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companyReminders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.companyReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> logsRefs<T extends Object>(
    Expression<T> Function($$LogsTableAnnotationComposer a) f,
  ) {
    final $$LogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogsTableAnnotationComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool statusId,
            bool companyIndustriesRefs,
            bool eventsRefs,
            bool companyRemindersRefs,
            bool logsRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> statusId = const Value.absent(),
                Value<String?> mypageId = const Value.absent(),
                Value<String?> mypageUrl = const Value.absent(),
                Value<bool> useCustomReminders = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                statusId: statusId,
                mypageId: mypageId,
                mypageUrl: mypageUrl,
                useCustomReminders: useCustomReminders,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int statusId,
                Value<String?> mypageId = const Value.absent(),
                Value<String?> mypageUrl = const Value.absent(),
                Value<bool> useCustomReminders = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                statusId: statusId,
                mypageId: mypageId,
                mypageUrl: mypageUrl,
                useCustomReminders: useCustomReminders,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompaniesTable, Company>(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                statusId = false,
                companyIndustriesRefs = false,
                eventsRefs = false,
                companyRemindersRefs = false,
                logsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (companyIndustriesRefs) db.companyIndustries,
                    if (eventsRefs) db.events,
                    if (companyRemindersRefs) db.companyReminders,
                    if (logsRefs) db.logs,
                  ],
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
                        if (statusId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.statusId,
                            referencedTable: $$CompaniesTableReferences
                                ._statusIdTable(db),
                            referencedColumn: $$CompaniesTableReferences
                                ._statusIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (companyIndustriesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CompanyIndustry
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._companyIndustriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).companyIndustriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Event
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (companyRemindersRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CompanyReminder
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._companyRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).companyRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (logsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Log
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._logsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).logsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool statusId,
        bool companyIndustriesRefs,
        bool eventsRefs,
        bool companyRemindersRefs,
        bool logsRefs,
      })
    >;
typedef $$CompanyIndustriesTableCreateCompanionBuilder =
    CompanyIndustriesCompanion Function({
      required int companyId,
      required int industryId,
      Value<int> rowid,
    });
typedef $$CompanyIndustriesTableUpdateCompanionBuilder =
    CompanyIndustriesCompanion Function({
      Value<int> companyId,
      Value<int> industryId,
      Value<int> rowid,
    });

final class $$CompanyIndustriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompanyIndustriesTable,
          CompanyIndustry
        > {
  $$CompanyIndustriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('company_industries__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IndustriesTable _industryIdTable(_$AppDatabase db) => db.industries
      .createAlias('company_industries__industry_id__industries__id');

  $$IndustriesTableProcessedTableManager get industryId {
    final $_column = $_itemColumn<int>('industry_id')!;

    final manager = $$IndustriesTableTableManager(
      $_db,
      $_db.industries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_industryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanyIndustriesTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyIndustriesTable> {
  $$CompanyIndustriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IndustriesTableFilterComposer get industryId {
    final $$IndustriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.industryId,
      referencedTable: $db.industries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IndustriesTableFilterComposer(
            $db: $db,
            $table: $db.industries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyIndustriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyIndustriesTable> {
  $$CompanyIndustriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IndustriesTableOrderingComposer get industryId {
    final $$IndustriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.industryId,
      referencedTable: $db.industries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IndustriesTableOrderingComposer(
            $db: $db,
            $table: $db.industries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyIndustriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyIndustriesTable> {
  $$CompanyIndustriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IndustriesTableAnnotationComposer get industryId {
    final $$IndustriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.industryId,
      referencedTable: $db.industries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IndustriesTableAnnotationComposer(
            $db: $db,
            $table: $db.industries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyIndustriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyIndustriesTable,
          CompanyIndustry,
          $$CompanyIndustriesTableFilterComposer,
          $$CompanyIndustriesTableOrderingComposer,
          $$CompanyIndustriesTableAnnotationComposer,
          $$CompanyIndustriesTableCreateCompanionBuilder,
          $$CompanyIndustriesTableUpdateCompanionBuilder,
          (CompanyIndustry, $$CompanyIndustriesTableReferences),
          CompanyIndustry,
          PrefetchHooks Function({bool companyId, bool industryId})
        > {
  $$CompanyIndustriesTableTableManager(
    _$AppDatabase db,
    $CompanyIndustriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyIndustriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyIndustriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyIndustriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> companyId = const Value.absent(),
                Value<int> industryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyIndustriesCompanion(
                companyId: companyId,
                industryId: industryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int companyId,
                required int industryId,
                Value<int> rowid = const Value.absent(),
              }) => CompanyIndustriesCompanion.insert(
                companyId: companyId,
                industryId: industryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompanyIndustriesTable, CompanyIndustry>(table),
                  $$CompanyIndustriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, industryId = false}) {
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
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$CompanyIndustriesTableReferences
                            ._companyIdTable(db),
                        referencedColumn: $$CompanyIndustriesTableReferences
                            ._companyIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (industryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.industryId,
                        referencedTable: $$CompanyIndustriesTableReferences
                            ._industryIdTable(db),
                        referencedColumn: $$CompanyIndustriesTableReferences
                            ._industryIdTable(db)
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

typedef $$CompanyIndustriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyIndustriesTable,
      CompanyIndustry,
      $$CompanyIndustriesTableFilterComposer,
      $$CompanyIndustriesTableOrderingComposer,
      $$CompanyIndustriesTableAnnotationComposer,
      $$CompanyIndustriesTableCreateCompanionBuilder,
      $$CompanyIndustriesTableUpdateCompanionBuilder,
      (CompanyIndustry, $$CompanyIndustriesTableReferences),
      CompanyIndustry,
      PrefetchHooks Function({bool companyId, bool industryId})
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  required int companyId,
  required EventType type,
  Value<String?> title,
  required DateTime startsAt,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<int> companyId,
  Value<EventType> type,
  Value<String?> title,
  Value<DateTime> startsAt,
});

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('events__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<EventType, EventType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({bool companyId})
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<EventType> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                companyId: companyId,
                type: type,
                title: title,
                startsAt: startsAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required EventType type,
                Value<String?> title = const Value.absent(),
                required DateTime startsAt,
              }) => EventsCompanion.insert(
                id: id,
                companyId: companyId,
                type: type,
                title: title,
                startsAt: startsAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, Event>(table),
                  $$EventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$EventsTableReferences
                            ._companyIdTable(db),
                        referencedColumn: $$EventsTableReferences
                            ._companyIdTable(db)
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

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$CompanyRemindersTableCreateCompanionBuilder =
    CompanyRemindersCompanion Function({
      required int companyId,
      required int minutesBefore,
      Value<int> rowid,
    });
typedef $$CompanyRemindersTableUpdateCompanionBuilder =
    CompanyRemindersCompanion Function({
      Value<int> companyId,
      Value<int> minutesBefore,
      Value<int> rowid,
    });

final class $$CompanyRemindersTableReferences
    extends
        BaseReferences<_$AppDatabase, $CompanyRemindersTable, CompanyReminder> {
  $$CompanyRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('company_reminders__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompanyRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyRemindersTable> {
  $$CompanyRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyRemindersTable> {
  $$CompanyRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyRemindersTable> {
  $$CompanyRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get minutesBefore => $composableBuilder(
    column: $table.minutesBefore,
    builder: (column) => column,
  );

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompanyRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyRemindersTable,
          CompanyReminder,
          $$CompanyRemindersTableFilterComposer,
          $$CompanyRemindersTableOrderingComposer,
          $$CompanyRemindersTableAnnotationComposer,
          $$CompanyRemindersTableCreateCompanionBuilder,
          $$CompanyRemindersTableUpdateCompanionBuilder,
          (CompanyReminder, $$CompanyRemindersTableReferences),
          CompanyReminder,
          PrefetchHooks Function({bool companyId})
        > {
  $$CompanyRemindersTableTableManager(
    _$AppDatabase db,
    $CompanyRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> companyId = const Value.absent(),
                Value<int> minutesBefore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyRemindersCompanion(
                companyId: companyId,
                minutesBefore: minutesBefore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int companyId,
                required int minutesBefore,
                Value<int> rowid = const Value.absent(),
              }) => CompanyRemindersCompanion.insert(
                companyId: companyId,
                minutesBefore: minutesBefore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompanyRemindersTable, CompanyReminder>(table),
                  $$CompanyRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$CompanyRemindersTableReferences
                            ._companyIdTable(db),
                        referencedColumn: $$CompanyRemindersTableReferences
                            ._companyIdTable(db)
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

typedef $$CompanyRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyRemindersTable,
      CompanyReminder,
      $$CompanyRemindersTableFilterComposer,
      $$CompanyRemindersTableOrderingComposer,
      $$CompanyRemindersTableAnnotationComposer,
      $$CompanyRemindersTableCreateCompanionBuilder,
      $$CompanyRemindersTableUpdateCompanionBuilder,
      (CompanyReminder, $$CompanyRemindersTableReferences),
      CompanyReminder,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$LogsTableCreateCompanionBuilder = LogsCompanion Function({
  Value<int> id,
  required int companyId,
  required LogKind kind,
  Value<String> body,
  Value<String?> fromStatus,
  Value<String?> toStatus,
  Value<DateTime> createdAt,
});
typedef $$LogsTableUpdateCompanionBuilder = LogsCompanion Function({
  Value<int> id,
  Value<int> companyId,
  Value<LogKind> kind,
  Value<String> body,
  Value<String?> fromStatus,
  Value<String?> toStatus,
  Value<DateTime> createdAt,
});

final class $$LogsTableReferences
    extends BaseReferences<_$AppDatabase, $LogsTable, Log> {
  $$LogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('logs__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<int>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LogsTableFilterComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<LogKind, LogKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogsTableOrderingComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableOrderingComposer({
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

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogsTable,
          Log,
          $$LogsTableFilterComposer,
          $$LogsTableOrderingComposer,
          $$LogsTableAnnotationComposer,
          $$LogsTableCreateCompanionBuilder,
          $$LogsTableUpdateCompanionBuilder,
          (Log, $$LogsTableReferences),
          Log,
          PrefetchHooks Function({bool companyId})
        > {
  $$LogsTableTableManager(_$AppDatabase db, $LogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> companyId = const Value.absent(),
                Value<LogKind> kind = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String?> toStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogsCompanion(
                id: id,
                companyId: companyId,
                kind: kind,
                body: body,
                fromStatus: fromStatus,
                toStatus: toStatus,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int companyId,
                required LogKind kind,
                Value<String> body = const Value.absent(),
                Value<String?> fromStatus = const Value.absent(),
                Value<String?> toStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogsCompanion.insert(
                id: id,
                companyId: companyId,
                kind: kind,
                body: body,
                fromStatus: fromStatus,
                toStatus: toStatus,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LogsTable, Log>(table),
                  $$LogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.companyId,
                        referencedTable: $$LogsTableReferences._companyIdTable(
                          db,
                        ),
                        referencedColumn: $$LogsTableReferences
                            ._companyIdTable(db)
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

typedef $$LogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogsTable,
      Log,
      $$LogsTableFilterComposer,
      $$LogsTableOrderingComposer,
      $$LogsTableAnnotationComposer,
      $$LogsTableCreateCompanionBuilder,
      $$LogsTableUpdateCompanionBuilder,
      (Log, $$LogsTableReferences),
      Log,
      PrefetchHooks Function({bool companyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StatusesTableTableManager get statuses =>
      $$StatusesTableTableManager(_db, _db.statuses);
  $$IndustriesTableTableManager get industries =>
      $$IndustriesTableTableManager(_db, _db.industries);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$CompanyIndustriesTableTableManager get companyIndustries =>
      $$CompanyIndustriesTableTableManager(_db, _db.companyIndustries);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$CompanyRemindersTableTableManager get companyReminders =>
      $$CompanyRemindersTableTableManager(_db, _db.companyReminders);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
}
