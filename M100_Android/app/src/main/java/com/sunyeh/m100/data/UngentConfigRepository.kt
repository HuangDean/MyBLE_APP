package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class UngentConfigRepository {

    // read
    private val getMotorTempeatureAlarmCmd: ByteArray = byteArrayOf(0x10, 0x8E.toByte(), 0x00, 0x1B) // 4238~4264

//    private val getMotorTempeatureAlarmCmd: ByteArray = byteArrayOf(0x10, 0x8E.toByte(), 0x00, 0x02) // 4238~4239
//    private val getOpenSignalActionCmd: ByteArray = byteArrayOf(0x10, 0x9A.toByte(), 0x00, 0x01) // 4250
//    private val getUngentActionModeCmd: ByteArray = byteArrayOf(0x10, 0x9D.toByte(), 0x00, 0x03) // 4253~4254 num實際2
//    private val getUngentInputModeCmd: ByteArray = byteArrayOf(0x10, 0xA8.toByte(), 0x00, 0x04) // 4264 num實際1

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private val saveOpenSignalActionCmd: ByteArray = byteArrayOf(0x10, 0x9D.toByte(), 0x00, 0x01, 0x02)
    private val setUngentActionCmd: ByteArray = byteArrayOf(0x10, 0x9E.toByte(), 0x00, 0x01, 0x02)
    private val setSignalUngentCmd: ByteArray = byteArrayOf(0x10, 0x9A.toByte(), 0x00, 0x01, 0x02)
    private val setMotorWarningSwitchCmd: ByteArray = byteArrayOf(0x10, 0x8F.toByte(), 0x00, 0x01, 0x02)
    private val setMotorWarningTempCmd: ByteArray = byteArrayOf(0x10, 0x8E.toByte(), 0x00, 0x01, 0x02)
    private val setUngentInputSwitchCmd: ByteArray = byteArrayOf(0x10, 0xA8.toByte(), 0x00, 0x01, 0x02)

    var isCanWrite: Boolean = false

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    fun getMotorTempeatureAlarm() {
        MyApplication.writeData(getMotorTempeatureAlarmCmd, callback, false)
    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: String) {
        when (index) {
            0 -> formatIntData(saveOpenSignalActionCmd, value)
            1 -> formatIntData(setUngentActionCmd, value)
            2 -> formatIntData(setSignalUngentCmd, value)
            3 -> formatIntData(setMotorWarningSwitchCmd, value)
            4 -> formatIntData(setMotorWarningTempCmd, value)
            5 -> formatIntData(setUngentInputSwitchCmd, value)
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