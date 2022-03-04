package com.sunyeh.m100.viewmodel

import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.clj.fastble.utils.HexUtil.formatHexString
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.NotifyDelegate
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.RemoteControlRepository
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch

class RemoteControlViewModel(val repo: RemoteControlRepository) : BaseViewModel(), NotifyDelegate {

    val remoteControlStatus = MutableLiveData<SettingStatus>()

    val rpmLiveData = MutableLiveData<Int>()
    val tempLiveData = MutableLiveData<Int>()

    val dashboardTorque = MutableLiveData<Float>()
    val valveCurrentLiveData = MutableLiveData<Float>()
    val valveTargetLiveData = MutableLiveData<Float>()
    val correctionMotorTorqueLiveData = MutableLiveData<Float>()

    val versionLiveData = MutableLiveData<String>()
    val valveStatusLiveData = MutableLiveData<String>()

    private val refreshTimer: CountDownTimer = object : CountDownTimer(1500, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            if (millisUntilFinished in 490..510) {
                repo.up()
            }
        }

        override fun onFinish() {
            repo.getValveRealPosition()
            this.start()
        }
    }

    init {
        MyApplication.delegate = this
    }

    override fun onDestory() {
        refreshTimer.cancel()
        super.onDestory()
    }

    fun getData() {
        refreshTimer.start()
    }

    fun exit() {
        if (!repo.isCanTapped) return
        refreshTimer.cancel()

        repo.exit()
    }

    fun prev() {
        if (!repo.isCanTapped) return
        refreshTimer.cancel()

        repo.prev()
    }

    fun next() {
        if (!repo.isCanTapped) return
        refreshTimer.cancel()

        repo.next()
    }

    fun enter() {
        if (!repo.isCanTapped) return
        refreshTimer.cancel()

        repo.enter()
    }

    fun up() {
        viewModelScope.launch {
            delay(300)
            repo.up()
            repo.isCanTapped = true

            getData()
        }
    }

    override fun disconnect() {
        remoteControlStatus.value = SettingStatus.Disconnect
    }

    override fun recvData(dataBytes: ByteArray) {
        when (dataBytes.size) {
            172 -> {
                dashboardTorque.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(8, 12))

                versionLiveData.value = ConvertUtil.convertUtf8(dataBytes.copyOfRange(32, 40))

                when (ConvertUtil.convertUInt16(dataBytes.copyOfRange(48, 50))) {
                    0 -> valveStatusLiveData.value = "Stop"
                    1 -> valveStatusLiveData.value = "Open"
                    else -> valveStatusLiveData.value = "Close"
                }

                valveCurrentLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(56, 60))
                valveTargetLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(60, 64))
                correctionMotorTorqueLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(64, 68))
                tempLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(72, 76)).toInt()

                rpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(170, 172))
            }
        }
    }

}