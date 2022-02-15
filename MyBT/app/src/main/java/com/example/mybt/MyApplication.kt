package com.example.mybt

import android.Manifest
import android.app.Application
import android.content.Context
import android.util.Log
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.clj.fastble.utils.HexUtil
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class MyApplication: Application() {

    companion object {
        lateinit var context: Context

        const val SERVICE_UUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
        const val CHARACTERISTIC_UUID_WRITE: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
        const val CHARACTERISTIC_UUID_NOTIFY: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

        var bleDevice: BleDevice? = null
        var delegate: NotifyDelegate? = null


        // 每次寫入建議等300ms，建議不要再UI Thread
        fun writeData(cmd: ByteArray, callback: BleWriteCallback, isWrite: Boolean) {
            if (bleDevice == null) return
            if (!BleManager.getInstance().isConnected(bleDevice)) return

            var cmdBytes: ByteArray = if (isWrite) {
                byteArrayOf(0x01, 0x10, *cmd)
            } else {
                byteArrayOf(0x01, 0x03, *cmd)
            }

            //  cmdBytes = byteArrayOf(*cmdBytes, *getCRC(cmdBytes))
            Log.e("write cmd", HexUtil.formatHexString(cmdBytes, true))

            BleManager
                .getInstance()
                .write(bleDevice, SERVICE_UUID, CHARACTERISTIC_UUID_WRITE, cmdBytes, false, callback)
        }
    }

    override fun onCreate() {
        super.onCreate()

        context = applicationContext

        BleManager.getInstance().init(this)

        startKoin {
            androidContext(this@MyApplication)
            modules(mainModule)
        }
    }




}