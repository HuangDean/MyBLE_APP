@file:Suppress("WHEN_ENUM_CAN_BE_NULL_IN_JAVA")

package com.sunyeh.m100.activity

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.util.DisplayMetrics
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.clj.fastble.BleManager
import com.clj.fastble.scan.BleScanRuleConfig
import com.sunyeh.m100.MainStatus.*
import com.sunyeh.m100.R
import com.sunyeh.m100.activity.setting.SettingActivity
import com.sunyeh.m100.adapter.BleDeviceAdapter
import com.sunyeh.m100.data.db.UserConfig
import com.sunyeh.m100.viewmodel.MainViewModel
import kotlinx.android.synthetic.main.activity_drawer.*
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.activity_main.dashboardView
import kotlinx.android.synthetic.main.activity_main.tvRpm
import kotlinx.android.synthetic.main.activity_main.tvValveStatus
import kotlinx.android.synthetic.main.activity_main.tvVersion
import kotlinx.android.synthetic.main.activity_remote_control.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.koin.androidx.viewmodel.ext.android.viewModel
import pub.devrel.easypermissions.AppSettingsDialog
import pub.devrel.easypermissions.EasyPermissions

class MainActivity : BaseActivity(), EasyPermissions.PermissionCallbacks {

    // 危險權限
    private val perms: Array<String> = arrayOf(
        "android.permission.ACCESS_FINE_LOCATION",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE"
    )

    private lateinit var adapterBleDevice: BleDeviceAdapter

