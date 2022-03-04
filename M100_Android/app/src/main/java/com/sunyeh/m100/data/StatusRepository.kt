package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class StatusRepository {

    // read
    private val getStatusCmd: ByteArray = byteArrayOf(0x10, 0x0E, 0x00, 0x04)

    var statusCode: ArrayList<Int> = ArrayList()

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    fun getSystemStatus() {
        MyApplication.writeData(getStatusCmd, callback, false)
    }
}