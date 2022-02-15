package com.example.mybt.Data

import android.Manifest
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.example.mybt.MyApplication.Companion.writeData

class MainRepository {

    private val getGeneralPasswordCmd: ByteArray = byteArrayOf(0x10, 0x5C, 0x00, 0x01)
    private val getDealerPasswordCmd: ByteArray = byteArrayOf(0x10, 0x5D, 0x00, 0x01)
    private val getValveRealPositionCmd: ByteArray = byteArrayOf(0x10, 0x06, 0x00, 0x56) // 12: 4102~4187


    var bleDevice: BleDevice? = null
    var password: String? = null
    var permission: Int? = null
    var reTryCount: Int = 0
    val discoverBleDevices: ArrayList<BleDevice> = ArrayList()

    fun addDiscoverBleDevice(device: BleDevice) = discoverBleDevices.add(device)

    fun clearDiscoverBleDevice() = discoverBleDevices.clear()

    fun getDiscoverBleDevice(index: Int): BleDevice? {
        if (index < discoverBleDevices.size) {
            return discoverBleDevices[index]
        }

        return null
    }
    fun addReTryCount() {
        ++reTryCount
    }

    fun disconnect() {
        bleDevice=null
        clearDiscoverBleDevice()
    }

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    fun fetchPassword() {
        val cmd: ByteArray = when (permission) {
            0 -> getGeneralPasswordCmd
            1 -> getDealerPasswordCmd
            else -> getDealerPasswordCmd
        }

        writeData("shkdjkfhjk".toByteArray(), callback, false)
    }
}