package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.MaintainRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MaintainViewModel(val repo: MaintainRepository) : BaseViewModel(), NotifyDelegate {

    val maintainStatus = MutableLiveData<SettingStatus>()
    val torqueRemainingTimes = MutableLiveData<Int>()
    val valveRemainingTimes = MutableLiveData<Int>()
    val motorRemainingTimes = MutableLiveData<Int>()
    val totalValveOffCount = MutableLiveData<Int>()
    val totalValveOnCount = MutableLiveData<Int>()
    val totalTorqueAllOff = MutableLiveData<Int>()
    val totalTorqueAllOn = MutableLiveData<Int>()
    val systemWorkinghours = MutableLiveData<Int>()
    val motorWorkinghours = MutableLiveData<Int>()
    val totalTorqueOffCount = MutableLiveData<Int>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            maintainStatus.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        viewModelScope.launch {
            delay(500)
            repo.getMotorRemaining()
            timeoutTimer.start()
        }
    }

    override fun disconnect() {
        maintainStatus.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        if (dataBytes.size == 44) {
            timeoutTimer.cancel()

            torqueRemainingTimes.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(0, 4))
            valveRemainingTimes.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(4, 8))
            motorRemainingTimes.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(8, 12))
            totalValveOffCount.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(12, 16))
            totalValveOnCount.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(16, 20))
            totalTorqueAllOff.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(24, 28))
            totalTorqueAllOn.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(28, 32))
            systemWorkinghours.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(32, 36))
            motorWorkinghours.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(36, 40))
            totalTorqueOffCount.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(40, 44))

            viewModelScope.launch {
                delay(1000)
                getData()
            }
        }
    }

}