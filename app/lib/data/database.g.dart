// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _defaultPortionsMeta = const VerificationMeta(
    'defaultPortions',
  );
  @override
  late final GeneratedColumn<int> defaultPortions = GeneratedColumn<int>(
    'default_portions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _defaultMealsPerWeekMeta =
      const VerificationMeta('defaultMealsPerWeek');
  @override
  late final GeneratedColumn<int> defaultMealsPerWeek = GeneratedColumn<int>(
    'default_meals_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _repeatCooldownWeeksMeta =
      const VerificationMeta('repeatCooldownWeeks');
  @override
  late final GeneratedColumn<int> repeatCooldownWeeks = GeneratedColumn<int>(
    'repeat_cooldown_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _planningNudgeWeekdayMeta =
      const VerificationMeta('planningNudgeWeekday');
  @override
  late final GeneratedColumn<int> planningNudgeWeekday = GeneratedColumn<int>(
    'planning_nudge_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planningNudgeMinuteOfDayMeta =
      const VerificationMeta('planningNudgeMinuteOfDay');
  @override
  late final GeneratedColumn<int> planningNudgeMinuteOfDay =
      GeneratedColumn<int>(
        'planning_nudge_minute_of_day',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastExportedAtMeta = const VerificationMeta(
    'lastExportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExportedAt =
      GeneratedColumn<DateTime>(
        'last_exported_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    defaultPortions,
    defaultMealsPerWeek,
    repeatCooldownWeeks,
    planningNudgeWeekday,
    planningNudgeMinuteOfDay,
    lastExportedAt,
  ];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_portions')) {
      context.handle(
        _defaultPortionsMeta,
        defaultPortions.isAcceptableOrUnknown(
          data['default_portions']!,
          _defaultPortionsMeta,
        ),
      );
    }
    if (data.containsKey('default_meals_per_week')) {
      context.handle(
        _defaultMealsPerWeekMeta,
        defaultMealsPerWeek.isAcceptableOrUnknown(
          data['default_meals_per_week']!,
          _defaultMealsPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('repeat_cooldown_weeks')) {
      context.handle(
        _repeatCooldownWeeksMeta,
        repeatCooldownWeeks.isAcceptableOrUnknown(
          data['repeat_cooldown_weeks']!,
          _repeatCooldownWeeksMeta,
        ),
      );
    }
    if (data.containsKey('planning_nudge_weekday')) {
      context.handle(
        _planningNudgeWeekdayMeta,
        planningNudgeWeekday.isAcceptableOrUnknown(
          data['planning_nudge_weekday']!,
          _planningNudgeWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('planning_nudge_minute_of_day')) {
      context.handle(
        _planningNudgeMinuteOfDayMeta,
        planningNudgeMinuteOfDay.isAcceptableOrUnknown(
          data['planning_nudge_minute_of_day']!,
          _planningNudgeMinuteOfDayMeta,
        ),
      );
    }
    if (data.containsKey('last_exported_at')) {
      context.handle(
        _lastExportedAtMeta,
        lastExportedAt.isAcceptableOrUnknown(
          data['last_exported_at']!,
          _lastExportedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defaultPortions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_portions'],
      )!,
      defaultMealsPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_meals_per_week'],
      )!,
      repeatCooldownWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_cooldown_weeks'],
      )!,
      planningNudgeWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planning_nudge_weekday'],
      ),
      planningNudgeMinuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planning_nudge_minute_of_day'],
      ),
      lastExportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_exported_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;

  /// Default portions per meal. Overridable per week — see
  /// docs/planning/architecture.md, "Portions and recipe scaling".
  final int defaultPortions;

  /// Default number of meals to suggest per week. Overridable per week.
  final int defaultMealsPerWeek;

  /// How many weeks a recipe stays out of unprompted suggestions after
  /// being cooked. See architecture.md, "Repeat cooldown".
  final int repeatCooldownWeeks;

  /// Weekly planning-nudge day, using [DateTime.weekday] convention
  /// (1 = Monday .. 7 = Sunday). Null means the nudge is off, which is
  /// the default — see decisions.md, "Notifications".
  final int? planningNudgeWeekday;

  /// Minutes since local midnight, rather than a wall-clock time, to
  /// sidestep timezone/DST storage edge cases. Null when the nudge is off.
  final int? planningNudgeMinuteOfDay;

  /// When the owner last ran the system-file-picker export. Drives the
  /// staleness nudge in settings — see architecture.md, "Export/import
  /// via the system file picker". Added in schema v2.
  final DateTime? lastExportedAt;
  const Setting({
    required this.id,
    required this.defaultPortions,
    required this.defaultMealsPerWeek,
    required this.repeatCooldownWeeks,
    this.planningNudgeWeekday,
    this.planningNudgeMinuteOfDay,
    this.lastExportedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_portions'] = Variable<int>(defaultPortions);
    map['default_meals_per_week'] = Variable<int>(defaultMealsPerWeek);
    map['repeat_cooldown_weeks'] = Variable<int>(repeatCooldownWeeks);
    if (!nullToAbsent || planningNudgeWeekday != null) {
      map['planning_nudge_weekday'] = Variable<int>(planningNudgeWeekday);
    }
    if (!nullToAbsent || planningNudgeMinuteOfDay != null) {
      map['planning_nudge_minute_of_day'] = Variable<int>(
        planningNudgeMinuteOfDay,
      );
    }
    if (!nullToAbsent || lastExportedAt != null) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      defaultPortions: Value(defaultPortions),
      defaultMealsPerWeek: Value(defaultMealsPerWeek),
      repeatCooldownWeeks: Value(repeatCooldownWeeks),
      planningNudgeWeekday: planningNudgeWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(planningNudgeWeekday),
      planningNudgeMinuteOfDay: planningNudgeMinuteOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(planningNudgeMinuteOfDay),
      lastExportedAt: lastExportedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      defaultPortions: serializer.fromJson<int>(json['defaultPortions']),
      defaultMealsPerWeek: serializer.fromJson<int>(
        json['defaultMealsPerWeek'],
      ),
      repeatCooldownWeeks: serializer.fromJson<int>(
        json['repeatCooldownWeeks'],
      ),
      planningNudgeWeekday: serializer.fromJson<int?>(
        json['planningNudgeWeekday'],
      ),
      planningNudgeMinuteOfDay: serializer.fromJson<int?>(
        json['planningNudgeMinuteOfDay'],
      ),
      lastExportedAt: serializer.fromJson<DateTime?>(json['lastExportedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultPortions': serializer.toJson<int>(defaultPortions),
      'defaultMealsPerWeek': serializer.toJson<int>(defaultMealsPerWeek),
      'repeatCooldownWeeks': serializer.toJson<int>(repeatCooldownWeeks),
      'planningNudgeWeekday': serializer.toJson<int?>(planningNudgeWeekday),
      'planningNudgeMinuteOfDay': serializer.toJson<int?>(
        planningNudgeMinuteOfDay,
      ),
      'lastExportedAt': serializer.toJson<DateTime?>(lastExportedAt),
    };
  }

  Setting copyWith({
    int? id,
    int? defaultPortions,
    int? defaultMealsPerWeek,
    int? repeatCooldownWeeks,
    Value<int?> planningNudgeWeekday = const Value.absent(),
    Value<int?> planningNudgeMinuteOfDay = const Value.absent(),
    Value<DateTime?> lastExportedAt = const Value.absent(),
  }) => Setting(
    id: id ?? this.id,
    defaultPortions: defaultPortions ?? this.defaultPortions,
    defaultMealsPerWeek: defaultMealsPerWeek ?? this.defaultMealsPerWeek,
    repeatCooldownWeeks: repeatCooldownWeeks ?? this.repeatCooldownWeeks,
    planningNudgeWeekday: planningNudgeWeekday.present
        ? planningNudgeWeekday.value
        : this.planningNudgeWeekday,
    planningNudgeMinuteOfDay: planningNudgeMinuteOfDay.present
        ? planningNudgeMinuteOfDay.value
        : this.planningNudgeMinuteOfDay,
    lastExportedAt: lastExportedAt.present
        ? lastExportedAt.value
        : this.lastExportedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      defaultPortions: data.defaultPortions.present
          ? data.defaultPortions.value
          : this.defaultPortions,
      defaultMealsPerWeek: data.defaultMealsPerWeek.present
          ? data.defaultMealsPerWeek.value
          : this.defaultMealsPerWeek,
      repeatCooldownWeeks: data.repeatCooldownWeeks.present
          ? data.repeatCooldownWeeks.value
          : this.repeatCooldownWeeks,
      planningNudgeWeekday: data.planningNudgeWeekday.present
          ? data.planningNudgeWeekday.value
          : this.planningNudgeWeekday,
      planningNudgeMinuteOfDay: data.planningNudgeMinuteOfDay.present
          ? data.planningNudgeMinuteOfDay.value
          : this.planningNudgeMinuteOfDay,
      lastExportedAt: data.lastExportedAt.present
          ? data.lastExportedAt.value
          : this.lastExportedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('defaultPortions: $defaultPortions, ')
          ..write('defaultMealsPerWeek: $defaultMealsPerWeek, ')
          ..write('repeatCooldownWeeks: $repeatCooldownWeeks, ')
          ..write('planningNudgeWeekday: $planningNudgeWeekday, ')
          ..write('planningNudgeMinuteOfDay: $planningNudgeMinuteOfDay, ')
          ..write('lastExportedAt: $lastExportedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    defaultPortions,
    defaultMealsPerWeek,
    repeatCooldownWeeks,
    planningNudgeWeekday,
    planningNudgeMinuteOfDay,
    lastExportedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.defaultPortions == this.defaultPortions &&
          other.defaultMealsPerWeek == this.defaultMealsPerWeek &&
          other.repeatCooldownWeeks == this.repeatCooldownWeeks &&
          other.planningNudgeWeekday == this.planningNudgeWeekday &&
          other.planningNudgeMinuteOfDay == this.planningNudgeMinuteOfDay &&
          other.lastExportedAt == this.lastExportedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<int> defaultPortions;
  final Value<int> defaultMealsPerWeek;
  final Value<int> repeatCooldownWeeks;
  final Value<int?> planningNudgeWeekday;
  final Value<int?> planningNudgeMinuteOfDay;
  final Value<DateTime?> lastExportedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.defaultPortions = const Value.absent(),
    this.defaultMealsPerWeek = const Value.absent(),
    this.repeatCooldownWeeks = const Value.absent(),
    this.planningNudgeWeekday = const Value.absent(),
    this.planningNudgeMinuteOfDay = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.defaultPortions = const Value.absent(),
    this.defaultMealsPerWeek = const Value.absent(),
    this.repeatCooldownWeeks = const Value.absent(),
    this.planningNudgeWeekday = const Value.absent(),
    this.planningNudgeMinuteOfDay = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<int>? defaultPortions,
    Expression<int>? defaultMealsPerWeek,
    Expression<int>? repeatCooldownWeeks,
    Expression<int>? planningNudgeWeekday,
    Expression<int>? planningNudgeMinuteOfDay,
    Expression<DateTime>? lastExportedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultPortions != null) 'default_portions': defaultPortions,
      if (defaultMealsPerWeek != null)
        'default_meals_per_week': defaultMealsPerWeek,
      if (repeatCooldownWeeks != null)
        'repeat_cooldown_weeks': repeatCooldownWeeks,
      if (planningNudgeWeekday != null)
        'planning_nudge_weekday': planningNudgeWeekday,
      if (planningNudgeMinuteOfDay != null)
        'planning_nudge_minute_of_day': planningNudgeMinuteOfDay,
      if (lastExportedAt != null) 'last_exported_at': lastExportedAt,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? defaultPortions,
    Value<int>? defaultMealsPerWeek,
    Value<int>? repeatCooldownWeeks,
    Value<int?>? planningNudgeWeekday,
    Value<int?>? planningNudgeMinuteOfDay,
    Value<DateTime?>? lastExportedAt,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      defaultPortions: defaultPortions ?? this.defaultPortions,
      defaultMealsPerWeek: defaultMealsPerWeek ?? this.defaultMealsPerWeek,
      repeatCooldownWeeks: repeatCooldownWeeks ?? this.repeatCooldownWeeks,
      planningNudgeWeekday: planningNudgeWeekday ?? this.planningNudgeWeekday,
      planningNudgeMinuteOfDay:
          planningNudgeMinuteOfDay ?? this.planningNudgeMinuteOfDay,
      lastExportedAt: lastExportedAt ?? this.lastExportedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultPortions.present) {
      map['default_portions'] = Variable<int>(defaultPortions.value);
    }
    if (defaultMealsPerWeek.present) {
      map['default_meals_per_week'] = Variable<int>(defaultMealsPerWeek.value);
    }
    if (repeatCooldownWeeks.present) {
      map['repeat_cooldown_weeks'] = Variable<int>(repeatCooldownWeeks.value);
    }
    if (planningNudgeWeekday.present) {
      map['planning_nudge_weekday'] = Variable<int>(planningNudgeWeekday.value);
    }
    if (planningNudgeMinuteOfDay.present) {
      map['planning_nudge_minute_of_day'] = Variable<int>(
        planningNudgeMinuteOfDay.value,
      );
    }
    if (lastExportedAt.present) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultPortions: $defaultPortions, ')
          ..write('defaultMealsPerWeek: $defaultMealsPerWeek, ')
          ..write('repeatCooldownWeeks: $repeatCooldownWeeks, ')
          ..write('planningNudgeWeekday: $planningNudgeWeekday, ')
          ..write('planningNudgeMinuteOfDay: $planningNudgeMinuteOfDay, ')
          ..write('lastExportedAt: $lastExportedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [settings];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> defaultPortions,
  Value<int> defaultMealsPerWeek,
  Value<int> repeatCooldownWeeks,
  Value<int?> planningNudgeWeekday,
  Value<int?> planningNudgeMinuteOfDay,
  Value<DateTime?> lastExportedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> defaultPortions,
  Value<int> defaultMealsPerWeek,
  Value<int> repeatCooldownWeeks,
  Value<int?> planningNudgeWeekday,
  Value<int?> planningNudgeMinuteOfDay,
  Value<DateTime?> lastExportedAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<int> get defaultPortions => $composableBuilder(
    column: $table.defaultPortions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultMealsPerWeek => $composableBuilder(
    column: $table.defaultMealsPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCooldownWeeks => $composableBuilder(
    column: $table.repeatCooldownWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planningNudgeWeekday => $composableBuilder(
    column: $table.planningNudgeWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planningNudgeMinuteOfDay => $composableBuilder(
    column: $table.planningNudgeMinuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<int> get defaultPortions => $composableBuilder(
    column: $table.defaultPortions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultMealsPerWeek => $composableBuilder(
    column: $table.defaultMealsPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCooldownWeeks => $composableBuilder(
    column: $table.repeatCooldownWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planningNudgeWeekday => $composableBuilder(
    column: $table.planningNudgeWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planningNudgeMinuteOfDay => $composableBuilder(
    column: $table.planningNudgeMinuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get defaultPortions => $composableBuilder(
    column: $table.defaultPortions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultMealsPerWeek => $composableBuilder(
    column: $table.defaultMealsPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatCooldownWeeks => $composableBuilder(
    column: $table.repeatCooldownWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get planningNudgeWeekday => $composableBuilder(
    column: $table.planningNudgeWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<int> get planningNudgeMinuteOfDay => $composableBuilder(
    column: $table.planningNudgeMinuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultPortions = const Value.absent(),
                Value<int> defaultMealsPerWeek = const Value.absent(),
                Value<int> repeatCooldownWeeks = const Value.absent(),
                Value<int?> planningNudgeWeekday = const Value.absent(),
                Value<int?> planningNudgeMinuteOfDay = const Value.absent(),
                Value<DateTime?> lastExportedAt = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                defaultPortions: defaultPortions,
                defaultMealsPerWeek: defaultMealsPerWeek,
                repeatCooldownWeeks: repeatCooldownWeeks,
                planningNudgeWeekday: planningNudgeWeekday,
                planningNudgeMinuteOfDay: planningNudgeMinuteOfDay,
                lastExportedAt: lastExportedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> defaultPortions = const Value.absent(),
                Value<int> defaultMealsPerWeek = const Value.absent(),
                Value<int> repeatCooldownWeeks = const Value.absent(),
                Value<int?> planningNudgeWeekday = const Value.absent(),
                Value<int?> planningNudgeMinuteOfDay = const Value.absent(),
                Value<DateTime?> lastExportedAt = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                defaultPortions: defaultPortions,
                defaultMealsPerWeek: defaultMealsPerWeek,
                repeatCooldownWeeks: repeatCooldownWeeks,
                planningNudgeWeekday: planningNudgeWeekday,
                planningNudgeMinuteOfDay: planningNudgeMinuteOfDay,
                lastExportedAt: lastExportedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
