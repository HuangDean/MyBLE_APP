package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class SystemConfigRepository {

    // read
    private val getLanguageCmd: ByteArray = byteArrayOf(0x10, 0x8C.toByte(), 0x00, 0x30) // 4236~4283

//    private val getLanguageCmd: ByteArray = byteArrayOf(0x10, 0x8C.toByte(), 0x00, 0x02) // 4236~4237
//    private val getAcVoltagePhaseCmd: ByteArray = byteArrayOf(0x10, 0xB9.toByte(), 0x00, 0x03) // 4281~4283

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private var setLanguageCmd: ByteArray = byteArrayOf(0x10, 0x8C.toByte(), 0x00, 0x01, 0x02)
    private var setMaxOutputTorqueCmd: ByteArray = byteArrayOf(0x10, 0x8D.toByte(), 0x00, 0x01, 0x02)
    private var setacVoltagePhaseCmd: ByteArray = byteArrayOf(0x10, 0xB9.toByte(), 0x00, 0x01, 0x02)
    private var setAcVoltageConfigCmd: ByteArray = byteArrayOf(0x10, 0xBA.toByte(), 0x00, 0x01, 0x02)
    private var setLightDefinitionCmd: ByteArray = byteArrayOf(0x10, 0xBB.toByte(), 0x00, 0x01, 0x02)

    var isCanWrite: Boolean = false

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    fun getLanguage() {
        MyApplication.writeData(getLanguageCmd, callback, false)
    }

//    fun getAcVoltagePhase() {
//        MyApplication.writeData(getAcVoltagePhaseCmd, callback, false)
//    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: String) {
        when (index) {
            0 -> formatIntData(setLanguageCmd, value)
            1 -> formatIntData(setLightDefinitionCmd, value)
            2 -> formatIntData(setMaxOutputTorqueCmd, value)
            3 -> formatIntData(setacVoltagePhaseCmd, value)
            4 -> formatIntData(setAcVoltageConfigCmd, value)
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