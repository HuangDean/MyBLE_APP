package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class MaintainRepository {

    // read
    private val getMotorRemainingCmd: ByteArray = byteArrayOf(0x10, 0x2C, 0x00, 0x16)

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    fun getMotorRemaining() {
        MyApplication.writeData(getMotorRemainingCmd, callback, false)
    }
}