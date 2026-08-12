package com.gusteau.gusteau

import android.app.backup.BackupAgentHelper
import android.app.backup.FullBackupDataOutput
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.io.File

/**
 * Forces a SQLite WAL checkpoint immediately before Android's Auto
 * Backup takes its file snapshot.
 *
 * Without this, Auto Backup can copy the main database file while
 * recent commits are still sitting in the -wal sidecar (drift/sqlite3
 * use WAL mode by default) — producing a stale or corrupt restore,
 * with no error raised at backup time. See
 * docs/planning/architecture.md, "Backup and durability", which flags
 * this as the single most important implementation detail in the
 * whole backup story.
 *
 * res/xml/data_extraction_rules.xml and backup_rules.xml only ever
 * include the main .sqlite file, never the -wal/-shm sidecars, so once
 * this checkpoint has run, that file is self-contained and consistent
 * on its own.
 *
 * Auto Backup runs this in the app's own process, so PRAGMA
 * wal_checkpoint here is an ordinary same-process SQLite call, not a
 * cross-process one.
 */
class GusteauBackupAgent : BackupAgentHelper() {
    override fun onFullBackup(data: FullBackupDataOutput) {
        checkpointDatabaseBeforeBackup()
        super.onFullBackup(data)
    }

    private fun checkpointDatabaseBeforeBackup() {
        val dbFile = File(filesDir, DATABASE_FILE_NAME)
        if (!dbFile.exists()) return

        try {
            SQLiteDatabase.openDatabase(
                dbFile.path,
                null,
                SQLiteDatabase.OPEN_READWRITE,
            ).use { db ->
                // TRUNCATE (not PASSIVE/FULL): forces every committed
                // -wal frame into the main database file and truncates
                // the -wal file to empty, so the main file becomes the
                // single, complete, self-contained copy that the
                // backup rules above are about to snapshot.
                db.rawQuery("PRAGMA wal_checkpoint(TRUNCATE);", null).use { it.moveToFirst() }
            }
        } catch (e: Exception) {
            // Never let a checkpoint failure block the backup outright
            // — a slightly-stale backup is still far better than none.
            Log.w(TAG, "WAL checkpoint before backup failed; backup will proceed anyway", e)
        }
    }

    companion object {
        private const val TAG = "GusteauBackupAgent"

        // Must match kDatabaseFileName in lib/data/database.dart, and
        // the `path` in res/xml/data_extraction_rules.xml and
        // backup_rules.xml. Checked by
        // test/android_backup_config_test.dart, which reads this file
        // as text rather than compiling it — this repo has no way to
        // build/run Kotlin unit tests without an Android SDK, so CI's
        // `flutter build apk` (which does have one) is the first real
        // compile check this class gets.
        const val DATABASE_FILE_NAME = "gusteau.sqlite"
    }
}
