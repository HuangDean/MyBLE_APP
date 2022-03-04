package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.MaintainConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MaintainConfigViewModel(val repo: MaintainConfigRepository) : BaseViewModel(), NotifyDelegate {

    val maintainConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val switchTimesLiveData = MutableLiveData<String>()
    val torqueTimesLiveData = MutableLiveData<String>()
    val motorWorkTimeLiveData = MutableLiveData<String>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            if (millisUntilFinished < 8000) {
                repo.getSwitchTimes()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            maintainConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        maintainConfigStatusLiveData.value = SettingStatus.Loading
        repo.getSwitchTimes()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: String) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        maintainConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)
            getData()
        }
    }

    override fun disconnect() {
        maintainConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        if (dataBytes.size == 12) {
            timeoutTimer.cancel()

            switchTimesLiveData.value = "${ConvertUtil.convertUInt32(dataBytes.copyOfRange(0, 4))}"
            torqueTimesLiveData.value = "${ConvertUtil.convertUInt32(dataBytes.copyOfRange(4, 8))}"
            motorWorkTimeLiveData.value = "${ConvertUtil.convertUInt32(dataBytes.copyOfRange(8, 12))}"

            viewModelScope.launch {
                delay(300)
                repo.isCanWrite = true
                maintainConfigStatusLiveData.postValue(SettingStatus.Finish)
            }
        }
    }

}