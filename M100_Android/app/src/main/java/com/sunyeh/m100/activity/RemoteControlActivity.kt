package com.sunyeh.m100.activity

import android.annotation.SuppressLint
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import androidx.lifecycle.Observer
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.utils.CommonUtil
import com.sunyeh.m100.viewmodel.RemoteControlViewModel
import kotlinx.android.synthetic.main.activity_remote_control.*
import kotlinx.android.synthetic.main.activity_remote_control.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class RemoteControlActivity : BaseActivity() {

    private val viewModel: RemoteControlViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_remote_control)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getData()
    }

    override fun onDestroy() {
        viewModel.onDestory()
        super.onDestroy()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.remote_title)

        val gdFrame = GradientDrawable()
        gdFrame.setStroke(CommonUtil.dp2px(this, 3F).toInt(), Color.GRAY)
        tvRpm.background = gdFrame
        tvTemp.background = gdFrame

        // 閥門狀態TextView樣式
        val gdValveStatus = GradientDrawable()
        gdValveStatus.cornerRadius = 15F * rate
        gdValveStatus.setColor(Color.WHITE)
        gdValveStatus.setStroke(2, getResColor(R.color.colorYellow))
        tvValveStatus.background = gdValveStatus
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        btnExit.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    viewModel.exit()
                }
                MotionEvent.ACTION_UP -> {
                    viewModel.up()
                }
                else -> {
                }
            }
            return@setOnTouchListener false
        }

        btnPrev.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    viewModel.prev()
                }
                MotionEvent.ACTION_UP -> {
                    viewModel.up()
                }
                else -> {
                }
            }
            return@setOnTouchListener false
        }

        btnNext.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    viewModel.next()
                }
                MotionEvent.ACTION_UP -> {
                    viewModel.up()
                }
                else -> {
                }
            }
            return@setOnTouchListener false
        }

        btnEnter.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    viewModel.enter()
                }
                MotionEvent.ACTION_UP -> {
                    viewModel.up()
                }
                else -> {
                }
            }
            return@setOnTouchListener false
        }
    }

    @SuppressLint("SetTextI18n")
    override fun setObserve() {

        viewModel.remoteControlStatus.observe(this, Observer { status ->
            when (status) {
                SettingStatus.Timeout -> {
                    setResult(100)
                    finish()
                }

                SettingStatus.Disconnect -> {
                    setResult(100)
                    finish()
                }

                else -> {
                }
            }
        })

        viewModel.rpmLiveData.observe(this, Observer { value ->
            tvRpm.text = "$value RPM"
        })

        viewModel.tempLiveData.observe(this, Observer { value ->
            pbTemp.progress = value
            tvTemp.text = "$value ℃"
        })

        viewModel.dashboardTorque.observe(this, Observer { value ->
            dashboardView.setMortorTorque(value)
        })

        viewModel.valveCurrentLiveData.observe(this, Observer { value ->
            dashboardView.setValveCurrent(value)
        })

        viewModel.valveTargetLiveData.observe(this, Observer { value ->
            dashboardView.setValveTarget(value)
        })

        viewModel.correctionMotorTorqueLiveData.observe(this, Observer { value ->
            dashboardView.setNm(value.toInt())
        })

        viewModel.versionLiveData.observe(this, Observer { value ->
            tvVersion.text = value
        })

        viewModel.valveStatusLiveData.observe(this, Observer { value ->
            tvValveStatus.text = value
        })

    }

}