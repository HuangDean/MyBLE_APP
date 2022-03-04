package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.StatusRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class StatusViewModel(val repo: StatusRepository) : BaseViewModel(), NotifyDelegate {

    val uiStatusLiveData = MutableLiveData<SettingStatus>()
    val statusCodeLiveData = MutableLiveData<ArrayList<Int>>()

    var isSystemStatus: Boolean = true

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            uiStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        viewModelScope.launch {
            delay(500)
            uiStatusLiveData.value = SettingStatus.Loading
            repo.getSystemStatus()
            timeoutTimer.start()
        }
    }

    override fun disconnect() {
        uiStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        if (dataBytes.size == 8) {
            timeoutTimer.cancel()

            repo.statusCode.clear()

            if (!isSystemStatus) {
                ConvertUtil.convertUInt32(dataBytes.copyOfRange(0, 4))
                    .toUInt()
                    .toString(2)
                    .reversed()
                    .forEachIndexed { index, char ->

                        if (index < 30 && char == '1') {
                            repo.statusCode.add(index)
                        }
                    }
            } else {
                ConvertUtil.convertUInt32(dataBytes.copyOfRange(4, 8))
                    .toUInt()
                    .toString(2)
                    .reversed()
                    .forEachIndexed { index, char ->
                        if (index < 21 && char == '1') {
                            repo.statusCode.add(index)
                        }
                    }
            }

            statusCodeLiveData.value = repo.statusCode
            uiStatusLiveData.value = SettingStatus.Finish

            viewModelScope.launch {
                delay(1000)
                repo.getSystemStatus()
                timeoutTimer.start()
            }
        }
    }
}