package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class MaintainConfigRepository {

    // read
    private val getSwitchTimesCmd: ByteArray = byteArrayOf(0x10, 0x86.toByte(), 0x00, 0x06)

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private var setSwitchTimesCmd: ByteArray = byteArrayOf(0x10, 0x86.toByte(), 0x00, 0x02, 0x04)
    private var setTorqueTimesCmd: ByteArray = byteArrayOf(0x10, 0x88.toByte(), 0x00, 0x02, 0x04)
    private var setMotorWorkTimeCmd: ByteArray = byteArrayOf(0x10, 0x8A.toByte(), 0x00, 0x02, 0x04)

    var isCanWrite: Boolean = false

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    fun getSwitchTimes() {
        MyApplication.writeData(getSwitchTimesCmd, callback, false)
    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: String) {
        when (index) {
            0 -> formatIntData(setSwitchTimesCmd, value)
            1 -> formatIntData(setTorqueTimesCmd, value)
            2 -> formatIntData(setMotorWorkTimeCmd, value)
        }
    }

    private fun formatIntData(cmd: ByteArray, data: String) {
        val dataCmd: ArrayList<Byte> = cmd.copyOf().toList() as ArrayList<Byte>

        val dataBytes: ByteArray = ConvertUtil.int2Bytes(data.toInt(), true)

        for (i in dataBytes.indices step 2) {
            dataCmd.add(dataBytes[i + 1])
            dataCmd.add(dataBytes[i])
        }

        setData(dataCmd.toByteArray())
    }

    private fun setData(cmd: ByteArray) {
        MyApplication.writeData(cmd, callback, true)
    }
}