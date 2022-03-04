package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.SystemConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class SystemConfigViewModel(val repo: SystemConfigRepository) : BaseViewModel(), NotifyDelegate {

    val systemConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val languageLiveData = MutableLiveData<String>()
    val lightDefinitionLiveData = MutableLiveData<String>()
    val maxOutputTorqueLiveData = MutableLiveData<String>()
    val acVoltagePhaseLiveData = MutableLiveData<String>()
    val acVoltageConfigLiveData = MutableLiveData<String>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            if (millisUntilFinished < 8000) {
                repo.getLanguage()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            systemConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        systemConfigStatusLiveData.value = SettingStatus.Loading
        repo.getLanguage()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: String) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        systemConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)
            getData()
        }
    }

    override fun disconnect() {
        systemConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            96 -> {
                timeoutTimer.cancel()

                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2))) {
                    0 -> languageLiveData.value = "English"
                    1 -> languageLiveData.value = "繁體中文"
                    2 -> languageLiveData.value = "簡體中文"
                }

                maxOutputTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(2, 4))}"

                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(90, 92))) {
                    0 -> acVoltagePhaseLiveData.value = "三相"
                    1 -> acVoltagePhaseLiveData.value = "單相"
                }

                acVoltageConfigLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(92, 94))}"

                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(94, 96))) {
                    0 -> lightDefinitionLiveData.value = "紅燈"
                    1 -> lightDefinitionLiveData.value = "綠燈"
                }

                viewModelScope.launch {
                    delay(300)
                    repo.isCanWrite = true
                    systemConfigStatusLiveData.postValue(SettingStatus.Finish)
                }
            }
        }
    }
}