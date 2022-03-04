package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class ControlModeConfigRepository {

    // read
    private val getInput1ModeCmd: ByteArray = byteArrayOf(0x10, 0xA3.toByte(), 0x00, 0x15) // 4259~4278

//    private val getInput1ModeCmd: ByteArray = byteArrayOf(0x10, 0xA3.toByte(), 0x00, 0x0A) // 4259~4268
//    private val getRemoteModeCmd: ByteArray = byteArrayOf(0x10, 0xB6.toByte(), 0x00, 0x02) // 4278

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private val setRemoteControlEnableCmd: ByteArray = byteArrayOf(0x10, 0xB6.toByte(), 0x00, 0x01, 0x02)
    private val setRemoteControlModeCmd: ByteArray = byteArrayOf(0x10, 0xB7.toByte(), 0x00, 0x01, 0x02)
    private val setInputSensitivityCmd: ByteArray = byteArrayOf(0x10, 0xA7.toByte(), 0x00, 0x01, 0x02)
    private val setDigitalInputEnableCmd: ByteArray = byteArrayOf(0x10, 0xA9.toByte(), 0x00, 0x01, 0x02)
    private val setDigitalInputCmd: ByteArray = byteArrayOf(0x10, 0xAC.toByte(), 0x00, 0x01, 0x02)
    private val setProportionalInputCmd: ByteArray = byteArrayOf(0x10, 0xAA.toByte(), 0x00, 0x01, 0x02)
    private val setProportionalOutputCmd: ByteArray = byteArrayOf(0x10, 0xAB.toByte(), 0x00, 0x01, 0x02)
    private val setInputModeConfig1Cmd: ByteArray = byteArrayOf(0x10, 0xA3.toByte(), 0x00, 0x01, 0x02)
    private val setInputModeConfig2Cmd: ByteArray = byteArrayOf(0x10, 0xA4.toByte(), 0x00, 0x01, 0x02)
    private val setOutputModeConfig1Cmd: ByteArray = byteArrayOf(0x10, 0xA5.toByte(), 0x00, 0x01, 0x02)
    private val setOutputModeConfig2Cmd: ByteArray = byteArrayOf(0x10, 0xA6.toByte(), 0x00, 0x01, 0x02)

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    var isChannel1: Boolean = true

    var isCanWrite: Boolean = false

    fun getInput1Mode() {
        MyApplication.writeData(getInput1ModeCmd, callback, false)
    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: Int) {
        when (index) {
            0 -> formatIntData(setRemoteControlEnableCmd, value)
            1 -> formatIntData(setRemoteControlModeCmd, value)
            2 -> formatIntData(setInputSensitivityCmd, value)
            3 -> formatIntData(setDigitalInputEnableCmd, value)
            4 -> formatIntData(setDigitalInputCmd, value)
            5 -> formatIntData(setProportionalInputCmd, value)
            6 -> formatIntData(setProportionalOutputCmd, value)
            7 -> {
                if (isChannel1) {
                    formatIntData(setInputModeConfig1Cmd, value)
                } else {
                    formatIntData(setInputModeConfig2Cmd, value)
                }
            }
            8 -> {
                if (isChannel1) {
                    formatIntData(setOutputModeConfig1Cmd, value)
                } else {
                    formatIntData(setOutputModeConfig2Cmd, value)
                }
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