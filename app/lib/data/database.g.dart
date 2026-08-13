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

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servesMeta = const VerificationMeta('serves');
  @override
  late final GeneratedColumn<int> serves = GeneratedColumn<int>(
    'serves',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedByUserMeta = const VerificationMeta(
    'editedByUser',
  );
  @override
  late final GeneratedColumn<bool> editedByUser = GeneratedColumn<bool>(
    'edited_by_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("edited_by_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kcalPerPortionMeta = const VerificationMeta(
    'kcalPerPortion',
  );
  @override
  late final GeneratedColumn<int> kcalPerPortion = GeneratedColumn<int>(
    'kcal_per_portion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGPerPortionMeta =
      const VerificationMeta('proteinGPerPortion');
  @override
  late final GeneratedColumn<double> proteinGPerPortion =
      GeneratedColumn<double>(
        'protein_g_per_portion',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatGPerPortionMeta = const VerificationMeta(
    'fatGPerPortion',
  );
  @override
  late final GeneratedColumn<double> fatGPerPortion = GeneratedColumn<double>(
    'fat_g_per_portion',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGPerPortionMeta = const VerificationMeta(
    'carbsGPerPortion',
  );
  @override
  late final GeneratedColumn<double> carbsGPerPortion = GeneratedColumn<double>(
    'carbs_g_per_portion',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecipeSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecipeSource>($RecipesTable.$convertersource);
  static const VerificationMeta _cuisineMeta = const VerificationMeta(
    'cuisine',
  );
  @override
  late final GeneratedColumn<String> cuisine = GeneratedColumn<String>(
    'cuisine',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeMinutesMeta = const VerificationMeta(
    'timeMinutes',
  );
  @override
  late final GeneratedColumn<int> timeMinutes = GeneratedColumn<int>(
    'time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecipeDifficulty?, String>
  difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<RecipeDifficulty?>($RecipesTable.$converterdifficultyn);
  static const VerificationMeta _primaryProteinMeta = const VerificationMeta(
    'primaryProtein',
  );
  @override
  late final GeneratedColumn<String> primaryProtein = GeneratedColumn<String>(
    'primary_protein',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cookingMethodMeta = const VerificationMeta(
    'cookingMethod',
  );
  @override
  late final GeneratedColumn<String> cookingMethod = GeneratedColumn<String>(
    'cooking_method',
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    serves,
    method,
    editedByUser,
    kcalPerPortion,
    proteinGPerPortion,
    fatGPerPortion,
    carbsGPerPortion,
    source,
    cuisine,
    timeMinutes,
    difficulty,
    primaryProtein,
    cookingMethod,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('serves')) {
      context.handle(
        _servesMeta,
        serves.isAcceptableOrUnknown(data['serves']!, _servesMeta),
      );
    } else if (isInserting) {
      context.missing(_servesMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('edited_by_user')) {
      context.handle(
        _editedByUserMeta,
        editedByUser.isAcceptableOrUnknown(
          data['edited_by_user']!,
          _editedByUserMeta,
        ),
      );
    }
    if (data.containsKey('kcal_per_portion')) {
      context.handle(
        _kcalPerPortionMeta,
        kcalPerPortion.isAcceptableOrUnknown(
          data['kcal_per_portion']!,
          _kcalPerPortionMeta,
        ),
      );
    }
    if (data.containsKey('protein_g_per_portion')) {
      context.handle(
        _proteinGPerPortionMeta,
        proteinGPerPortion.isAcceptableOrUnknown(
          data['protein_g_per_portion']!,
          _proteinGPerPortionMeta,
        ),
      );
    }
    if (data.containsKey('fat_g_per_portion')) {
      context.handle(
        _fatGPerPortionMeta,
        fatGPerPortion.isAcceptableOrUnknown(
          data['fat_g_per_portion']!,
          _fatGPerPortionMeta,
        ),
      );
    }
    if (data.containsKey('carbs_g_per_portion')) {
      context.handle(
        _carbsGPerPortionMeta,
        carbsGPerPortion.isAcceptableOrUnknown(
          data['carbs_g_per_portion']!,
          _carbsGPerPortionMeta,
        ),
      );
    }
    if (data.containsKey('cuisine')) {
      context.handle(
        _cuisineMeta,
        cuisine.isAcceptableOrUnknown(data['cuisine']!, _cuisineMeta),
      );
    }
    if (data.containsKey('time_minutes')) {
      context.handle(
        _timeMinutesMeta,
        timeMinutes.isAcceptableOrUnknown(
          data['time_minutes']!,
          _timeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('primary_protein')) {
      context.handle(
        _primaryProteinMeta,
        primaryProtein.isAcceptableOrUnknown(
          data['primary_protein']!,
          _primaryProteinMeta,
        ),
      );
    }
    if (data.containsKey('cooking_method')) {
      context.handle(
        _cookingMethodMeta,
        cookingMethod.isAcceptableOrUnknown(
          data['cooking_method']!,
          _cookingMethodMeta,
        ),
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
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      serves: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serves'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      editedByUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}edited_by_user'],
      )!,
      kcalPerPortion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal_per_portion'],
      ),
      proteinGPerPortion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g_per_portion'],
      ),
      fatGPerPortion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g_per_portion'],
      ),
      carbsGPerPortion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g_per_portion'],
      ),
      source: $RecipesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      cuisine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuisine'],
      ),
      timeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_minutes'],
      ),
      difficulty: $RecipesTable.$converterdifficultyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        ),
      ),
      primaryProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_protein'],
      ),
      cookingMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cooking_method'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecipeSource, String, String> $convertersource =
      const EnumNameConverter<RecipeSource>(RecipeSource.values);
  static JsonTypeConverter2<RecipeDifficulty, String, String>
  $converterdifficulty = const EnumNameConverter<RecipeDifficulty>(
    RecipeDifficulty.values,
  );
  static JsonTypeConverter2<RecipeDifficulty?, String?, String?>
  $converterdifficultyn = JsonTypeConverter2.asNullable($converterdifficulty);
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String title;

  /// The portion count these quantities are written for. See
  /// architecture.md, "Portions and recipe scaling" — recipes are
  /// generated at the target count, not scaled afterwards.
  final int serves;
  final String method;
  final bool editedByUser;

  /// Rough, LLM-estimated, informational only — never feeds back into
  /// suggestions. See architecture.md, "Shared house style".
  final int? kcalPerPortion;
  final double? proteinGPerPortion;
  final double? fatGPerPortion;
  final double? carbsGPerPortion;
  final RecipeSource source;
  final String? cuisine;
  final int? timeMinutes;
  final RecipeDifficulty? difficulty;
  final String? primaryProtein;
  final String? cookingMethod;
  final DateTime createdAt;
  const Recipe({
    required this.id,
    required this.title,
    required this.serves,
    required this.method,
    required this.editedByUser,
    this.kcalPerPortion,
    this.proteinGPerPortion,
    this.fatGPerPortion,
    this.carbsGPerPortion,
    required this.source,
    this.cuisine,
    this.timeMinutes,
    this.difficulty,
    this.primaryProtein,
    this.cookingMethod,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['serves'] = Variable<int>(serves);
    map['method'] = Variable<String>(method);
    map['edited_by_user'] = Variable<bool>(editedByUser);
    if (!nullToAbsent || kcalPerPortion != null) {
      map['kcal_per_portion'] = Variable<int>(kcalPerPortion);
    }
    if (!nullToAbsent || proteinGPerPortion != null) {
      map['protein_g_per_portion'] = Variable<double>(proteinGPerPortion);
    }
    if (!nullToAbsent || fatGPerPortion != null) {
      map['fat_g_per_portion'] = Variable<double>(fatGPerPortion);
    }
    if (!nullToAbsent || carbsGPerPortion != null) {
      map['carbs_g_per_portion'] = Variable<double>(carbsGPerPortion);
    }
    {
      map['source'] = Variable<String>(
        $RecipesTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || cuisine != null) {
      map['cuisine'] = Variable<String>(cuisine);
    }
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = Variable<int>(timeMinutes);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(
        $RecipesTable.$converterdifficultyn.toSql(difficulty),
      );
    }
    if (!nullToAbsent || primaryProtein != null) {
      map['primary_protein'] = Variable<String>(primaryProtein);
    }
    if (!nullToAbsent || cookingMethod != null) {
      map['cooking_method'] = Variable<String>(cookingMethod);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      title: Value(title),
      serves: Value(serves),
      method: Value(method),
      editedByUser: Value(editedByUser),
      kcalPerPortion: kcalPerPortion == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalPerPortion),
      proteinGPerPortion: proteinGPerPortion == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinGPerPortion),
      fatGPerPortion: fatGPerPortion == null && nullToAbsent
          ? const Value.absent()
          : Value(fatGPerPortion),
      carbsGPerPortion: carbsGPerPortion == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsGPerPortion),
      source: Value(source),
      cuisine: cuisine == null && nullToAbsent
          ? const Value.absent()
          : Value(cuisine),
      timeMinutes: timeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeMinutes),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      primaryProtein: primaryProtein == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryProtein),
      cookingMethod: cookingMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(cookingMethod),
      createdAt: Value(createdAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      serves: serializer.fromJson<int>(json['serves']),
      method: serializer.fromJson<String>(json['method']),
      editedByUser: serializer.fromJson<bool>(json['editedByUser']),
      kcalPerPortion: serializer.fromJson<int?>(json['kcalPerPortion']),
      proteinGPerPortion: serializer.fromJson<double?>(
        json['proteinGPerPortion'],
      ),
      fatGPerPortion: serializer.fromJson<double?>(json['fatGPerPortion']),
      carbsGPerPortion: serializer.fromJson<double?>(json['carbsGPerPortion']),
      source: $RecipesTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      cuisine: serializer.fromJson<String?>(json['cuisine']),
      timeMinutes: serializer.fromJson<int?>(json['timeMinutes']),
      difficulty: $RecipesTable.$converterdifficultyn.fromJson(
        serializer.fromJson<String?>(json['difficulty']),
      ),
      primaryProtein: serializer.fromJson<String?>(json['primaryProtein']),
      cookingMethod: serializer.fromJson<String?>(json['cookingMethod']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'serves': serializer.toJson<int>(serves),
      'method': serializer.toJson<String>(method),
      'editedByUser': serializer.toJson<bool>(editedByUser),
      'kcalPerPortion': serializer.toJson<int?>(kcalPerPortion),
      'proteinGPerPortion': serializer.toJson<double?>(proteinGPerPortion),
      'fatGPerPortion': serializer.toJson<double?>(fatGPerPortion),
      'carbsGPerPortion': serializer.toJson<double?>(carbsGPerPortion),
      'source': serializer.toJson<String>(
        $RecipesTable.$convertersource.toJson(source),
      ),
      'cuisine': serializer.toJson<String?>(cuisine),
      'timeMinutes': serializer.toJson<int?>(timeMinutes),
      'difficulty': serializer.toJson<String?>(
        $RecipesTable.$converterdifficultyn.toJson(difficulty),
      ),
      'primaryProtein': serializer.toJson<String?>(primaryProtein),
      'cookingMethod': serializer.toJson<String?>(cookingMethod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recipe copyWith({
    int? id,
    String? title,
    int? serves,
    String? method,
    bool? editedByUser,
    Value<int?> kcalPerPortion = const Value.absent(),
    Value<double?> proteinGPerPortion = const Value.absent(),
    Value<double?> fatGPerPortion = const Value.absent(),
    Value<double?> carbsGPerPortion = const Value.absent(),
    RecipeSource? source,
    Value<String?> cuisine = const Value.absent(),
    Value<int?> timeMinutes = const Value.absent(),
    Value<RecipeDifficulty?> difficulty = const Value.absent(),
    Value<String?> primaryProtein = const Value.absent(),
    Value<String?> cookingMethod = const Value.absent(),
    DateTime? createdAt,
  }) => Recipe(
    id: id ?? this.id,
    title: title ?? this.title,
    serves: serves ?? this.serves,
    method: method ?? this.method,
    editedByUser: editedByUser ?? this.editedByUser,
    kcalPerPortion: kcalPerPortion.present
        ? kcalPerPortion.value
        : this.kcalPerPortion,
    proteinGPerPortion: proteinGPerPortion.present
        ? proteinGPerPortion.value
        : this.proteinGPerPortion,
    fatGPerPortion: fatGPerPortion.present
        ? fatGPerPortion.value
        : this.fatGPerPortion,
    carbsGPerPortion: carbsGPerPortion.present
        ? carbsGPerPortion.value
        : this.carbsGPerPortion,
    source: source ?? this.source,
    cuisine: cuisine.present ? cuisine.value : this.cuisine,
    timeMinutes: timeMinutes.present ? timeMinutes.value : this.timeMinutes,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    primaryProtein: primaryProtein.present
        ? primaryProtein.value
        : this.primaryProtein,
    cookingMethod: cookingMethod.present
        ? cookingMethod.value
        : this.cookingMethod,
    createdAt: createdAt ?? this.createdAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      serves: data.serves.present ? data.serves.value : this.serves,
      method: data.method.present ? data.method.value : this.method,
      editedByUser: data.editedByUser.present
          ? data.editedByUser.value
          : this.editedByUser,
      kcalPerPortion: data.kcalPerPortion.present
          ? data.kcalPerPortion.value
          : this.kcalPerPortion,
      proteinGPerPortion: data.proteinGPerPortion.present
          ? data.proteinGPerPortion.value
          : this.proteinGPerPortion,
      fatGPerPortion: data.fatGPerPortion.present
          ? data.fatGPerPortion.value
          : this.fatGPerPortion,
      carbsGPerPortion: data.carbsGPerPortion.present
          ? data.carbsGPerPortion.value
          : this.carbsGPerPortion,
      source: data.source.present ? data.source.value : this.source,
      cuisine: data.cuisine.present ? data.cuisine.value : this.cuisine,
      timeMinutes: data.timeMinutes.present
          ? data.timeMinutes.value
          : this.timeMinutes,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      primaryProtein: data.primaryProtein.present
          ? data.primaryProtein.value
          : this.primaryProtein,
      cookingMethod: data.cookingMethod.present
          ? data.cookingMethod.value
          : this.cookingMethod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('serves: $serves, ')
          ..write('method: $method, ')
          ..write('editedByUser: $editedByUser, ')
          ..write('kcalPerPortion: $kcalPerPortion, ')
          ..write('proteinGPerPortion: $proteinGPerPortion, ')
          ..write('fatGPerPortion: $fatGPerPortion, ')
          ..write('carbsGPerPortion: $carbsGPerPortion, ')
          ..write('source: $source, ')
          ..write('cuisine: $cuisine, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryProtein: $primaryProtein, ')
          ..write('cookingMethod: $cookingMethod, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    serves,
    method,
    editedByUser,
    kcalPerPortion,
    proteinGPerPortion,
    fatGPerPortion,
    carbsGPerPortion,
    source,
    cuisine,
    timeMinutes,
    difficulty,
    primaryProtein,
    cookingMethod,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.title == this.title &&
          other.serves == this.serves &&
          other.method == this.method &&
          other.editedByUser == this.editedByUser &&
          other.kcalPerPortion == this.kcalPerPortion &&
          other.proteinGPerPortion == this.proteinGPerPortion &&
          other.fatGPerPortion == this.fatGPerPortion &&
          other.carbsGPerPortion == this.carbsGPerPortion &&
          other.source == this.source &&
          other.cuisine == this.cuisine &&
          other.timeMinutes == this.timeMinutes &&
          other.difficulty == this.difficulty &&
          other.primaryProtein == this.primaryProtein &&
          other.cookingMethod == this.cookingMethod &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> serves;
  final Value<String> method;
  final Value<bool> editedByUser;
  final Value<int?> kcalPerPortion;
  final Value<double?> proteinGPerPortion;
  final Value<double?> fatGPerPortion;
  final Value<double?> carbsGPerPortion;
  final Value<RecipeSource> source;
  final Value<String?> cuisine;
  final Value<int?> timeMinutes;
  final Value<RecipeDifficulty?> difficulty;
  final Value<String?> primaryProtein;
  final Value<String?> cookingMethod;
  final Value<DateTime> createdAt;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.serves = const Value.absent(),
    this.method = const Value.absent(),
    this.editedByUser = const Value.absent(),
    this.kcalPerPortion = const Value.absent(),
    this.proteinGPerPortion = const Value.absent(),
    this.fatGPerPortion = const Value.absent(),
    this.carbsGPerPortion = const Value.absent(),
    this.source = const Value.absent(),
    this.cuisine = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.primaryProtein = const Value.absent(),
    this.cookingMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int serves,
    required String method,
    this.editedByUser = const Value.absent(),
    this.kcalPerPortion = const Value.absent(),
    this.proteinGPerPortion = const Value.absent(),
    this.fatGPerPortion = const Value.absent(),
    this.carbsGPerPortion = const Value.absent(),
    required RecipeSource source,
    this.cuisine = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.primaryProtein = const Value.absent(),
    this.cookingMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       serves = Value(serves),
       method = Value(method),
       source = Value(source);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? serves,
    Expression<String>? method,
    Expression<bool>? editedByUser,
    Expression<int>? kcalPerPortion,
    Expression<double>? proteinGPerPortion,
    Expression<double>? fatGPerPortion,
    Expression<double>? carbsGPerPortion,
    Expression<String>? source,
    Expression<String>? cuisine,
    Expression<int>? timeMinutes,
    Expression<String>? difficulty,
    Expression<String>? primaryProtein,
    Expression<String>? cookingMethod,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (serves != null) 'serves': serves,
      if (method != null) 'method': method,
      if (editedByUser != null) 'edited_by_user': editedByUser,
      if (kcalPerPortion != null) 'kcal_per_portion': kcalPerPortion,
      if (proteinGPerPortion != null)
        'protein_g_per_portion': proteinGPerPortion,
      if (fatGPerPortion != null) 'fat_g_per_portion': fatGPerPortion,
      if (carbsGPerPortion != null) 'carbs_g_per_portion': carbsGPerPortion,
      if (source != null) 'source': source,
      if (cuisine != null) 'cuisine': cuisine,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (difficulty != null) 'difficulty': difficulty,
      if (primaryProtein != null) 'primary_protein': primaryProtein,
      if (cookingMethod != null) 'cooking_method': cookingMethod,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? serves,
    Value<String>? method,
    Value<bool>? editedByUser,
    Value<int?>? kcalPerPortion,
    Value<double?>? proteinGPerPortion,
    Value<double?>? fatGPerPortion,
    Value<double?>? carbsGPerPortion,
    Value<RecipeSource>? source,
    Value<String?>? cuisine,
    Value<int?>? timeMinutes,
    Value<RecipeDifficulty?>? difficulty,
    Value<String?>? primaryProtein,
    Value<String?>? cookingMethod,
    Value<DateTime>? createdAt,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      serves: serves ?? this.serves,
      method: method ?? this.method,
      editedByUser: editedByUser ?? this.editedByUser,
      kcalPerPortion: kcalPerPortion ?? this.kcalPerPortion,
      proteinGPerPortion: proteinGPerPortion ?? this.proteinGPerPortion,
      fatGPerPortion: fatGPerPortion ?? this.fatGPerPortion,
      carbsGPerPortion: carbsGPerPortion ?? this.carbsGPerPortion,
      source: source ?? this.source,
      cuisine: cuisine ?? this.cuisine,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      difficulty: difficulty ?? this.difficulty,
      primaryProtein: primaryProtein ?? this.primaryProtein,
      cookingMethod: cookingMethod ?? this.cookingMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (serves.present) {
      map['serves'] = Variable<int>(serves.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (editedByUser.present) {
      map['edited_by_user'] = Variable<bool>(editedByUser.value);
    }
    if (kcalPerPortion.present) {
      map['kcal_per_portion'] = Variable<int>(kcalPerPortion.value);
    }
    if (proteinGPerPortion.present) {
      map['protein_g_per_portion'] = Variable<double>(proteinGPerPortion.value);
    }
    if (fatGPerPortion.present) {
      map['fat_g_per_portion'] = Variable<double>(fatGPerPortion.value);
    }
    if (carbsGPerPortion.present) {
      map['carbs_g_per_portion'] = Variable<double>(carbsGPerPortion.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $RecipesTable.$convertersource.toSql(source.value),
      );
    }
    if (cuisine.present) {
      map['cuisine'] = Variable<String>(cuisine.value);
    }
    if (timeMinutes.present) {
      map['time_minutes'] = Variable<int>(timeMinutes.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $RecipesTable.$converterdifficultyn.toSql(difficulty.value),
      );
    }
    if (primaryProtein.present) {
      map['primary_protein'] = Variable<String>(primaryProtein.value);
    }
    if (cookingMethod.present) {
      map['cooking_method'] = Variable<String>(cookingMethod.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('serves: $serves, ')
          ..write('method: $method, ')
          ..write('editedByUser: $editedByUser, ')
          ..write('kcalPerPortion: $kcalPerPortion, ')
          ..write('proteinGPerPortion: $proteinGPerPortion, ')
          ..write('fatGPerPortion: $fatGPerPortion, ')
          ..write('carbsGPerPortion: $carbsGPerPortion, ')
          ..write('source: $source, ')
          ..write('cuisine: $cuisine, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryProtein: $primaryProtein, ')
          ..write('cookingMethod: $cookingMethod, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngredientUnit?, String> unit =
      GeneratedColumn<String>(
        'unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<IngredientUnit?>($RecipeIngredientsTable.$converterunitn);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    sortOrder,
    name,
    quantity,
    unit,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: $RecipeIngredientsTable.$converterunitn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IngredientUnit, String, String> $converterunit =
      const EnumNameConverter<IngredientUnit>(IngredientUnit.values);
  static JsonTypeConverter2<IngredientUnit?, String?, String?> $converterunitn =
      JsonTypeConverter2.asNullable($converterunit);
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final int recipeId;

  /// Preserves the order the model returned — ingredient lists read
  /// oddly reordered (mise en place first, garnish last, etc).
  final int sortOrder;

  /// Precisely enough to buy, not just to cook — "beef mince, 12% fat",
  /// not "mince". See architecture.md, "Shared house style".
  final String name;

  /// Nullable because cooking is fuzzy: "salt to taste", "a splash of
  /// oil". See architecture.md, "Quantities are nullable". Ingredients
  /// with a null quantity skip merging/rounding entirely.
  final double? quantity;
  final IngredientUnit? unit;
  final String? note;
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.sortOrder,
    required this.name,
    this.quantity,
    this.unit,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(
        $RecipeIngredientsTable.$converterunitn.toSql(unit),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      sortOrder: Value(sortOrder),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: $RecipeIngredientsTable.$converterunitn.fromJson(
        serializer.fromJson<String?>(json['unit']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(
        $RecipeIngredientsTable.$converterunitn.toJson(unit),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    int? recipeId,
    int? sortOrder,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<IngredientUnit?> unit = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => RecipeIngredient(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    sortOrder: sortOrder ?? this.sortOrder,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    note: note.present ? note.value : this.note,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, sortOrder, name, quantity, unit, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.sortOrder == this.sortOrder &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.note == this.note);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> sortOrder;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<IngredientUnit?> unit;
  final Value<String?> note;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int sortOrder,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
  }) : recipeId = Value(recipeId),
       sortOrder = Value(sortOrder),
       name = Value(name);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? sortOrder,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (note != null) 'note': note,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int>? sortOrder,
    Value<String>? name,
    Value<double?>? quantity,
    Value<IngredientUnit?>? unit,
    Value<String?>? note,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(
        $RecipeIngredientsTable.$converterunitn.toSql(unit.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $WeeklyPlansTable extends WeeklyPlans
    with TableInfo<$WeeklyPlansTable, WeeklyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _portionsMeta = const VerificationMeta(
    'portions',
  );
  @override
  late final GeneratedColumn<int> portions = GeneratedColumn<int>(
    'portions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealCountMeta = const VerificationMeta(
    'mealCount',
  );
  @override
  late final GeneratedColumn<int> mealCount = GeneratedColumn<int>(
    'meal_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [id, portions, mealCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('portions')) {
      context.handle(
        _portionsMeta,
        portions.isAcceptableOrUnknown(data['portions']!, _portionsMeta),
      );
    } else if (isInserting) {
      context.missing(_portionsMeta);
    }
    if (data.containsKey('meal_count')) {
      context.handle(
        _mealCountMeta,
        mealCount.isAcceptableOrUnknown(data['meal_count']!, _mealCountMeta),
      );
    } else if (isInserting) {
      context.missing(_mealCountMeta);
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
  WeeklyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      portions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}portions'],
      )!,
      mealCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WeeklyPlansTable createAlias(String alias) {
    return $WeeklyPlansTable(attachedDatabase, alias);
  }
}

class WeeklyPlan extends DataClass implements Insertable<WeeklyPlan> {
  final int id;

  /// Seeded from Settings.defaultPortions, overridable per week.
  final int portions;

  /// Seeded from Settings.defaultMealsPerWeek, overridable per week.
  final int mealCount;
  final DateTime createdAt;
  const WeeklyPlan({
    required this.id,
    required this.portions,
    required this.mealCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['portions'] = Variable<int>(portions);
    map['meal_count'] = Variable<int>(mealCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WeeklyPlansCompanion toCompanion(bool nullToAbsent) {
    return WeeklyPlansCompanion(
      id: Value(id),
      portions: Value(portions),
      mealCount: Value(mealCount),
      createdAt: Value(createdAt),
    );
  }

  factory WeeklyPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyPlan(
      id: serializer.fromJson<int>(json['id']),
      portions: serializer.fromJson<int>(json['portions']),
      mealCount: serializer.fromJson<int>(json['mealCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'portions': serializer.toJson<int>(portions),
      'mealCount': serializer.toJson<int>(mealCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WeeklyPlan copyWith({
    int? id,
    int? portions,
    int? mealCount,
    DateTime? createdAt,
  }) => WeeklyPlan(
    id: id ?? this.id,
    portions: portions ?? this.portions,
    mealCount: mealCount ?? this.mealCount,
    createdAt: createdAt ?? this.createdAt,
  );
  WeeklyPlan copyWithCompanion(WeeklyPlansCompanion data) {
    return WeeklyPlan(
      id: data.id.present ? data.id.value : this.id,
      portions: data.portions.present ? data.portions.value : this.portions,
      mealCount: data.mealCount.present ? data.mealCount.value : this.mealCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlan(')
          ..write('id: $id, ')
          ..write('portions: $portions, ')
          ..write('mealCount: $mealCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, portions, mealCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyPlan &&
          other.id == this.id &&
          other.portions == this.portions &&
          other.mealCount == this.mealCount &&
          other.createdAt == this.createdAt);
}

class WeeklyPlansCompanion extends UpdateCompanion<WeeklyPlan> {
  final Value<int> id;
  final Value<int> portions;
  final Value<int> mealCount;
  final Value<DateTime> createdAt;
  const WeeklyPlansCompanion({
    this.id = const Value.absent(),
    this.portions = const Value.absent(),
    this.mealCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WeeklyPlansCompanion.insert({
    this.id = const Value.absent(),
    required int portions,
    required int mealCount,
    this.createdAt = const Value.absent(),
  }) : portions = Value(portions),
       mealCount = Value(mealCount);
  static Insertable<WeeklyPlan> custom({
    Expression<int>? id,
    Expression<int>? portions,
    Expression<int>? mealCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (portions != null) 'portions': portions,
      if (mealCount != null) 'meal_count': mealCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WeeklyPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? portions,
    Value<int>? mealCount,
    Value<DateTime>? createdAt,
  }) {
    return WeeklyPlansCompanion(
      id: id ?? this.id,
      portions: portions ?? this.portions,
      mealCount: mealCount ?? this.mealCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (portions.present) {
      map['portions'] = Variable<int>(portions.value);
    }
    if (mealCount.present) {
      map['meal_count'] = Variable<int>(mealCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlansCompanion(')
          ..write('id: $id, ')
          ..write('portions: $portions, ')
          ..write('mealCount: $mealCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SuggestionsTable extends Suggestions
    with TableInfo<$SuggestionsTable, Suggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuggestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weeklyPlanIdMeta = const VerificationMeta(
    'weeklyPlanId',
  );
  @override
  late final GeneratedColumn<int> weeklyPlanId = GeneratedColumn<int>(
    'weekly_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES weekly_plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotIndexMeta = const VerificationMeta(
    'slotIndex',
  );
  @override
  late final GeneratedColumn<int> slotIndex = GeneratedColumn<int>(
    'slot_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FilledVia?, String> filledVia =
      GeneratedColumn<String>(
        'filled_via',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<FilledVia?>($SuggestionsTable.$converterfilledVian);
  @override
  late final GeneratedColumnWithTypeConverter<SuggestionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => SuggestionStatus.pending.name,
      ).withConverter<SuggestionStatus>($SuggestionsTable.$converterstatus);
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
    clientDefault: () => DateTime.now(),
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weeklyPlanId,
    slotIndex,
    recipeId,
    filledVia,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Suggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weekly_plan_id')) {
      context.handle(
        _weeklyPlanIdMeta,
        weeklyPlanId.isAcceptableOrUnknown(
          data['weekly_plan_id']!,
          _weeklyPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weeklyPlanIdMeta);
    }
    if (data.containsKey('slot_index')) {
      context.handle(
        _slotIndexMeta,
        slotIndex.isAcceptableOrUnknown(data['slot_index']!, _slotIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIndexMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Suggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Suggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weeklyPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_plan_id'],
      )!,
      slotIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_index'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      ),
      filledVia: $SuggestionsTable.$converterfilledVian.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}filled_via'],
        ),
      ),
      status: $SuggestionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SuggestionsTable createAlias(String alias) {
    return $SuggestionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FilledVia, String, String> $converterfilledVia =
      const EnumNameConverter<FilledVia>(FilledVia.values);
  static JsonTypeConverter2<FilledVia?, String?, String?> $converterfilledVian =
      JsonTypeConverter2.asNullable($converterfilledVia);
  static JsonTypeConverter2<SuggestionStatus, String, String> $converterstatus =
      const EnumNameConverter<SuggestionStatus>(SuggestionStatus.values);
}

class Suggestion extends DataClass implements Insertable<Suggestion> {
  final int id;
  final int weeklyPlanId;

  /// 0-based position within the week — display order, not a meaning.
  final int slotIndex;

  /// Null until filled — a slot can exist before generation completes.
  final int? recipeId;
  final FilledVia? filledVia;
  final SuggestionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Suggestion({
    required this.id,
    required this.weeklyPlanId,
    required this.slotIndex,
    this.recipeId,
    this.filledVia,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weekly_plan_id'] = Variable<int>(weeklyPlanId);
    map['slot_index'] = Variable<int>(slotIndex);
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<int>(recipeId);
    }
    if (!nullToAbsent || filledVia != null) {
      map['filled_via'] = Variable<String>(
        $SuggestionsTable.$converterfilledVian.toSql(filledVia),
      );
    }
    {
      map['status'] = Variable<String>(
        $SuggestionsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuggestionsCompanion toCompanion(bool nullToAbsent) {
    return SuggestionsCompanion(
      id: Value(id),
      weeklyPlanId: Value(weeklyPlanId),
      slotIndex: Value(slotIndex),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      filledVia: filledVia == null && nullToAbsent
          ? const Value.absent()
          : Value(filledVia),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Suggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Suggestion(
      id: serializer.fromJson<int>(json['id']),
      weeklyPlanId: serializer.fromJson<int>(json['weeklyPlanId']),
      slotIndex: serializer.fromJson<int>(json['slotIndex']),
      recipeId: serializer.fromJson<int?>(json['recipeId']),
      filledVia: $SuggestionsTable.$converterfilledVian.fromJson(
        serializer.fromJson<String?>(json['filledVia']),
      ),
      status: $SuggestionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weeklyPlanId': serializer.toJson<int>(weeklyPlanId),
      'slotIndex': serializer.toJson<int>(slotIndex),
      'recipeId': serializer.toJson<int?>(recipeId),
      'filledVia': serializer.toJson<String?>(
        $SuggestionsTable.$converterfilledVian.toJson(filledVia),
      ),
      'status': serializer.toJson<String>(
        $SuggestionsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Suggestion copyWith({
    int? id,
    int? weeklyPlanId,
    int? slotIndex,
    Value<int?> recipeId = const Value.absent(),
    Value<FilledVia?> filledVia = const Value.absent(),
    SuggestionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Suggestion(
    id: id ?? this.id,
    weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
    slotIndex: slotIndex ?? this.slotIndex,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    filledVia: filledVia.present ? filledVia.value : this.filledVia,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Suggestion copyWithCompanion(SuggestionsCompanion data) {
    return Suggestion(
      id: data.id.present ? data.id.value : this.id,
      weeklyPlanId: data.weeklyPlanId.present
          ? data.weeklyPlanId.value
          : this.weeklyPlanId,
      slotIndex: data.slotIndex.present ? data.slotIndex.value : this.slotIndex,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      filledVia: data.filledVia.present ? data.filledVia.value : this.filledVia,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Suggestion(')
          ..write('id: $id, ')
          ..write('weeklyPlanId: $weeklyPlanId, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('recipeId: $recipeId, ')
          ..write('filledVia: $filledVia, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weeklyPlanId,
    slotIndex,
    recipeId,
    filledVia,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Suggestion &&
          other.id == this.id &&
          other.weeklyPlanId == this.weeklyPlanId &&
          other.slotIndex == this.slotIndex &&
          other.recipeId == this.recipeId &&
          other.filledVia == this.filledVia &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuggestionsCompanion extends UpdateCompanion<Suggestion> {
  final Value<int> id;
  final Value<int> weeklyPlanId;
  final Value<int> slotIndex;
  final Value<int?> recipeId;
  final Value<FilledVia?> filledVia;
  final Value<SuggestionStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SuggestionsCompanion({
    this.id = const Value.absent(),
    this.weeklyPlanId = const Value.absent(),
    this.slotIndex = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.filledVia = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SuggestionsCompanion.insert({
    this.id = const Value.absent(),
    required int weeklyPlanId,
    required int slotIndex,
    this.recipeId = const Value.absent(),
    this.filledVia = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : weeklyPlanId = Value(weeklyPlanId),
       slotIndex = Value(slotIndex);
  static Insertable<Suggestion> custom({
    Expression<int>? id,
    Expression<int>? weeklyPlanId,
    Expression<int>? slotIndex,
    Expression<int>? recipeId,
    Expression<String>? filledVia,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weeklyPlanId != null) 'weekly_plan_id': weeklyPlanId,
      if (slotIndex != null) 'slot_index': slotIndex,
      if (recipeId != null) 'recipe_id': recipeId,
      if (filledVia != null) 'filled_via': filledVia,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SuggestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? weeklyPlanId,
    Value<int>? slotIndex,
    Value<int?>? recipeId,
    Value<FilledVia?>? filledVia,
    Value<SuggestionStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SuggestionsCompanion(
      id: id ?? this.id,
      weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
      slotIndex: slotIndex ?? this.slotIndex,
      recipeId: recipeId ?? this.recipeId,
      filledVia: filledVia ?? this.filledVia,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weeklyPlanId.present) {
      map['weekly_plan_id'] = Variable<int>(weeklyPlanId.value);
    }
    if (slotIndex.present) {
      map['slot_index'] = Variable<int>(slotIndex.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (filledVia.present) {
      map['filled_via'] = Variable<String>(
        $SuggestionsTable.$converterfilledVian.toSql(filledVia.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SuggestionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('weeklyPlanId: $weeklyPlanId, ')
          ..write('slotIndex: $slotIndex, ')
          ..write('recipeId: $recipeId, ')
          ..write('filledVia: $filledVia, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $WeeklyPlansTable weeklyPlans = $WeeklyPlansTable(this);
  late final $SuggestionsTable suggestions = $SuggestionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    recipes,
    recipeIngredients,
    weeklyPlans,
    suggestions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_ingredients', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'weekly_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.update)],
    ),
  ]);
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
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  Value<int> id,
  required String title,
  required int serves,
  required String method,
  Value<bool> editedByUser,
  Value<int?> kcalPerPortion,
  Value<double?> proteinGPerPortion,
  Value<double?> fatGPerPortion,
  Value<double?> carbsGPerPortion,
  required RecipeSource source,
  Value<String?> cuisine,
  Value<int?> timeMinutes,
  Value<RecipeDifficulty?> difficulty,
  Value<String?> primaryProtein,
  Value<String?> cookingMethod,
  Value<DateTime> createdAt,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int> serves,
  Value<String> method,
  Value<bool> editedByUser,
  Value<int?> kcalPerPortion,
  Value<double?> proteinGPerPortion,
  Value<double?> fatGPerPortion,
  Value<double?> carbsGPerPortion,
  Value<RecipeSource> source,
  Value<String?> cuisine,
  Value<int?> timeMinutes,
  Value<RecipeDifficulty?> difficulty,
  Value<String?> primaryProtein,
  Value<String?> cookingMethod,
  Value<DateTime> createdAt,
});

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: 'recipes__id__recipe_ingredients__recipe_id',
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SuggestionsTable, List<Suggestion>>
  _suggestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suggestions,
    aliasName: 'recipes__id__suggestions__recipe_id',
  );

  $$SuggestionsTableProcessedTableManager get suggestionsRefs {
    final manager = $$SuggestionsTableTableManager(
      $_db,
      $_db.suggestions,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_suggestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serves => $composableBuilder(
    column: $table.serves,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get editedByUser => $composableBuilder(
    column: $table.editedByUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcalPerPortion => $composableBuilder(
    column: $table.kcalPerPortion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGPerPortion => $composableBuilder(
    column: $table.proteinGPerPortion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGPerPortion => $composableBuilder(
    column: $table.fatGPerPortion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGPerPortion => $composableBuilder(
    column: $table.carbsGPerPortion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecipeSource, RecipeSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get cuisine => $composableBuilder(
    column: $table.cuisine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecipeDifficulty?, RecipeDifficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get primaryProtein => $composableBuilder(
    column: $table.primaryProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> suggestionsRefs(
    Expression<bool> Function($$SuggestionsTableFilterComposer f) f,
  ) {
    final $$SuggestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableFilterComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serves => $composableBuilder(
    column: $table.serves,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get editedByUser => $composableBuilder(
    column: $table.editedByUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcalPerPortion => $composableBuilder(
    column: $table.kcalPerPortion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGPerPortion => $composableBuilder(
    column: $table.proteinGPerPortion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGPerPortion => $composableBuilder(
    column: $table.fatGPerPortion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGPerPortion => $composableBuilder(
    column: $table.carbsGPerPortion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuisine => $composableBuilder(
    column: $table.cuisine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryProtein => $composableBuilder(
    column: $table.primaryProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get serves =>
      $composableBuilder(column: $table.serves, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<bool> get editedByUser => $composableBuilder(
    column: $table.editedByUser,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kcalPerPortion => $composableBuilder(
    column: $table.kcalPerPortion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGPerPortion => $composableBuilder(
    column: $table.proteinGPerPortion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGPerPortion => $composableBuilder(
    column: $table.fatGPerPortion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGPerPortion => $composableBuilder(
    column: $table.carbsGPerPortion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RecipeSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get cuisine =>
      $composableBuilder(column: $table.cuisine, builder: (column) => column);

  GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RecipeDifficulty?, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<String> get primaryProtein => $composableBuilder(
    column: $table.primaryProtein,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.recipeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> suggestionsRefs<T extends Object>(
    Expression<T> Function($$SuggestionsTableAnnotationComposer a) f,
  ) {
    final $$SuggestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({
            bool recipeIngredientsRefs,
            bool suggestionsRefs,
          })
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> serves = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<bool> editedByUser = const Value.absent(),
                Value<int?> kcalPerPortion = const Value.absent(),
                Value<double?> proteinGPerPortion = const Value.absent(),
                Value<double?> fatGPerPortion = const Value.absent(),
                Value<double?> carbsGPerPortion = const Value.absent(),
                Value<RecipeSource> source = const Value.absent(),
                Value<String?> cuisine = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<RecipeDifficulty?> difficulty = const Value.absent(),
                Value<String?> primaryProtein = const Value.absent(),
                Value<String?> cookingMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                title: title,
                serves: serves,
                method: method,
                editedByUser: editedByUser,
                kcalPerPortion: kcalPerPortion,
                proteinGPerPortion: proteinGPerPortion,
                fatGPerPortion: fatGPerPortion,
                carbsGPerPortion: carbsGPerPortion,
                source: source,
                cuisine: cuisine,
                timeMinutes: timeMinutes,
                difficulty: difficulty,
                primaryProtein: primaryProtein,
                cookingMethod: cookingMethod,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int serves,
                required String method,
                Value<bool> editedByUser = const Value.absent(),
                Value<int?> kcalPerPortion = const Value.absent(),
                Value<double?> proteinGPerPortion = const Value.absent(),
                Value<double?> fatGPerPortion = const Value.absent(),
                Value<double?> carbsGPerPortion = const Value.absent(),
                required RecipeSource source,
                Value<String?> cuisine = const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<RecipeDifficulty?> difficulty = const Value.absent(),
                Value<String?> primaryProtein = const Value.absent(),
                Value<String?> cookingMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                title: title,
                serves: serves,
                method: method,
                editedByUser: editedByUser,
                kcalPerPortion: kcalPerPortion,
                proteinGPerPortion: proteinGPerPortion,
                fatGPerPortion: fatGPerPortion,
                carbsGPerPortion: carbsGPerPortion,
                source: source,
                cuisine: cuisine,
                timeMinutes: timeMinutes,
                difficulty: difficulty,
                primaryProtein: primaryProtein,
                cookingMethod: cookingMethod,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recipeIngredientsRefs = false, suggestionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (suggestionsRefs) db.suggestions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (suggestionsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          Suggestion
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._suggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).suggestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
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

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({bool recipeIngredientsRefs, bool suggestionsRefs})
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required int recipeId,
      required int sortOrder,
      required String name,
      Value<double?> quantity,
      Value<IngredientUnit?> unit,
      Value<String?> note,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int> sortOrder,
      Value<String> name,
      Value<double?> quantity,
      Value<IngredientUnit?> unit,
      Value<String?> note,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        > {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_ingredients__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IngredientUnit?, IngredientUnit, String>
  get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IngredientUnit?, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (RecipeIngredient, $$RecipeIngredientsTableReferences),
          RecipeIngredient,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<IngredientUnit?> unit = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                sortOrder: sortOrder,
                name: name,
                quantity: quantity,
                unit: unit,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required int sortOrder,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<IngredientUnit?> unit = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                sortOrder: sortOrder,
                name: name,
                quantity: quantity,
                unit: unit,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
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
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$RecipeIngredientsTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$RecipeIngredientsTableReferences
                            ._recipeIdTable(db)
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

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (RecipeIngredient, $$RecipeIngredientsTableReferences),
      RecipeIngredient,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$WeeklyPlansTableCreateCompanionBuilder =
    WeeklyPlansCompanion Function({
      Value<int> id,
      required int portions,
      required int mealCount,
      Value<DateTime> createdAt,
    });
typedef $$WeeklyPlansTableUpdateCompanionBuilder =
    WeeklyPlansCompanion Function({
      Value<int> id,
      Value<int> portions,
      Value<int> mealCount,
      Value<DateTime> createdAt,
    });

final class $$WeeklyPlansTableReferences
    extends BaseReferences<_$AppDatabase, $WeeklyPlansTable, WeeklyPlan> {
  $$WeeklyPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SuggestionsTable, List<Suggestion>>
  _suggestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suggestions,
    aliasName: 'weekly_plans__id__suggestions__weekly_plan_id',
  );

  $$SuggestionsTableProcessedTableManager get suggestionsRefs {
    final manager = $$SuggestionsTableTableManager(
      $_db,
      $_db.suggestions,
    ).filter((f) => f.weeklyPlanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_suggestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WeeklyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyPlansTable> {
  $$WeeklyPlansTableFilterComposer({
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

  ColumnFilters<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealCount => $composableBuilder(
    column: $table.mealCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> suggestionsRefs(
    Expression<bool> Function($$SuggestionsTableFilterComposer f) f,
  ) {
    final $$SuggestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.weeklyPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableFilterComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WeeklyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyPlansTable> {
  $$WeeklyPlansTableOrderingComposer({
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

  ColumnOrderings<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealCount => $composableBuilder(
    column: $table.mealCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyPlansTable> {
  $$WeeklyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get portions =>
      $composableBuilder(column: $table.portions, builder: (column) => column);

  GeneratedColumn<int> get mealCount =>
      $composableBuilder(column: $table.mealCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> suggestionsRefs<T extends Object>(
    Expression<T> Function($$SuggestionsTableAnnotationComposer a) f,
  ) {
    final $$SuggestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suggestions,
      getReferencedColumn: (t) => t.weeklyPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuggestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.suggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WeeklyPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyPlansTable,
          WeeklyPlan,
          $$WeeklyPlansTableFilterComposer,
          $$WeeklyPlansTableOrderingComposer,
          $$WeeklyPlansTableAnnotationComposer,
          $$WeeklyPlansTableCreateCompanionBuilder,
          $$WeeklyPlansTableUpdateCompanionBuilder,
          (WeeklyPlan, $$WeeklyPlansTableReferences),
          WeeklyPlan,
          PrefetchHooks Function({bool suggestionsRefs})
        > {
  $$WeeklyPlansTableTableManager(_$AppDatabase db, $WeeklyPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> portions = const Value.absent(),
                Value<int> mealCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeeklyPlansCompanion(
                id: id,
                portions: portions,
                mealCount: mealCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int portions,
                required int mealCount,
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeeklyPlansCompanion.insert(
                id: id,
                portions: portions,
                mealCount: mealCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WeeklyPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({suggestionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (suggestionsRefs) db.suggestions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (suggestionsRefs)
                    await $_getPrefetchedData<
                      WeeklyPlan,
                      $WeeklyPlansTable,
                      Suggestion
                    >(
                      currentTable: table,
                      referencedTable: $$WeeklyPlansTableReferences
                          ._suggestionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WeeklyPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).suggestionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.weeklyPlanId == item.id,
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

typedef $$WeeklyPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyPlansTable,
      WeeklyPlan,
      $$WeeklyPlansTableFilterComposer,
      $$WeeklyPlansTableOrderingComposer,
      $$WeeklyPlansTableAnnotationComposer,
      $$WeeklyPlansTableCreateCompanionBuilder,
      $$WeeklyPlansTableUpdateCompanionBuilder,
      (WeeklyPlan, $$WeeklyPlansTableReferences),
      WeeklyPlan,
      PrefetchHooks Function({bool suggestionsRefs})
    >;
typedef $$SuggestionsTableCreateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      required int weeklyPlanId,
      required int slotIndex,
      Value<int?> recipeId,
      Value<FilledVia?> filledVia,
      Value<SuggestionStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$SuggestionsTableUpdateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      Value<int> weeklyPlanId,
      Value<int> slotIndex,
      Value<int?> recipeId,
      Value<FilledVia?> filledVia,
      Value<SuggestionStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SuggestionsTableReferences
    extends BaseReferences<_$AppDatabase, $SuggestionsTable, Suggestion> {
  $$SuggestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WeeklyPlansTable _weeklyPlanIdTable(_$AppDatabase db) => db
      .weeklyPlans
      .createAlias('suggestions__weekly_plan_id__weekly_plans__id');

  $$WeeklyPlansTableProcessedTableManager get weeklyPlanId {
    final $_column = $_itemColumn<int>('weekly_plan_id')!;

    final manager = $$WeeklyPlansTableTableManager(
      $_db,
      $_db.weeklyPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_weeklyPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('suggestions__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager? get recipeId {
    final $_column = $_itemColumn<int>('recipe_id');
    if ($_column == null) return null;
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableFilterComposer({
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

  ColumnFilters<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FilledVia?, FilledVia, String> get filledVia =>
      $composableBuilder(
        column: $table.filledVia,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SuggestionStatus, SuggestionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WeeklyPlansTableFilterComposer get weeklyPlanId {
    final $$WeeklyPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyPlanId,
      referencedTable: $db.weeklyPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyPlansTableFilterComposer(
            $db: $db,
            $table: $db.weeklyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableOrderingComposer({
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

  ColumnOrderings<int> get slotIndex => $composableBuilder(
    column: $table.slotIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filledVia => $composableBuilder(
    column: $table.filledVia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

  $$WeeklyPlansTableOrderingComposer get weeklyPlanId {
    final $$WeeklyPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyPlanId,
      referencedTable: $db.weeklyPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyPlansTableOrderingComposer(
            $db: $db,
            $table: $db.weeklyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotIndex =>
      $composableBuilder(column: $table.slotIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FilledVia?, String> get filledVia =>
      $composableBuilder(column: $table.filledVia, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SuggestionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WeeklyPlansTableAnnotationComposer get weeklyPlanId {
    final $$WeeklyPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyPlanId,
      referencedTable: $db.weeklyPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WeeklyPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.weeklyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuggestionsTable,
          Suggestion,
          $$SuggestionsTableFilterComposer,
          $$SuggestionsTableOrderingComposer,
          $$SuggestionsTableAnnotationComposer,
          $$SuggestionsTableCreateCompanionBuilder,
          $$SuggestionsTableUpdateCompanionBuilder,
          (Suggestion, $$SuggestionsTableReferences),
          Suggestion,
          PrefetchHooks Function({bool weeklyPlanId, bool recipeId})
        > {
  $$SuggestionsTableTableManager(_$AppDatabase db, $SuggestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> weeklyPlanId = const Value.absent(),
                Value<int> slotIndex = const Value.absent(),
                Value<int?> recipeId = const Value.absent(),
                Value<FilledVia?> filledVia = const Value.absent(),
                Value<SuggestionStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SuggestionsCompanion(
                id: id,
                weeklyPlanId: weeklyPlanId,
                slotIndex: slotIndex,
                recipeId: recipeId,
                filledVia: filledVia,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int weeklyPlanId,
                required int slotIndex,
                Value<int?> recipeId = const Value.absent(),
                Value<FilledVia?> filledVia = const Value.absent(),
                Value<SuggestionStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SuggestionsCompanion.insert(
                id: id,
                weeklyPlanId: weeklyPlanId,
                slotIndex: slotIndex,
                recipeId: recipeId,
                filledVia: filledVia,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuggestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({weeklyPlanId = false, recipeId = false}) {
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
                    if (weeklyPlanId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.weeklyPlanId,
                        referencedTable: $$SuggestionsTableReferences
                            ._weeklyPlanIdTable(db),
                        referencedColumn: $$SuggestionsTableReferences
                            ._weeklyPlanIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$SuggestionsTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$SuggestionsTableReferences
                            ._recipeIdTable(db)
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

typedef $$SuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuggestionsTable,
      Suggestion,
      $$SuggestionsTableFilterComposer,
      $$SuggestionsTableOrderingComposer,
      $$SuggestionsTableAnnotationComposer,
      $$SuggestionsTableCreateCompanionBuilder,
      $$SuggestionsTableUpdateCompanionBuilder,
      (Suggestion, $$SuggestionsTableReferences),
      Suggestion,
      PrefetchHooks Function({bool weeklyPlanId, bool recipeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$WeeklyPlansTableTableManager get weeklyPlans =>
      $$WeeklyPlansTableTableManager(_db, _db.weeklyPlans);
  $$SuggestionsTableTableManager get suggestions =>
      $$SuggestionsTableTableManager(_db, _db.suggestions);
}
