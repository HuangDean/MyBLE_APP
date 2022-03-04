package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.OutputConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class OutputConfigViewModel(val repo: OutputConfigRepository) : BaseViewModel(), NotifyDelegate {

    val outputConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val output1LiveData = MutableLiveData<Int>()
    val output2LiveData = MutableLiveData<Int>()
    val output3LiveData = MutableLiveData<Int>()
    val output4LiveData = MutableLiveData<Int>()
    val output1StatusLiveData = MutableLiveData<Int>()
    val output2StatusLiveData = MutableLiveData<Int>()
    val output3StatusLiveData = MutableLiveData<Int>()
    val output4StatusLiveData = MutableLiveData<Int>()
//    val digitalOutputChannelLiveData = MutableLiveData<Int>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
            if (millisUntilFinished < 8000) {
                repo.getDigitOutputChannel()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            outputConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getChannel1Data() {
        outputConfigStatusLiveData.value = SettingStatus.Loading
        repo.isChannel1 = true
        repo.getDigitOutputChannel()
        timeoutTimer.start()
    }

    fun getChannel2Data() {
        outputConfigStatusLiveData.value = SettingStatus.Loading
        repo.isChannel1 = false
        repo.getDigitOutputChannel()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: Int) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        outputConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)

            if (repo.isChannel1) {
                repo.isChannel1 = true
                repo.getDigitOutputChannel()
                timeoutTimer.start()
            } else {
                repo.isChannel1 = false
                repo.getDigitOutputChannel()
                timeoutTimer.start()
            }
        }
    }

    override fun disconnect() {
        outputConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        if (dataBytes.size == 18) {
            timeoutTimer.cancel()

//            digitalOutputChannelLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2))

            if (repo.isChannel1) {
                output1StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[2])
                output2StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[4])
                output3StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[6])
                output4StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[8])

                output1LiveData.value = ConvertUtil.convertUInt8(dataBytes[3])
                output2LiveData.value = ConvertUtil.convertUInt8(dataBytes[5])
                output3LiveData.value = ConvertUtil.convertUInt8(dataBytes[7])
                output4LiveData.value = ConvertUtil.convertUInt8(dataBytes[9])
            } else {
                output1StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[10])
                output2StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[12])
                output3StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[14])
                output4StatusLiveData.value = ConvertUtil.convertUInt8(dataBytes[16])

                output1LiveData.value = ConvertUtil.convertUInt8(dataBytes[11])
                output2LiveData.value = ConvertUtil.convertUInt8(dataBytes[13])
                output3LiveData.value = ConvertUtil.convertUInt8(dataBytes[15])
                output4LiveData.value = ConvertUtil.convertUInt8(dataBytes[17])
            }

            viewModelScope.launch {
                delay(300)
                repo.isCanWrite = true
                outputConfigStatusLiveData.postValue(SettingStatus.Finish)
            }
        }
    }

}