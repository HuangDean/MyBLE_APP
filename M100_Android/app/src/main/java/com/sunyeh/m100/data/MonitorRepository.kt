package com.sunyeh.m100.data

import android.annotation.SuppressLint
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.github.mikephil.charting.data.Entry
import com.sunyeh.m100.MyApplication
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList

class MonitorRepository {

    // read
    private val getValveRealPositionCmd: ByteArray = byteArrayOf(0x10, 0x22, 0x00, 0x0A)
    private val getMotorRPMCmd: ByteArray = byteArrayOf(0x10, 0x5B, 0x00, 0x01)

    var delayTimerSeconds: Int = 1000
    var feature: Int = 0

    val timeLines: ArrayList<Float> = ArrayList()
    val rpms: ArrayList<Int> = ArrayList()
    val valveCurrents: ArrayList<Float> = ArrayList()
    val motorTorques: ArrayList<Float> = ArrayList()
    val motorTemperatures: ArrayList<Float> = ArrayList()
    val moduleTemperatures: ArrayList<Float> = ArrayList()

    val csvData: ArrayList<MonitorData> = ArrayList()

    var isRecord: Boolean = false

    data class MonitorData(
        var time: String,
        var position: Float,
        var torque: Float,
        var moduleTemp: Float,
        var motorTemp: Float,
        var rpm: Int
    )

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
        }

        override fun onWriteFailure(exception: BleException?) {
        }
    }

    @SuppressLint("SimpleDateFormat")
    fun setTime() {
        timeLines.add(SimpleDateFormat("HHmmss").format(Date()).toFloat())
        if (timeLines.size > 10) {
            timeLines.removeAt(0)
        }

        val dateString: String = SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(Date())
        csvData.add(MonitorData(dateString, 0F, 0F, 0F, 0F, 0))
    }

    fun setValveCurrent(value: Float) {
        valveCurrents.add(value)
        if (valveCurrents.size > 10) {
            valveCurrents.removeAt(0)
        }

        if (csvData.size == 0) { return }
        csvData[csvData.size - 1].position = value
    }

    fun getValveCurrentEntrys(): ArrayList<Entry> {
        val entrys: ArrayList<Entry> = ArrayList()

        valveCurrents.forEachIndexed { index, valveCurrent ->
            entrys.add(Entry(timeLines[index], valveCurrent))
        }

        return entrys
    }

    fun setRpm(value: Int) {
        rpms.add(value)
        if (rpms.size > 10) {
            rpms.removeAt(0)
        }

        if (csvData.size == 0) { return }
        csvData[csvData.size - 1].rpm = value
    }

    fun getEpmEntrys(): ArrayList<Entry> {
        val entrys: ArrayList<Entry> = ArrayList()

        rpms.forEachIndexed { index, rpm ->
            entrys.add(Entry(timeLines[index], rpm.toFloat()))
        }

        return entrys
    }

    fun setMotorTorque(value: Float) {
        motorTorques.add(value)
        if (motorTorques.size > 10) {
            motorTorques.removeAt(0)
        }

        if (csvData.size == 0) { return }
        csvData[csvData.size - 1].torque = value
    }

    fun getMotorTorqueEntrys(): ArrayList<Entry> {
        val entrys: ArrayList<Entry> = ArrayList()

        motorTorques.forEachIndexed { index, motorTorque ->
            entrys.add(Entry(timeLines[index], motorTorque))
        }

        return entrys
    }

    fun setMotorTemp(value: Float) {
        motorTemperatures.add(value)
        if (motorTemperatures.size > 10) {
            motorTemperatures.removeAt(0)
        }

        if (csvData.size == 0) { return }
        csvData[csvData.size - 1].motorTemp = value
    }

    fun getMotorTempEntrys(): ArrayList<Entry> {
        val entrys: ArrayList<Entry> = ArrayList()

        motorTemperatures.forEachIndexed { index, motorTemp ->
            entrys.add(Entry(timeLines[index], motorTemp))
        }

        return entrys
    }

    fun setModuleTemp(value: Float) {
        moduleTemperatures.add(value)
        if (moduleTemperatures.size > 10) {
            moduleTemperatures.removeAt(0)
        }

        if (csvData.size == 0) { return }
        csvData[csvData.size - 1].moduleTemp = value
    }

    fun getModuleTempEntrys(): ArrayList<Entry> {
        val entrys: ArrayList<Entry> = ArrayList()

        moduleTemperatures.forEachIndexed { index, moduleTemperature ->
            entrys.add(Entry(timeLines[index], moduleTemperature))
        }

        return entrys
    }

    fun getValveRealPosition() {
        MyApplication.writeData(getValveRealPositionCmd, callback, false)
    }

    fun getMotorRPM() {
        MyApplication.writeData(getMotorRPMCmd, callback, false)
    }
}