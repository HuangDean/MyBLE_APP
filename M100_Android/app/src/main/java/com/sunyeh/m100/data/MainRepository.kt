package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.MyApplication.Companion.writeData

class MainRepository {

    private val getGeneralPasswordCmd: ByteArray = byteArrayOf(0x10, 0x5C, 0x00, 0x01)
    private val getDealerPasswordCmd: ByteArray = byteArrayOf(0x10, 0x5D, 0x00, 0x01)

    private val getValveRealPositionCmd: ByteArray = byteArrayOf(0x10, 0x06, 0x00, 0x56) // 12: 4102~4187

//    private val getValveRealPositionCmd: ByteArray = byteArrayOf(0x10, 0x06, 0x00, 0x0C) // 12: 4102~4112
//    private val getSoftwareVersionCmd: ByteArray = byteArrayOf(0x10, 0x16, 0x00, 0x16)   // 22: 4118~4138
//    private val getMotorRPMCmd: ByteArray = byteArrayOf(0x10, 0x5B, 0x00, 0x02)          // 2: 4187~4188



    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    val discoverBleDevices: ArrayList<BleDevice> = ArrayList()
    var reTryCount: Int = 0
    var bleDevice: BleDevice? = null
    var password: String? = null
    var permission: Int? = null

    /**
     * @return BleDevice
     */

    fun fetchPassword() {
        val cmd: ByteArray = when (permission) {
            0 -> getGeneralPasswordCmd
            1 -> getDealerPasswordCmd
            else -> getDealerPasswordCmd
        }

        writeData(cmd, callback, false)
    }

    fun addReTryCount() {
        ++reTryCount
    }

    fun getValveRealPositionCmd() {
        writeData(getValveRealPositionCmd, callback, false)
    }

    fun addDiscoverBleDevice(device: BleDevice) = discoverBleDevices.add(device)

    fun clearDiscoverBleDevice() = discoverBleDevices.clear()

    fun getDiscoverBleDevice(index: Int): BleDevice? {
        if (index < discoverBleDevices.size) {
            return discoverBleDevices[index]
        }

        return null
    }

    fun disconnect() {
        bleDevice = null
        password = null
        permission = null
        clearDiscoverBleDevice()
    }
}