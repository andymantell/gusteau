import 'package:drift/drift.dart';

/// Household-wide settings — deliberately a single row (id is always 0).
///
/// There is no `Household` or `User` table: the device is the user, so
/// there's nothing to scope these to. See docs/planning/decisions.md,
/// "One install, one user: the device is the 'user'".
class Settings extends Table {
  // NOTE: this DEFAULT is documentation, not a working safety net.
  // As the sole INTEGER PRIMARY KEY column, `id` is a SQLite rowid
  // alias, and rowid aliases ignore their column DEFAULT on insert —
  // SQLite auto-assigns the next rowid instead. Any code that inserts
  // a Settings row MUST pass `id: Value(0)` explicitly. See the
  // onCreate comment in database.dart.
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// Default portions per meal. Overridable per week — see
  /// docs/planning/architecture.md, "Portions and recipe scaling".
  IntColumn get defaultPortions => integer().withDefault(const Constant(4))();

  /// Default number of meals to suggest per week. Overridable per week.
  IntColumn get defaultMealsPerWeek =>
      integer().withDefault(const Constant(5))();

  /// How many weeks a recipe stays out of unprompted suggestions after
  /// being cooked. See architecture.md, "Repeat cooldown".
  IntColumn get repeatCooldownWeeks =>
      integer().withDefault(const Constant(6))();

  /// Weekly planning-nudge day, using [DateTime.weekday] convention
  /// (1 = Monday .. 7 = Sunday). Null means the nudge is off, which is
  /// the default — see decisions.md, "Notifications".
  IntColumn get planningNudgeWeekday => integer().nullable()();

  /// Minutes since local midnight, rather than a wall-clock time, to
  /// sidestep timezone/DST storage edge cases. Null when the nudge is off.
  IntColumn get planningNudgeMinuteOfDay => integer().nullable()();

  /// When the owner last ran the system-file-picker export. Drives the
  /// staleness nudge in settings — see architecture.md, "Export/import
  /// via the system file picker". Added in schema v2.
  DateTimeColumn get lastExportedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