    private val viewModel: MainViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)

        val screenHeight: Float = displayMetrics.heightPixels.toFloat()
        val screenWidth: Float = displayMetrics.widthPixels.toFloat()

        // 1.7777 -> 16:9 rate
        if ((screenHeight / screenWidth) > 1.777777) {
            setContentView(R.layout.activity_main2)
        } else {
            setContentView(R.layout.activity_main)
        }

        setupViews()
        setObserve()
        setOnClickListeners()
        setDrawerListener()

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

        if (requestCode == 200) {

            if (resultCode == RESULT_OK) {
                coroutineScope.launch {
                    delay(200)
                    drawer.closeDrawers()

                    val index: Int = data?.extras?.getInt("index")!!
                    val password: String = data.extras?.getString("password").toString()
                    val permission: Int = data.extras?.getInt("permission")!!
                    viewModel.connect(index, password, permission)
                }
            } else if (resultCode == 100) {
                toastMsg(getString(R.string.ble_status_disconnect))
                viewModel.disConnect()
                uiReset()
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
        setStatusBarColor(R.color.colorTheme)

        // 閥門狀態TextView樣式
        val gdValveStatus = GradientDrawable()
        gdValveStatus.cornerRadius = 15F * rate
        gdValveStatus.setColor(Color.WHITE)
        gdValveStatus.setStroke(2, getResColor(R.color.colorYellow))
        tvValveStatus.background = gdValveStatus

        // 快速連線按鈕樣式
        val inactiveSd = GradientDrawable()
        inactiveSd.cornerRadius = 10F * rate
        inactiveSd.setColor(Color.GRAY)
        val activeSd = GradientDrawable()
        activeSd.cornerRadius = 10F * rate
        activeSd.setColor(Color.DKGRAY)

        val sld = StateListDrawable()
        sld.addState(intArrayOf(-android.R.attr.state_pressed), inactiveSd)
        sld.addState(intArrayOf(android.R.attr.state_pressed), activeSd)
        btnQuickConnect.background = sld

        // 綁定recyclerView
        adapterBleDevice = BleDeviceAdapter()
        rvBleDevice.apply {
            addItemDecoration(DividerItemDecoration(this@MainActivity, DividerItemDecoration.VERTICAL))
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = adapterBleDevice
        }

        tvDeviceName.text = UserConfig.getDeviceName(this)
        tvDeviceMacAddress.text = UserConfig.getMacAddress(this)
    }

    override fun setObserve() {
        viewModel.bleDeviceLiveData.observe(this, Observer { devices ->
            adapterBleDevice.setData(devices)
        })

        viewModel.mainStatusLiveData.observe(this, Observer { status ->
            hidePrograss()

            when (status) {
                Connecting -> showPrograss()
                ConnectFailed -> toastMsg(getString(R.string.ble_status_faild))
                LoginFailed -> toastMsg(R.string.login_password_error)
                DisConnect -> {
                    toastMsg(R.string.ble_status_disconnect)
                    uiReset()
                }
                QuickEnable -> {
                    tvDeviceName.text = UserConfig.getDeviceName(this)
                    tvDeviceMacAddress.text = UserConfig.getMacAddress(this)
                    btnQuickConnect.isEnabled = true
                }
                Unlogined -> {
                    linearFeature.visibility = View.INVISIBLE
                    imgSetting.visibility = View.GONE
                }
                else -> {
                    imgConnectStatus.setImageResource(R.drawable.ic_green_ball)

                    linearFeature.visibility = View.VISIBLE

                    if (status != General) {
                        imgSetting.visibility = View.VISIBLE
                    }
                }
            }
        })

        viewModel.rpmLiveData.observe(this, Observer {
            tvRpm.text = String.format("%s %s", it.toString(), getString(R.string.main_rpm))
        })

        viewModel.valveCurrentLiveData.observe(this, Observer {
            dashboardView.setValveCurrent(it)
        })

        viewModel.valveTargetLiveData.observe(this, Observer {
            dashboardView.setValveTarget(it)
        })

        viewModel.correctionMotorTorqueLiveData.observe(this, Observer {
            dashboardView.setNm(it)
        })

        viewModel.motorTorqueLiveData.observe(this, Observer {
            dashboardView.setMortorTorque(it)
        })

        viewModel.motorTemperatureLiveData.observe(this, Observer {
            tvMotorTemperature.text = it.toString()

            when (it) {
                in 0..25 -> imgMotorTemperature.setImageResource(R.drawable.img_thermometer25)
                in 26..50 -> imgMotorTemperature.setImageResource(R.drawable.img_thermometer50)
                in 51..80 -> imgMotorTemperature.setImageResource(R.drawable.img_thermometer_80)
                else -> imgMotorTemperature.setImageResource(R.drawable.img_thermometer100)
            }
        })

        viewModel.systemErrorStatusLiveData.observe(this, Observer {
            if (it != 0) {
                imgSystemError.visibility = View.VISIBLE
            } else {
                imgSystemError.visibility = View.INVISIBLE
            }
        })

        viewModel.moduleTemperatureLiveData.observe(this, Observer {
            tvModuleTemperature.text = it.toString()

            when (it) {
                in 0..25 -> imgModuleTemperature.setImageResource(R.drawable.img_thermometer25)
                in 26..50 -> imgModuleTemperature.setImageResource(R.drawable.img_thermometer50)
                in 51..80 -> imgModuleTemperature.setImageResource(R.drawable.img_thermometer_80)
                else -> imgModuleTemperature.setImageResource(R.drawable.img_thermometer100)
            }
        })

        viewModel.versionLiveData.observe(this, Observer {
            tvVersion.text = it
        })

        viewModel.valveStatusLiveData.observe(this, Observer {
            when (it) {
                0 -> tvValveStatus.text = getString(R.string.main_stop)
                1 -> tvValveStatus.text = getString(R.string.main_open)
                else -> tvValveStatus.text = getString(R.string.main_close)
            }
        })
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun setOnClickListeners() {
        imgSystemStatus.setOnClickListener {
            val bundle = Bundle()
            bundle.putBoolean("isSystemStatus", true)
            startActivityResult(bundle, StatusActivity::class.java)
        }

        imgMaintain.setOnClickListener {
            startActivityResult(null, MaintainActivity::class.java)
        }

        imgSystemError.setOnClickListener {
            val bundle = Bundle()
            bundle.putBoolean("isSystemStatus", false)
            startActivityResult(bundle, StatusActivity::class.java)
        }

        imgDisconnect.setOnClickListener {
            viewModel.disConnect()
        }

        imgSetting.setOnClickListener {
            startActivityResult(null, SettingActivity::class.java)
        }

        imgMonitor.setOnClickListener {
            startActivityResult(null, MonitorActivity::class.java)
        }

        imgControl.setOnClickListener {
            startActivityResult(null, RemoteControlActivity::class.java)
        }

        btnQuickConnect.setOnClickListener {
            coroutineScope.launch {
                delay(200)
                drawer.closeDrawers()
                viewModel.quickConnect()
            }
        }

        imgSide.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    drawer.openDrawer(Gravity.LEFT, true)
                }
                else -> {
                }
            }
            return@setOnTouchListener false
        }

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

    private fun setDrawerListener() {
        drawer.addDrawerListener(object : DrawerLayout.DrawerListener {
            override fun onDrawerStateChanged(newState: Int) {
            }

            override fun onDrawerSlide(drawerView: View, slideOffset: Float) {
            }

            override fun onDrawerClosed(drawerView: View) {
                if (!BleManager.getInstance().isSupportBle || !BleManager.getInstance().isBlueEnable) {
                    return
                }

                viewModel.stopScan()
            }

            override fun onDrawerOpened(drawerView: View) {

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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this)
    }

    override fun onPermissionsDenied(requestCode: Int, perms: MutableList<String>) {
        if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
            AppSettingsDialog.Builder(this).build().show()
        }
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

        BleManager.getInstance().initScanRule(scanRuleConfig)
    }


    @SuppressLint("SetTextI18n")
    private fun uiReset() {
        imgConnectStatus.setImageResource(R.drawable.ic_red_ball)
        btnQuickConnect.isEnabled = false

        tvRpm.text = "0 RPM"
        tvModuleTemperature.text = "00"
        tvMotorTemperature.text = "00"

        imgModuleTemperature.setImageResource(R.drawable.img_thermometer0)
        imgMotorTemperature.setImageResource(R.drawable.img_thermometer0)

        linearFeature.visibility = View.INVISIBLE
        imgSetting.visibility = View.GONE
        imgSystemError.visibility = View.INVISIBLE

        dashboardView.setValveTarget(0F)
        dashboardView.setValveCurrent(0F)
        dashboardView.setMortorTorque(0F)
    }

    private fun showPrograss() {
        prograss.visibility = View.VISIBLE
    }

    private fun hidePrograss() {
        prograss.visibility = View.INVISIBLE
    }

}
