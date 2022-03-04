package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class ProductConfigRepository {

    // read
    private val getSystemDetectBoardCmd: ByteArray = byteArrayOf(0x10, 0x56, 0x00, 0x63) // 4182

//    private val getSystemDetectBoardCmd: ByteArray = byteArrayOf(0x10, 0x56, 0x00, 0x01) // 4182
//    private val getOemSerialCmd: ByteArray = byteArrayOf(0x10, 0x60, 0x00, 0x20) // 4192
//    private val getModbusIdCmd: ByteArray = byteArrayOf(0x10, 0x83.toByte(), 0x00, 0x03) // 4227~4228
//    private val getProfibusAddressCmd: ByteArray = byteArrayOf(0x10, 0xB8.toByte(), 0x00, 0x02) // num:2 board區分

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private var setModbusIdCmd: ByteArray = byteArrayOf(0x10, 0x83.toByte(), 0x00, 0x01, 0x02)
    private var setBaundRateCmd: ByteArray = byteArrayOf(0x10, 0x84.toByte(), 0x00, 0x02, 0x04)
    private var setProfibusAddressCmd: ByteArray = byteArrayOf(0x10, 0xB8.toByte(), 0x00, 0x01, 0x02)
    private var setGearCmd: ByteArray = byteArrayOf(0x10, 0x7F, 0x00, 0x01, 0x02)
    private var setOemTypeCmd: ByteArray = byteArrayOf(0x10, 0x68, 0x00, 0x05, 0x0A)
    private var setOemSerialCmd: ByteArray = byteArrayOf(0x10, 0x60, 0x00, 0x08, 0x10)
    private var setDealerTypeCmd: ByteArray = byteArrayOf(0x10, 0x7A, 0x00, 0x05, 0x0A) // 0A: 文件長度10, 目前只讀6byte
    private var setDealerSerialCmd: ByteArray = byteArrayOf(0x10, 0x72, 0x00, 0x08, 0x10)

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    var isCanWrite: Boolean = false

    fun getSystemDetectBoard() {
        MyApplication.writeData(getSystemDetectBoardCmd, callback, false)
    }

//    fun getOemSerial() {
//        MyApplication.writeData(getOemSerialCmd, callback, false)
//    }
//
//    fun getModbusId() {
//        MyApplication.writeData(getModbusIdCmd, callback, false)
//    }
//
//    fun getProfibusAddress() {
//        MyApplication.writeData(getProfibusAddressCmd, callback, false)
//    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: String) {
        when (index) {
            0 -> formatIntData(setModbusIdCmd, value, false)
            1 -> formatIntData(setBaundRateCmd, value, true)
            2 -> formatIntData(setProfibusAddressCmd, value, false)
            3 -> formatIntData(setGearCmd, value, false)
            4 -> formatUTF8Data(setOemTypeCmd, 10, value)
            5 -> formatUTF8Data(setOemSerialCmd, 16, value)
            6 -> formatUTF8Data(setDealerTypeCmd, 10, value)
            7 -> formatUTF8Data(setDealerSerialCmd, 16, value)
        }
    }

    private fun formatIntData(cmd: ByteArray, data: String, isLittlleEnian: Boolean) {
        val dataCmd: ArrayList<Byte> = cmd.copyOf().toList() as ArrayList<Byte>

        if (isLittlleEnian) {
            val dataBytes: ByteArray = ConvertUtil.int2Bytes(data.toInt(), isLittlleEnian)

            for (i in dataBytes.indices step 2) {
                dataCmd.add(dataBytes[i + 1])
                dataCmd.add(dataBytes[i])
            }

            setData(dataCmd.toByteArray())
        } else {
            val dataBytes: List<Byte> = ConvertUtil.uShort2Bytes(data.toInt(), isLittlleEnian).toList()
            dataCmd += dataBytes
            setData(dataCmd.toByteArray())
        }
    }

    private fun formatUTF8Data(cmd: ByteArray, maxLength: Int, data: String) {
        val dataCmd: ArrayList<Byte> = cmd.copyOf().toList() as ArrayList<Byte>

        val utf8Bytes: ArrayList<Byte> = ConvertUtil.utf2byte(data).toList() as ArrayList<Byte>

        if (utf8Bytes.size % 2 == 1) {
            utf8Bytes.add(0x00)
        }

        var dataLength: Int = utf8Bytes.size

        // 限制資料長度
        if (dataLength > maxLength) {
            dataLength = maxLength
        }

        for (i in 0 until dataLength step 2) {
            dataCmd.add(utf8Bytes[i + 1])
            dataCmd.add(utf8Bytes[i])
        }

        // 資料不夠長塞0x00
        if (dataLength < maxLength) {
            for (i in 1..maxLength - dataLength) {
                dataCmd.add(0x00)
            }
        }

        val newCmd: ByteArray = dataCmd.toByteArray()

        setData(newCmd)
    }

    private fun setData(cmd: ByteArray) {
        MyApplication.writeData(cmd, callback, true)
    }
}