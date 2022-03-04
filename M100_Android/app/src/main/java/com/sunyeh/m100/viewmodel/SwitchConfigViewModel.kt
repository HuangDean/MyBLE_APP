package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.SwitchConfigRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class SwitchConfigViewModel(val repo: SwitchConfigRepository) : BaseViewModel(), NotifyDelegate {

    val switchConfigStatusLiveData = MutableLiveData<SettingStatus>()
    val prograssMinLiveData = MutableLiveData<Int>()
    val prograssMaxLiveData = MutableLiveData<Int>()
    val prograssStrokeOffLiveData = MutableLiveData<String>()
    val prograssStrokeOnLiveData = MutableLiveData<String>()
    val prograssRangeOfEndOffLiveData = MutableLiveData<String>()
    val prograssRangeOfEndOnLiveData = MutableLiveData<String>()

    val outputRpmLiveData = MutableLiveData<Float>()
    val ungentRpmLiveData = MutableLiveData<Float>()
    val rangeOfEndLiveData = MutableLiveData<Float>()
    val limitLiveData = MutableLiveData<String>()
    val torqueRetryLiveData = MutableLiveData<String>()
    val rangeOfEndModeLiveData = MutableLiveData<String>()
    val rangeOfEndTorqueLiveData = MutableLiveData<String>()
    val strokeTorqueLiveData = MutableLiveData<String>()
    val closeTightlyLiveData = MutableLiveData<Int>()
    val closeDefinitionLiveData = MutableLiveData<String>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
            if (millisUntilFinished < 8000) {
                if (repo.isOpenStatus) {
                    repo.getValveOffOutputRpm()
                } else {
                    repo.getValveOffOutputRpm()
                }
                Log.e("重新取得資料", "$millisUntilFinished")
            }
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            switchConfigStatusLiveData.value = SettingStatus.Timeout
        }
    }

    init {
        MyApplication.delegate = this
    }

    fun getDataOn() {
        switchConfigStatusLiveData.value = SettingStatus.Loading
        repo.isOpenStatus = true
        repo.getValveOffOutputRpm()
        timeoutTimer.start()
    }

    fun getDataOff() {
        switchConfigStatusLiveData.value = SettingStatus.Loading
        repo.isOpenStatus = false
        repo.getValveOffOutputRpm()
        timeoutTimer.start()
    }

    fun saveData(index: Int, value: Int) {
        if (!repo.isCanWrite) {
            return
        }

        repo.isCanWrite = false

        switchConfigStatusLiveData.value = SettingStatus.Loading
        viewModelScope.launch {
            repo.saveData(index, value)
            delay(300)
            repo.saveCmd()
            delay(300)

            if (repo.isOpenStatus) {
                repo.isOpenStatus = true
                repo.getValveOffOutputRpm()
                timeoutTimer.start()
            } else {
                repo.isOpenStatus = false
                repo.getValveOffOutputRpm()
                timeoutTimer.start()
            }
        }
    }

    override fun disconnect() {
        switchConfigStatusLiveData.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            152 -> {
                timeoutTimer.cancel()

                // 1
                if (!repo.isOpenStatus) {
                    limitLiveData.value = String.format("%.5f", ConvertUtil.convertFloat(dataBytes.copyOfRange(0, 4)))
                } else {
                    limitLiveData.value = String.format("%.5f", ConvertUtil.convertFloat(dataBytes.copyOfRange(4, 8)))
                }

                // 2
                prograssMinLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(130, 132)) // prograss 用
                prograssStrokeOffLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(126, 128))}%" //prograss 用
                prograssRangeOfEndOffLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(122, 124))}%" // prograss 用
                prograssMaxLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(132, 134)) // prograss 用
                prograssStrokeOnLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(128, 130))}%" // prograss 用
                prograssRangeOfEndOnLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(124, 126))}%" // prograss 用

                if (!repo.isOpenStatus) {
                    rangeOfEndTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(122, 124))}%"
                    strokeTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(126, 128))}%"
                    rangeOfEndLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(130, 132)).toFloat()
                    outputRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(114, 116)).toFloat()
                    ungentRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(118, 120)).toFloat()
                    torqueRetryLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(136, 138))}"

                    if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(146, 148)) == 0) {
                        rangeOfEndModeLiveData.value = "扭力優先"
                    } else {
                        rangeOfEndModeLiveData.value = "位置優先"
                    }
                } else {
                    rangeOfEndTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(124, 126))}%"
                    strokeTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(128, 130))}%"
                    rangeOfEndLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(132, 134)).toFloat()
                    outputRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(116, 118)).toFloat()
                    ungentRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(120, 122)).toFloat()
                    torqueRetryLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(138, 140))}"

                    if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(148, 150)) == 0) {
                        rangeOfEndModeLiveData.value = "扭力優先"
                    } else {
                        rangeOfEndModeLiveData.value = "位置優先"
                    }
                }

                if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(144, 146)) == 0) {
                    closeDefinitionLiveData.value = "CCW"
                } else {
                    closeDefinitionLiveData.value = "CW"
                }

                closeTightlyLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(150, 152)) // 0:off 1:on


                viewModelScope.launch {
                    delay(300)
                    switchConfigStatusLiveData.postValue(SettingStatus.Finish)
                    repo.isCanWrite = true
                }
            }

