package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.ProductConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class ProductConfigViewModel(val repo: ProductConfigRepository) : BaseViewModel(), NotifyDelegate {

    val productConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val modbusIdLiveData = MutableLiveData<String>()
    val baudRateLiveData = MutableLiveData<String>()
    val profibusAddressLiveData = MutableLiveData<String>()
    val gearLiveData = MutableLiveData<String>()
    val oemTypeLiveData = MutableLiveData<String>()
    val oemSerialLiveData = MutableLiveData<String>()
    val dealerTypeLiveData = MutableLiveData<String>()
    val dealerSerialLiveData = MutableLiveData<String>()

    val ai1BoardLiveData = MutableLiveData<Boolean>()
    val ai2BoardLiveData = MutableLiveData<Boolean>()
    val di1BoardLiveData = MutableLiveData<Boolean>()
    val di2BoardLiveData = MutableLiveData<Boolean>()
    val modbusBoardLiveData = MutableLiveData<Boolean>()
    val hartBoardLiveData = MutableLiveData<Boolean>()
    val ao1BoardLiveData = MutableLiveData<Boolean>()
    val ao2BoardLiveData = MutableLiveData<Boolean>()
    val do1BoardLiveData = MutableLiveData<Boolean>()
    val do2BoardLiveData = MutableLiveData<Boolean>()
    val profibusBoardLiveData = MutableLiveData<Boolean>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            if (millisUntilFinished < 8000) {
                repo.getSystemDetectBoard()
                Log.e("重新取得資料", "$millisUntilFinished")
            }
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            productConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getData() {
        productConfigStatusLiveData.value = SettingStatus.Loading
        repo.getSystemDetectBoard()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: String) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        productConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)
            getData()
        }
    }

    override fun disconnect() {
        productConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            198 -> {
                timeoutTimer.cancel()

                var binaryValue: String = ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2)).toString(2)

                if (binaryValue.length <= 11) {
                    for (i in 0 until 11 - binaryValue.length) {
                        binaryValue = "0$binaryValue"
                    }
                }

                binaryValue.forEachIndexed { index, value ->
                    when (index) {
                        0 -> hartBoardLiveData.value = value != '0'
                        1 -> profibusBoardLiveData.value = value != '0'
                        2 -> modbusBoardLiveData.value = value != '0'
                        3 -> do2BoardLiveData.value = value != '0'
                        4 -> do1BoardLiveData.value = value != '0'
                        5 -> di2BoardLiveData.value = value != '0'
                        6 -> di1BoardLiveData.value = value != '0'
                        7 -> ao2BoardLiveData.value = value != '0'
                        8 -> ao1BoardLiveData.value = value != '0'
                        9 -> ai2BoardLiveData.value = value != '0'
                        10 -> ai1BoardLiveData.value = value != '0'
                    }
                }

                oemSerialLiveData.value =
                    ConvertUtil.convertUtf8(dataBytes.copyOfRange(20, 36)).replace(0.toChar(), '@').split("@")[0]
                oemTypeLiveData.value =
                    ConvertUtil.convertUtf8(dataBytes.copyOfRange(36, 46)).replace(0.toChar(), '@').split("@")[0]
                dealerSerialLiveData.value =
                    ConvertUtil.convertUtf8(dataBytes.copyOfRange(56, 72)).replace(0.toChar(), '@').split("@")[0]
                dealerTypeLiveData.value =
                    ConvertUtil.convertUtf8(dataBytes.copyOfRange(72, 82)).replace(0.toChar(), '@').split("@")[0]
                gearLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(82, 84))}"

                modbusIdLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(90, 92))}"
                baudRateLiveData.value = "${ConvertUtil.convertUInt32(dataBytes.copyOfRange(92, 96))}"
                profibusAddressLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(196, 198))}"

                viewModelScope.launch {
                    delay(300)
                    repo.isCanWrite = true
                    productConfigStatusLiveData.postValue(SettingStatus.Finish)
                }
            }
        }
    }

}