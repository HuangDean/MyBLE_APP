package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.UngentConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class UngentConfigViewModel(val repo: UngentConfigRepository) : BaseViewModel(), NotifyDelegate {

    val ungentConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val openSignalActionLiveData = MutableLiveData<String>()
    val ungentActionLiveData = MutableLiveData<String>()
    val signalUngentPositionLiveData = MutableLiveData<String>()
    val motorWarningTempeatureLiveData = MutableLiveData<String>()
    val motorWarningSwitchLiveData = MutableLiveData<String>()
    val ungentIntputSwitchLiveData = MutableLiveData<Int>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
            if (millisUntilFinished < 8000) {
                repo.getMotorTempeatureAlarm()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            ungentConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        ungentConfigStatusLiveData.value = SettingStatus.Loading
        repo.getMotorTempeatureAlarm()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: String) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        ungentConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)
            getData()
        }
    }

    override fun disconnect() {
        ungentConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            54 -> {
                timeoutTimer.cancel()

                // 1
                motorWarningTempeatureLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2))}"
                motorWarningSwitchLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(2, 4))}"

                // 2
                signalUngentPositionLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(24, 26))}"

                // 3
                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(30, 32))) {
                    0 -> openSignalActionLiveData.value = "保持位置不動"
                    1 -> openSignalActionLiveData.value = "運行至緊急位置"
                    2 -> openSignalActionLiveData.value = "運轉至設定位置"
                }

                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(32, 34))) {
                    0 -> ungentActionLiveData.value = "運轉至全關"
                    1 -> ungentActionLiveData.value = "運轉至全開"
                    2 -> ungentActionLiveData.value = "停止運轉"
                    3 -> ungentActionLiveData.value = "關閉緊急功能"
                }

                // 4
                ungentIntputSwitchLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(52, 54))

                viewModelScope.launch {
                    delay(300)
                    repo.isCanWrite = true
                    ungentConfigStatusLiveData.postValue(SettingStatus.Finish)
                }
            }
        }
    }
}