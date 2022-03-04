package com.sunyeh.m100.viewmodel

import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.os.CountDownTimer
import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleGattCallback
import com.clj.fastble.callback.BleNotifyCallback
import com.clj.fastble.callback.BleScanCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.data.BleScanState
import com.clj.fastble.exception.BleException
import com.clj.fastble.utils.HexUtil
import com.sunyeh.m100.MainStatus
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.MyApplication.Companion.CHARACTERISTIC_UUID_NOTIFY
import com.sunyeh.m100.MyApplication.Companion.SERVICE_UUID
import com.sunyeh.m100.MyApplication.Companion.bleDevice
import com.sunyeh.m100.MyApplication.Companion.context
import com.sunyeh.m100.data.MainRepository
import com.sunyeh.m100.data.db.UserConfig
import com.sunyeh.m100.utils.ConvertUtil
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.koin.ext.scope

class MainViewModel(val repo: MainRepository) : BaseViewModel() {

    val bleDeviceLiveData = MutableLiveData<ArrayList<BleDevice>>()
    val mainStatusLiveData = MutableLiveData<MainStatus>()
    val rpmLiveData = MutableLiveData<Int>()
    val valveCurrentLiveData = MutableLiveData<Float>()
    val valveTargetLiveData = MutableLiveData<Float>()
    val correctionMotorTorqueLiveData = MutableLiveData<Int>()
    val motorTorqueLiveData = MutableLiveData<Float>()
    val motorTemperatureLiveData = MutableLiveData<Int>()
    val systemErrorStatusLiveData = MutableLiveData<Int>()
    val moduleTemperatureLiveData = MutableLiveData<Int>()
    val versionLiveData = MutableLiveData<String>()
    val valveStatusLiveData = MutableLiveData<Int>()

    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
            bleDevice?.let {
                BleManager.getInstance().disconnect(it)
            }
            mainStatusLiveData.value = MainStatus.ConnectFailed
        }
    }

    private val refreshTimer: CountDownTimer = object : CountDownTimer(1000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
        }

        override fun onFinish() {
            Log.e("time observer", "finish")

            bleDevice?.let {
                repo.getValveRealPositionCmd()
                this.start()
            }
        }
    }

    fun startScan() {
        BleManager.getInstance().scan(object : BleScanCallback() {
            override fun onScanFinished(scanResultList: MutableList<BleDevice>?) {
            }

            override fun onScanStarted(success: Boolean) {
                // 藍牙未打開、上次的scan動作還沒結束等等原因造成的結果
            }
            // if !peripheralName.contains("MT") && !peripheralName.contains("SUNYEH") && !peripheralName.contains("SunYeh") { return }
            override fun onScanning(bleDevice: BleDevice?) {
                bleDevice?.let {
                    if (!it.name.isNullOrBlank()) {
                        if (!it.name.contains("SunYeh", true) && !it.name.contains("MT")) {
                            return
                        }
                    }

                    if (UserConfig.getDeviceName(context) == it.name) {
                        repo.bleDevice = it
                        mainStatusLiveData.value = MainStatus.QuickEnable
                    }

                    if (!it.name.isNullOrBlank()) {
                        repo.addDiscoverBleDevice(it)
                        bleDeviceLiveData.value = repo.discoverBleDevices
                    }
                }
            }
        })
    }

    fun stopScan() {
        if (!BleManager.getInstance().isBlueEnable) return

        if (BleManager.getInstance().scanSate == BleScanState.STATE_SCANNING) {
            BleManager.getInstance().cancelScan()
            repo.clearDiscoverBleDevice()
            bleDeviceLiveData.value = repo.discoverBleDevices
        }
    }

    fun disConnect() {
        BleManager.getInstance().disconnect(repo.bleDevice)
        repo.disconnect()
    }

    fun quickConnect() {
        repo.bleDevice?.let {
            val index: Int = repo.discoverBleDevices.indexOf(it)
            repo.password = UserConfig.getPassword(context)
            repo.permission = UserConfig.getPermission(context).toInt()
            connect(index, repo.password!!, repo.permission!!)
        }
    }

    fun connect(index: Int, password: String, permission: Int) {
        if (repo.bleDevice == null) {
            repo.bleDevice = repo.getDiscoverBleDevice(index)
        }

        BleManager.getInstance().connect(repo.bleDevice, object : BleGattCallback() {
            override fun onStartConnect() {
                Log.e("ble", "連線中")
                mainStatusLiveData.value = MainStatus.Connecting
            }

            override fun onDisConnected(isActiveDisConnected: Boolean, device: BleDevice?, gatt: BluetoothGatt?, status: Int) {
                Log.e("ble", "斷線")
                timeoutTimer.cancel()

                bleDevice = null
                MyApplication.delegate?.disconnect()

                if (repo.permission == null) {
                    mainStatusLiveData.value = MainStatus.DisConnect
                    mainStatusLiveData.value = MainStatus.Unlogined
                }

                repo.bleDevice = null
                repo.password = null
                repo.permission = null
            }

            override fun onConnectSuccess(bleDevice: BleDevice?, gatt: BluetoothGatt?, status: Int) {
                Log.e("ble", "連線成功")
                timeoutTimer.start()

                if (bleDevice != null) {
                    MyApplication.bleDevice = bleDevice
                }
                repo.bleDevice = bleDevice
                repo.password = password

                repo.permission = permission
                val bluetoothGatt: BluetoothGatt = BleManager.getInstance().getBluetoothGatt(bleDevice)

                val serviceList = bluetoothGatt.services
                Log.e("ble", "service數量 ${serviceList.size}")

                for (service in serviceList) {
                    Log.e("ble", "serviceUuid ${service.uuid}")

                    if (service.uuid.toString().equals(SERVICE_UUID, true)) {
                        Log.e("ble", "characteristics數量 ${service.characteristics.size}")

                        for (characteristic in service.characteristics) {
                            Log.e("ble", "characteristicsUuid ${characteristic.uuid}")

                            if (characteristic.uuid.toString().equals(CHARACTERISTIC_UUID_NOTIFY, true)) {
                                viewModelScope.launch {
                                    delay(300)
                                    setNotifyListener(bleDevice)
                                }

                                return
                            }
                        }
                    }
                }
            }

            override fun onConnectFail(bleDevice: BleDevice?, exception: BleException?) {
                repo.addReTryCount()
                Log.e("ble", "連線失敗 重新連線次數${repo.reTryCount}")

                if (repo.reTryCount <= 2) {
                    viewModelScope.launch {
                        delay(500)
                        connect(index, password, permission)
                    }
                    return
                }

                Log.e("ble", "連線失敗")
                repo.reTryCount = 0
                repo.bleDevice = null
                repo.password = null
                repo.permission = null
                mainStatusLiveData.value = MainStatus.ConnectFailed
                mainStatusLiveData.value = MainStatus.Unlogined
            }
        })
    }

    fun setNotifyListener(bleDevice: BleDevice?) {
        viewModelScope.launch {
            delay(200)

            BleManager
                .getInstance()
                .notify(bleDevice, SERVICE_UUID, CHARACTERISTIC_UUID_NOTIFY, notifyCallBack)
        }
    }

    fun onResume() {
        isOnPause = false

        bleDevice?.let {
            viewModelScope.launch {
                delay(500)
                refreshTimer.start()
            }
        }
    }

    fun onPause() {
        isOnPause = true
        refreshTimer.cancel()
    }

    /**
     * 資料接收
     */

    private val notifyCallBack = object : BleNotifyCallback() {
        override fun onNotifySuccess() {
            Log.e("ble", "監聽成功")

            viewModelScope.launch(Dispatchers.IO) {
                delay(300)
                repo.fetchPassword()
            }
        }

        override fun onNotifyFailure(exception: BleException?) {
            // 監聽通知失敗
            Log.e("ble", "監聽失敗: ${exception.toString()}")
            if (BleManager.getInstance().isConnected(bleDevice)) {
                setNotifyListener(bleDevice)
            }
        }

        override fun onCharacteristicChanged(data: ByteArray?) {
            // Log.e("ble recive", formatHexString(data, true))

            data?.let { recvData ->
                Log.e("recv", HexUtil.formatHexString(recvData, true))
                val dataBytes = recvData.copyOfRange(3, recvData.size - 2)
                MyApplication.delegate?.recvData(dataBytes)

                if (isOnPause) {
                    return
                }

                when (dataBytes.size) {
                    2 -> {
                        timeoutTimer.cancel()

                        val password: String = ConvertUtil.convertInt16(dataBytes).toString()

                        Log.e("password", "get")

                        if (repo.permission != 2 && repo.password != password) {
                            BleManager.getInstance().disconnect(repo.bleDevice)
                            mainStatusLiveData.value = MainStatus.LoginFailed
                            return
                        }

                        if (repo.permission == 2 && repo.password != "2293") {
                            BleManager.getInstance().disconnect(repo.bleDevice)
                            mainStatusLiveData.value = MainStatus.LoginFailed
                            return
                        }

                        repo.bleDevice?.let { it ->
                            UserConfig.setDeviceName(context, it.name)
                            UserConfig.setMacAddress(context, it.mac)
                        }

                        repo.password?.let { it ->
                            UserConfig.setPassword(context, it)
                        }

                        repo.permission?.let { it ->
                            UserConfig.setPermission(context, it)
                        }

                        when (repo.permission) {
                            0 -> mainStatusLiveData.value = MainStatus.General
                            1 -> mainStatusLiveData.value = MainStatus.Dealer
                            else -> mainStatusLiveData.value = MainStatus.Developer
                        }

                        viewModelScope.launch {
                            delay(500)
                            refreshTimer.start()
                        }
                    }
                    172 -> {
                        motorTorqueLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(8, 12))
                        systemErrorStatusLiveData.value = ConvertUtil.convertUInt32(dataBytes.copyOfRange(16, 20))

                        versionLiveData.value = ConvertUtil.convertUtf8(dataBytes.copyOfRange(32, 40))
                        valveStatusLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(48, 50))
                        valveCurrentLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(56, 60))
                        valveTargetLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(60, 64))
                        correctionMotorTorqueLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(64, 68)).toInt()
                        moduleTemperatureLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(68, 72)).toInt()
                        motorTemperatureLiveData.value = ConvertUtil.convertFloat(dataBytes.copyOfRange(72, 76)).toInt()

                        rpmLiveData.value = ConvertUtil.convertUInt16(dataBytes.copyOfRange(170, 172))
                    }
                    else -> {
                    }
                }
            }
        }
    }

}