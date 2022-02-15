package com.example.mybt.ViewModel

import android.bluetooth.BluetoothGatt
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
import com.example.mybt.Data.MainRepository
import com.example.mybt.MainStatus
import com.example.mybt.MyApplication
import com.example.mybt.MyApplication.Companion.CHARACTERISTIC_UUID_NOTIFY
import com.example.mybt.MyApplication.Companion.SERVICE_UUID
import com.example.mybt.MyApplication.Companion.bleDevice
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay as delay1

class MainViewModel(val repo: MainRepository): BaseViewModel(){

    val bleDeviceLiveData = MutableLiveData<ArrayList<BleDevice>>()
    val mainStatusLiveData = MutableLiveData<MainStatus>()


    private val timeoutTimer: CountDownTimer = object : CountDownTimer(10000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("timeout剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            Log.e("timeout剩餘時間", "timeout")
//            bleDevice?.let {
//                BleManager.getInstance().disconnect(it)
//            }
//            mainStatusLiveData.value = MainStatus.ConnectFailed
        }
    }

    private val refreshTimer: CountDownTimer = object : CountDownTimer(1000, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            Log.e("refreshTimer剩餘時間", "$millisUntilFinished")
        }

        override fun onFinish() {
            Log.e("time observer", "finish")

            bleDevice?.let {
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

            override fun onLeScan(bleDevice:BleDevice ) {
                super.onLeScan(bleDevice);
            }

            override fun onScanning(bleDevice: BleDevice?) {
                Log.e("MainViewModel", "onScanning")
                bleDevice?.let {
                    if (!it.name.isNullOrBlank()) {
                        Log.e("MainViewModel", "onScanning")
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
                                    kotlinx.coroutines.delay(300)
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
                        kotlinx.coroutines.delay(500)
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

    fun onResume() {
        isOnPause = false

        bleDevice?.let {
            viewModelScope.launch {
                delay1(500)
                refreshTimer.start()
            }
        }
    }

    fun onPause() {
        isOnPause = true
        refreshTimer.cancel()
    }

    fun setNotifyListener(bleDevice: BleDevice?) {
        viewModelScope.launch {
            kotlinx.coroutines.delay(200)

            BleManager
                .getInstance()
                .notify(bleDevice, SERVICE_UUID, CHARACTERISTIC_UUID_NOTIFY, notifyCallBack)
        }
    }

    /**
     * 資料接收
     */
    private val notifyCallBack = object : BleNotifyCallback() {
        override fun onNotifySuccess() {
            Log.e("ble", "監聽成功")

            viewModelScope.launch(Dispatchers.IO) {
                kotlinx.coroutines.delay(300)
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
                //***/
                //***/
            }
        }
    }
}