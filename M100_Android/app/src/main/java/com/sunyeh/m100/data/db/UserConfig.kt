package com.sunyeh.m100.data.db

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase

object UserConfig {

    private var writeDbHelper: DbCreateHelper? = null
    private var readDbHelper: DbCreateHelper? = null

    @Synchronized
    private fun getDb(context: Context, writable: Boolean): SQLiteDatabase {
        val result: SQLiteDatabase

        synchronized(DbCreateHelper::class.java) {
            if (writable) {
                if (writeDbHelper == null) {
                    writeDbHelper = DbCreateHelper(context)
                    val db = writeDbHelper!!.writableDatabase
                    writeDbHelper!!.onCreate(db)
                    db.close()
                }

                result = writeDbHelper!!.writableDatabase
            } else {
                if (readDbHelper == null) {
                    readDbHelper = DbCreateHelper(context)
                    val db = readDbHelper!!.writableDatabase
                    readDbHelper!!.onCreate(db)
                    db.close()
                }

                result = readDbHelper!!.readableDatabase
            }
        }

        return result
    }

    @Synchronized
    private fun setValue(context: Context, id: String, value: String) {
        val db = getDb(context, true)

        val values = ContentValues()
        values.put("id", id)
        values.put("value", value)
        db.insert(DbCreateHelper.TABLE_NAME, null, values)
        db.close()
    }

    @Synchronized
    private fun getValue(context: Context, id: String): String {
        val db = getDb(context, false)

        var result = ""
        val cursor = db.rawQuery("SELECT value FROM UserConfig WHERE id='$id';", null)
        if (cursor.moveToFirst()) {
            if (!cursor.isNull(0)) {
                result = cursor.getString(0)
            }
        }

        cursor.close()
        db.close()
        return result
    }

    fun getPermission(context: Context): String {
        return getValue(context, "permission")
    }

    fun setPermission(context: Context, permission: Int) {
        setValue(context, "permission", permission.toString())
    }

    fun getPassword(context: Context): String {
        return getValue(context, "password")
    }

    fun setPassword(context: Context, password: String) {
        setValue(context, "password", password)
    }

    fun getDeviceName(context: Context): String {
        return getValue(context, "deviceName")
    }

    fun setDeviceName(context: Context, deviceName: String) {
        setValue(context, "deviceName", deviceName)
    }

    fun getMacAddress(context: Context): String {
        return getValue(context, "address")
    }

    fun setMacAddress(context: Context, address: String) {
        setValue(context, "address", address)
    }
}