//            8 -> {
//                timeoutTimer.cancel()
//
//                if (!repo.isOpenStatus) {
//                    limitLiveData.value = String.format("%.5f", ConvertUtil.convertFloat(dataBytes.copyOfRange(0, 4)))
//                } else {
//                    limitLiveData.value = String.format("%.5f", ConvertUtil.convertFloat(dataBytes.copyOfRange(4, 8)))
//                }
//
//
//                viewModelScope.launch {
//                    delay(300)
//                    switchConfigStatusLiveData.postValue(SettingStatus.Finish)
//                    repo.isCanWrite = true
//                }
//            }
//
//            38 -> {
//                prograssMinLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(16, 18)) // prograss 用
//                prograssStrokeOffLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(12, 14))}%" //prograss 用
//                prograssRangeOfEndOffLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(8, 10))}%" // prograss 用
//                prograssMaxLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(18, 20)) // prograss 用
//                prograssStrokeOnLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(14, 16))}%" // prograss 用
//                prograssRangeOfEndOnLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(10, 12))}%" // prograss 用
//
//                if (!repo.isOpenStatus) {
//                    rangeOfEndTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(8, 10))}%"
//                    strokeTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(12, 14))}%"
//                    rangeOfEndLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(16, 18)).toFloat()
//                    outputRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(0, 2)).toFloat()
//                    ungentRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(4, 6)).toFloat()
//                    torqueRetryLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(22, 24))}"
//
//                    if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(32, 34)) == 0) {
//                        rangeOfEndModeLiveData.value = "扭力優先"
//                    } else {
//                        rangeOfEndModeLiveData.value = "位置優先"
//                    }
//                } else {
//                    rangeOfEndTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(10, 12))}%"
//                    strokeTorqueLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(14, 16))}%"
//                    rangeOfEndLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(18, 20)).toFloat()
//                    outputRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(2, 4)).toFloat()
//                    ungentRpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(6, 8)).toFloat()
//                    torqueRetryLiveData.value = "${ConvertUtil.convertUInt16(dataBytes.copyOfRange(24, 26))}"
//
//                    if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(34, 36)) == 0) {
//                        rangeOfEndModeLiveData.value = "扭力優先"
//                    } else {
//                        rangeOfEndModeLiveData.value = "位置優先"
//                    }
//                }
//
//                if (ConvertUtil.convertUInt16(dataBytes.copyOfRange(30, 32)) == 0) {
//                    closeDefinitionLiveData.value = "CCW"
//                } else {
//                    closeDefinitionLiveData.value = "CW"
//                }
//
//                closeTightlyLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(36, 38)) // 0:off 1:on
//
//                viewModelScope.launch {
//                    delay(300)
//
//                    repo.getLimitOffPosition()
//                }
//            }
        }
    }
}