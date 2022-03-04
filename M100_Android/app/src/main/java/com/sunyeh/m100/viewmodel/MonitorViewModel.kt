package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.github.mikephil.charting.data.Entry
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.MonitorRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MonitorViewModel(val repo: MonitorRepository) : BaseViewModel(), NotifyDelegate {

    val monitorStatus = MutableLiveData<SettingStatus>()
    val valveCurrentLiveData = MutableLiveData<ArrayList<Entry>>()
    val rpmLiveData = MutableLiveData<ArrayList<Entry>>()
    val motorTorqueLiveData = MutableLiveData<ArrayList<Entry>>()
    val moduleTemperatureLiveData = MutableLiveData<ArrayList<Entry>>()
    val motorTemperatureLiveData = MutableLiveData<ArrayList<Entry>>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            monitorStatus.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData(isFromUser: Boolean) {
        if (!isFromUser && !repo.isRecord) {
            return
        } else {
            repo.isRecord = true
        }
        repo.getValveRealPosition()
        timeoutTimer.start()
    }

    fun setFeature(feature: Int) {
        repo.feature = feature

        when (feature) {
            0 -> valveCurrentLiveData.value = repo.getValveCurrentEntrys()
            1 -> rpmLiveData.value = repo.getEpmEntrys()
            2 -> motorTorqueLiveData.value = repo.getMotorTorqueEntrys()
            3 -> motorTemperatureLiveData.value = repo.getMotorTempEntrys()
            4 -> moduleTemperatureLiveData.value = repo.getModuleTempEntrys()
        }
    }

    fun saveCVS(): ArrayList<MonitorRepository.MonitorData> {
        repo.isRecord = false
        timeoutTimer.cancel()
        return repo.csvData
    }

    fun clearData() {
        repo.csvData.clear()
        repo.timeLines.clear()
        repo.rpms.clear()
        repo.valveCurrents.clear()
        repo.motorTorques.clear()
        repo.motorTemperatures.clear()
        repo.moduleTemperatures.clear()
    }

    fun setDelayTimeSeconds(seconds: Int) {
        repo.delayTimerSeconds = seconds * 1000
    }

    override fun disconnect() {
        monitorStatus.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {

        if (!repo.isRecord) {
            return
        }

        when (dataBytes.size) {
            2 -> {
                timeoutTimer.cancel()

                repo.setRpm(ConvertUtil.convertUInt16(dataBytes))
                if (repo.feature == 1) {
                    rpmLiveData.value = repo.getEpmEntrys()
                }
                viewModelScope.launch {
                    delay(repo.delayTimerSeconds.toLong())
                    getData(false)
                }
            }
            20 -> {
                repo.setTime()

                val valveCurrent: Float = ConvertUtil.convertFloat(dataBytes.copyOfRange(0, 4))
                val motorTorque: Float = ConvertUtil.convertFloat(dataBytes.copyOfRange(8, 12))
                val moduleTemperature: Float = ConvertUtil.convertFloat(dataBytes.copyOfRange(12, 16))
                val motorTemperature: Float = ConvertUtil.convertFloat(dataBytes.copyOfRange(16, 20))

                repo.setValveCurrent(valveCurrent)
                repo.setMotorTorque(motorTorque)
                repo.setModuleTemp(moduleTemperature)
                repo.setMotorTemp(motorTemperature)

                when (repo.feature) {
                    0 -> valveCurrentLiveData.value = repo.getValveCurrentEntrys()
                    2 -> motorTorqueLiveData.value = repo.getMotorTorqueEntrys()
                    3 -> motorTemperatureLiveData.value = repo.getMotorTempEntrys()
                    4 -> moduleTemperatureLiveData.value = repo.getModuleTempEntrys()
                }

                viewModelScope.launch {
                    delay(1000)
                    repo.getMotorRPM()
                }
            }
        }
    }

}