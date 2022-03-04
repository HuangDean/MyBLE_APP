package com.sunyeh.m100.data

import android.util.Log
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import java.nio.charset.StandardCharsets

class RemoteControlRepository {

    // read
    private val getValveRealPositionCmd: ByteArray = byteArrayOf(0x10, 0x06, 0x00, 0x56) // 12: 4102~4187

    var isCanTapped: Boolean = true // 防止按鈕按過快

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    fun getValveRealPosition() {
        MyApplication.writeData(getValveRealPositionCmd, callback, false, "remote 1")
    }

    fun exit() {
        if (!isCanTapped) return
        isCanTapped = false

        MyApplication.writeData("cmd_esc".toByteArray(StandardCharsets.UTF_8), callback, "exit")
    }

    fun prev() {
        if (!isCanTapped) return
        isCanTapped = false

        MyApplication.writeData("cmd_up".toByteArray(StandardCharsets.UTF_8), callback, "prev")
    }

    fun next() {
        if (!isCanTapped) return
        isCanTapped = false

        MyApplication.writeData("cmd_shift".toByteArray(StandardCharsets.UTF_8), callback, "next")
    }

    fun enter() {
        if (!isCanTapped) return
        isCanTapped = false

        MyApplication.writeData("cmd_enter".toByteArray(StandardCharsets.UTF_8), callback, "enter")
    }

    fun up() {
        MyApplication.writeData("cmd_keyclr".toByteArray(StandardCharsets.UTF_8), callback, "up")
    }
}