package com.sunyeh.m100.data.db

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DbCreateHelper internal constructor(context: Context) :
    SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(CREATE_TABLE)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $DATABASE_NAME")
        onCreate(db)
    }

    companion object {

        private const val DATABASE_NAME = "M100.db"
        private const val DATABASE_VERSION = 1

        internal var TABLE_NAME = "UserConfig"

        private const val CREATE_TABLE = "CREATE TABLE IF NOT EXISTS UserConfig (" +
                "id TEXT PRIMARY KEY ON CONFLICT REPLACE, " +
                "value TEXT" +
                ");"
    }
}