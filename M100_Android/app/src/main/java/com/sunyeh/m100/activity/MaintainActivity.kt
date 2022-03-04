package com.sunyeh.m100.activity

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.View
import androidx.lifecycle.Observer
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.viewmodel.MaintainViewModel
import kotlinx.android.synthetic.main.activity_maintain.*
import kotlinx.android.synthetic.main.activity_remote_control.*
import kotlinx.android.synthetic.main.activity_status.*
import kotlinx.android.synthetic.main.activity_status.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class MaintainActivity : BaseActivity() {

    private val viewModel: MaintainViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_maintain)

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
        toolbar.title = getString(R.string.status_title_maintain)

        // 閥門狀態TextView樣式
        val gdFrame = GradientDrawable()
        gdFrame.cornerRadius = 10F * rate
        gdFrame.setColor(Color.WHITE)
        tvTorqueRemainingTimes.background = gdFrame
        tvValveRemainingTimes.background = gdFrame
        tvMotorRemainingTimes.background = gdFrame
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }
    }

    override fun setObserve() {
        viewModel.maintainStatus.observe(this, Observer { status ->
            when (status) {
                SettingStatus.Loading -> {
                    prograss.visibility = View.VISIBLE
                }

                SettingStatus.Timeout -> {
                    setResult(100)
                    finish()
                }

                SettingStatus.Finish -> {
                    prograss.visibility = View.GONE
                }

                SettingStatus.Disconnect -> {
                    setResult(100)
                    finish()
                }

                else -> {
                }
            }
        })

        viewModel.torqueRemainingTimes.observe(this, Observer { value ->
            tvTorqueRemainingTimes.text = "$value"
        })

        viewModel.valveRemainingTimes.observe(this, Observer { value ->
            tvValveRemainingTimes.text = "$value"
        })

        viewModel.motorRemainingTimes.observe(this, Observer { value ->
            val time = getTime(value)
            tvMotorRemainingTimes.text = String.format(getString(R.string.maintain_date_format), time.day, time.hour, time.minute, time.second)
        })

        viewModel.totalValveOffCount.observe(this, Observer { value ->
            tvTotalValveOffCount.text = String.format("%d %s", value, getString(R.string.maintain_count))
        })

        viewModel.totalValveOnCount.observe(this, Observer { value ->
            tvTotalValveOnCount.text = String.format("%d %s", value, getString(R.string.maintain_count))
        })

        viewModel.totalTorqueAllOff.observe(this, Observer { value ->
            tvTotalTorqueAllOff.text = String.format("%d %s", value, getString(R.string.maintain_count))
        })

        viewModel.totalTorqueAllOn.observe(this, Observer { value ->
            tvTotalTorqueAllOn.text = String.format("%d %s", value, getString(R.string.maintain_count))
        })

        viewModel.systemWorkinghours.observe(this, Observer { value ->
            val time = getTime(value)
            tvSystemWorkingHours.text =
                String.format(
                    getString(R.string.maintain_system_working_hours),
                    time.day,
                    time.hour,
                    time.minute,
                    time.second
                )
        })

        viewModel.motorWorkinghours.observe(this, Observer { value ->
            val time = getTime(value)
            tvMotorWorkingHours.text =
                String.format(
                    getString(R.string.maintain_motor_working_hours),
                    time.day,
                    time.hour,
                    time.minute,
                    time.second
                )
        })

        viewModel.totalTorqueOffCount.observe(this, Observer { value ->
            tvTotalTorqueOffCount.text =  String.format("%d %s", value, getString(R.string.maintain_count))
        })

    }

    private fun getTime(seconds: Int): Time {
        return Time(seconds / 86400, seconds % 86400 / 3600, seconds % 3600 / 60, seconds % 3600 % 60)
    }

    data class Time(val day: Int, val hour: Int, val minute: Int, val second: Int)
}