package com.example.mybt.Activity

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.MutableLiveData
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleScanCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.data.BleScanState
import com.clj.fastble.scan.BleScanRuleConfig
import com.example.mybt.Adapter.BleDeviceAdapter
import com.example.mybt.R
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.android.synthetic.main.activity_drawer.*
import kotlinx.android.synthetic.main.activity_main.*
import androidx.lifecycle.Observer
import com.example.mybt.ViewModel.MainViewModel
import com.example.mybt.mainModule
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.ext.android.viewModel
import org.koin.core.context.startKoin
import pub.devrel.easypermissions.AppSettingsDialog
import pub.devrel.easypermissions.EasyPermissions

class MainActivity : BaseActivity(),EasyPermissions.PermissionCallbacks {

    // 危險權限
    private val perms: Array<String> = arrayOf(
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE"
    )

    private lateinit var adapterBleDevice: BleDeviceAdapter
    //利用Koin 建立 viewmodel
    private val viewModel: MainViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupViews()
        setObserve()
        setDrawerListener()
        setOnClickListeners()
        // 檢查授權
        if (!EasyPermissions.hasPermissions(this, *perms)) {
            // 第二次請求授權時，提醒user此項授權的必要性
            EasyPermissions.requestPermissions(this, getString(R.string.perm), 200, *perms)
            return
        } else {
            initBLE()
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if ((requestCode == 200) && (resultCode == RESULT_OK)) {
            coroutineScope.launch {         // 在后台启动一个新的协程并继续
                delay(200)
                drawer.closeDrawers()

                val index: Int = data?.extras?.getInt("index")!!
                val password: String = data.extras?.getString("password").toString()
                val permission: Int = data.extras?.getInt("permission")!!
                 viewModel.connect(index, password, permission)
            }
        }
    }


    override fun onResume() {
        viewModel.onResume()
        super.onResume()
    }

    override fun onPause() {
        viewModel.onPause()
        super.onPause()
    }

    override fun onDestroy() {
        viewModel.disConnect()
        super.onDestroy()
    }

    override fun setupViews() {
        // 綁定recyclerView
        adapterBleDevice = BleDeviceAdapter()
        //.apply =>呼叫RecycleView內部函數
        rvBleDevice.apply {
            addItemDecoration(DividerItemDecoration(this@MainActivity, DividerItemDecoration.VERTICAL))
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = adapterBleDevice
        }
    }

    override fun setOnClickListeners() {
        adapterBleDevice.setListener(object : BleDeviceAdapter.OnItemClickListener {
            override fun onItemClick(index: Int, deviceName: String) {
                BleManager.getInstance().cancelScan()
                val bundle = Bundle()
                bundle.putInt("index", index)
                bundle.putString("deviceName", deviceName)
                startActivityResult(bundle, LoginActivity::class.java)
            }
        })
    }

    override fun setObserve() {
        //LiveData 取值
        viewModel.bleDeviceLiveData.observe(this, Observer { devices ->
            adapterBleDevice.setData(devices)       //傳送BLE Devies裝置訊息給BleDeviceAdapter
        })
    }


    private fun setDrawerListener() {
        drawer.addDrawerListener(object : DrawerLayout.DrawerListener {
            override fun onDrawerStateChanged(newState: Int) {
            }

            override fun onDrawerSlide(drawerView: View, slideOffset: Float) {
            }

            override fun onDrawerClosed(drawerView: View) {
                Log.e("Drawer", "close")
                if (!BleManager.getInstance().isSupportBle || !BleManager.getInstance().isBlueEnable) {
                    return
                }
                viewModel.stopScan()
            }

            override fun onDrawerOpened(drawerView: View) {
                Log.e("Drawer", "open")

                if (!BleManager.getInstance().isSupportBle) {
                    return
                }

                if (!BleManager.getInstance().isBlueEnable) {
                    toastMsg(R.string.ble_disable)
                    return
                }

                btnQuickConnect.isEnabled = false

                coroutineScope.launch {
                    delay(300)
                    viewModel.startScan()
                }
            }
        })

    }

    private fun initBLE() {
        Log.e("ble", "初始化設定")
        BleManager.getInstance().init(application)
        BleManager.getInstance()
            .enableLog(true)
            .setReConnectCount(3, 500)
            .operateTimeout = 10 * 1000


        val scanRuleConfig = BleScanRuleConfig.Builder()
            .setScanTimeOut(10 * 1000)              // scan timeout，default 10s
            .build()

        Log.e("ble", "initScanRule")
        BleManager.getInstance().initScanRule(scanRuleConfig)
    }

    override fun onPermissionsGranted(requestCode: Int, perms: MutableList<String>) {
        if (requestCode == 200) {
            // 檢查是否支援藍芽
            if (!BleManager.getInstance().isSupportBle) {
                toastMsg(getString(R.string.no_support_ble))
                return
            }

            initBLE()
        }
    }

    override fun onPermissionsDenied(requestCode: Int, perms: MutableList<String>) {
        if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
            AppSettingsDialog.Builder(this).build().show()
        }
    }


}