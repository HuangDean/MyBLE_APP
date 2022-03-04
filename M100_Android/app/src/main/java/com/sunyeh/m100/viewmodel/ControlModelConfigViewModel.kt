package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.ControlModeConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class ControlModelConfigViewModel(val repo: ControlModeConfigRepository) : BaseViewModel(), NotifyDelegate {

    val controlModelConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val inputModeConfigLiveData = MutableLiveData<Int>()
    val outputConfigLiveData = MutableLiveData<Int>()
    val inputSensitivityLiveData = MutableLiveData<Int>()
    val digitalInputEnableLiveData = MutableLiveData<Int>()
    val proportionalInputLiveData = MutableLiveData<Int>()
    val proportionalOutputLiveData = MutableLiveData<Int>()
    val digitalInputLiveData = MutableLiveData<Int>()
    val remoteControlModeSwitchLiveData = MutableLiveData<Int>()
    val remoteControlModeLiveData = MutableLiveData<Int>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
            if (millisUntilFinished < 8000) {
                repo.getInput1Mode()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            controlModelConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getInputModeChannel1() {
        controlModelConfigStatusLiveData.value = SettingStatus.Loading
        repo.isChannel1 = true
        repo.getInput1Mode()
        timeoutTimer.start()
    }

    fun getInputModeChannel2() {
        controlModelConfigStatusLiveData.value = SettingStatus.Loading
        repo.isChannel1 = false
        repo.getInput1Mode()
        timeoutTimer.start()
    }

    override fun disconnect() {
        controlModelConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    fun saveData(index: Int, value: Int) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        controlModelConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)

            if (repo.isChannel1) {
                repo.isChannel1 = true
                repo.getInput1Mode()
                timeoutTimer.start()
            } else {
                repo.isChannel1 = false
                repo.getInput1Mode()
                timeoutTimer.start()
            }
        }
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            42 -> {
                timeoutTimer.cancel()

                // 1
                if (repo.isChannel1) {
                    inputModeConfigLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2))
                    outputConfigLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(4, 6))
                } else {
                    inputModeConfigLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(2, 4))
                    outputConfigLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(6, 8))
                }

                inputSensitivityLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(8, 10))
                digitalInputEnableLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(12, 14))

                proportionalInputLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(14, 16))

                proportionalOutputLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(16, 18))

                digitalInputLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(18, 20))

                // 2
                remoteControlModeSwitchLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(38, 40))
                remoteControlModeLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(40, 42))

                viewModelScope.launch {
                    repo.isCanWrite = true
                    controlModelConfigStatusLiveData.postValue(SettingStatus.Finish)
                }
            }
        }
    }

}