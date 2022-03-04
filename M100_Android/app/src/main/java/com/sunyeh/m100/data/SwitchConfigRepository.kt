package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class SwitchConfigRepository {

    // read
    private val getValveOffOutputRpmCmd: ByteArray = byteArrayOf(0x10, 0x57.toByte(), 0x00, 0x4C) // 4183~4258

//    private val getValveOffOutputRpmCmd: ByteArray = byteArrayOf(0x10, 0x90.toByte(), 0x00, 0x13) // 4240~4258
//    private val getLimitOffPositionCmd: ByteArray = byteArrayOf(0x10, 0x57, 0x00, 0x04) // 4183 num:2 (limit position 表未更新

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private val setOutputRpmOffCmd: ByteArray = byteArrayOf(0x10, 0x90.toByte(), 0x00, 0x01, 0x02)
    private val setOutputRpmOnCmd: ByteArray = byteArrayOf(0x10, 0x91.toByte(), 0x00, 0x01, 0x02)
    private val setUngentRpmOffCmd: ByteArray = byteArrayOf(0x10, 0x92.toByte(), 0x00, 0x01, 0x02)
    private val setUngentRpmOnCmd: ByteArray = byteArrayOf(0x10, 0x93.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndTorqueOffCmd: ByteArray = byteArrayOf(0x10, 0x94.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndTorqueOnCmd: ByteArray = byteArrayOf(0x10, 0x95.toByte(), 0x00, 0x01, 0x02)
    private val setStrokeTorqueOffCmd: ByteArray = byteArrayOf(0x10, 0x96.toByte(), 0x00, 0x01, 0x02)
    private val setStrokeTorqueOnCmd: ByteArray = byteArrayOf(0x10, 0x97.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndOffCmd: ByteArray = byteArrayOf(0x10, 0x98.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndOnCmd: ByteArray = byteArrayOf(0x10, 0x99.toByte(), 0x00, 0x01, 0x02)
    private val setTorqueRetryOffCmd: ByteArray = byteArrayOf(0x10, 0x9B.toByte(), 0x00, 0x01, 0x02)
    private val setTorqueRetryOnCmd: ByteArray = byteArrayOf(0x10, 0x9C.toByte(), 0x00, 0x01, 0x02)
    private val setCloseDefinitionCmd: ByteArray = byteArrayOf(0x10, 0x9F.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndModeOffCmd: ByteArray = byteArrayOf(0x10, 0xA0.toByte(), 0x00, 0x01, 0x02)
    private val setRangeOfEndModeOnCmd: ByteArray = byteArrayOf(0x10, 0xA1.toByte(), 0x00, 0x01, 0x02)
    private val setCloseTightlyEnableCmd: ByteArray = byteArrayOf(0x10, 0xA2.toByte(), 0x00, 0x01, 0x02)

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {}
        override fun onWriteFailure(exception: BleException?) {}
    }

    var isOpenStatus: Boolean = false

    var isCanWrite: Boolean = false

    fun getValveOffOutputRpm() {
        MyApplication.writeData(getValveOffOutputRpmCmd, callback, false)
    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: Int) {
        if (!isOpenStatus) {
            when (index) {
                0 -> formatIntData(setOutputRpmOffCmd, value)
                1 -> formatIntData(setUngentRpmOffCmd, value)
                2 -> formatIntData(setRangeOfEndOffCmd, value)
                4 -> formatIntData(setTorqueRetryOffCmd, value)
                5 -> formatIntData(setRangeOfEndModeOffCmd, value)
                6 -> formatIntData(setRangeOfEndTorqueOffCmd, value)
                7 -> formatIntData(setStrokeTorqueOffCmd, value)
                8 -> formatIntData(setCloseTightlyEnableCmd, value)
                9 -> formatIntData(setCloseDefinitionCmd, value)
            }
        } else {
            when (index) {
                0 -> formatIntData(setOutputRpmOnCmd, value)
                1 -> formatIntData(setUngentRpmOnCmd, value)
                2 -> formatIntData(setRangeOfEndOnCmd, value)
                4 -> formatIntData(setTorqueRetryOnCmd, value)
                5 -> formatIntData(setRangeOfEndModeOnCmd, value)
                6 -> formatIntData(setRangeOfEndTorqueOnCmd, value)
                7 -> formatIntData(setStrokeTorqueOnCmd, value)
                8 -> formatIntData(setCloseTightlyEnableCmd, value)
                9 -> formatIntData(setCloseDefinitionCmd, value)
            }
        }

    }

    private fun formatIntData(cmd: ByteArray, data: Int) {
        val dataCmd: ArrayList<Byte> = cmd.copyOf().toList() as ArrayList<Byte>

        val dataBytes: ByteArray = ConvertUtil.int2Bytes(data, true)

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