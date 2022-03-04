package com.sunyeh.m100.activity.setting

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.Button
import androidx.lifecycle.Observer
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.viewmodel.ControlModelConfigViewModel
import com.xw.repo.BubbleSeekBar
import kotlinx.android.synthetic.main.activity_control_mode_config.*
import kotlinx.android.synthetic.main.activity_product_config.prograss
import kotlinx.android.synthetic.main.activity_setting.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class ControlModeConfigActivity : BaseActivity() {

    private val viewModel: ControlModelConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_control_mode_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getInputModeChannel1()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.control_mode_config_title)
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        swRemoteModeConfig.setOnCheckedChangeListener { view, isChecked ->
            if (!isChecked) {
                view.text = getString(R.string.config_off)
                viewModel.saveData(0, 0)
            } else {
                view.text = getString(R.string.config_on)
                viewModel.saveData(0, 1)
            }
        }

        spRemoteModeConfig.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(1, position)
            }
        }

        sbProportional.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
                viewModel.saveData(2, (progressFloat * 10).toInt())
            }

            override fun getProgressOnFinally(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }
        }

        cbDigitalInputChannel.setOnCheckedChangeListener { buttonView, isChecked ->
            if (!isChecked) {
                buttonView.text = getString(R.string.config_nc)
                viewModel.saveData(3, 0)
            } else {
                buttonView.text = getString(R.string.config_no)
                viewModel.saveData(3, 1)
            }
        }

        swChannel.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                tvChannelTitle.text = getString(R.string.control_mode_config_signal_input_mode1)
                viewModel.getInputModeChannel1()
            } else {
                tvChannelTitle.text = getString(R.string.control_mode_config_signal_input_mode2)
                viewModel.getInputModeChannel2()
            }
        }

        btnDigitalInputChannel.setOnClickListener {
            it.tag = if ((it.tag as Int) == 2) 0 else it.tag as Int + 1
            viewModel.saveData(4, it.tag as Int)
        }

        btnProportionalInputChannel.setOnClickListener {
            it.tag = if ((it.tag as Int) == 2) 0 else it.tag as Int + 1
            if (it.tag as Int > 2) {
                it.tag = 0
            }
            viewModel.saveData(5, it.tag as Int)
        }

        btnProportionalOutputChannel.setOnClickListener {
            it.tag = if ((it.tag as Int) == 2) 0 else it.tag as Int + 1
            if (it.tag as Int > 2) {
                it.tag = 0
            }
            viewModel.saveData(6, it.tag as Int)
        }

        spInputModeConfig.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(7, position)
            }
        }

        spOutputModeConfig.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(8, position)
            }
        }
    }

    override fun setObserve() {
        viewModel.controlModelConfigStatusLiveData.observe(this, Observer { status ->
            when (status) {
                SettingStatus.Loading -> {
                    prograss.visibility = View.VISIBLE
                }

                SettingStatus.Timeout -> {
                    setResult(Activity.RESULT_OK)
                    finish()
                }

                SettingStatus.Finish -> {
                    prograss.visibility = View.GONE
                }

                SettingStatus.Disconnect -> {
                    setResult(Activity.RESULT_OK)
                    finish()
                }

                else -> {
                }
            }
        })

        viewModel.inputModeConfigLiveData.observe(this, Observer { value ->
            spInputModeConfig.setSelection(value)
        })

        viewModel.outputConfigLiveData.observe(this, Observer { value ->
            spOutputModeConfig.setSelection(value)
        })

        viewModel.inputSensitivityLiveData.observe(this, Observer { value ->
            sbProportional.setProgress(value.toFloat() / 10)
        })

        viewModel.digitalInputEnableLiveData.observe(this, Observer { value ->
            if (value == 0) {
                cbDigitalInputChannel.isChecked = false
                cbDigitalInputChannel.text = getString(R.string.config_nc)
            } else {
                cbDigitalInputChannel.isChecked = true
                cbDigitalInputChannel.text = getString(R.string.config_no)
            }
        })

        viewModel.proportionalInputLiveData.observe(this, Observer { value ->
            when (value) {
                1 -> {
                    btnProportionalInputChannel.tag = 1
                    btnProportionalInputChannel.setEnableStyle()
                    btnProportionalInputChannel.text = getString(R.string.ch1)
                }
                2 -> {
                    btnProportionalInputChannel.tag = 2
                    btnProportionalInputChannel.setEnableStyle()
                    btnProportionalInputChannel.text = getString(R.string.ch2)
                }
                else -> {
                    btnProportionalInputChannel.tag = 0
                    btnProportionalInputChannel.setDisableStyle()
                    btnProportionalInputChannel.text = getString(R.string.disable)
                }
            }
        })

        viewModel.proportionalOutputLiveData.observe(this, Observer { value ->
            when (value) {
                1 -> {
                    btnProportionalOutputChannel.tag = 1
                    btnProportionalOutputChannel.setEnableStyle()
                    btnProportionalOutputChannel.text = getString(R.string.ch1)
                }
                2 -> {
                    btnProportionalOutputChannel.tag = 2
                    btnProportionalOutputChannel.setEnableStyle()
                    btnProportionalOutputChannel.text = getString(R.string.ch2)
                }
                else -> {
                    btnProportionalOutputChannel.tag = 0
                    btnProportionalOutputChannel.setDisableStyle()
                    btnProportionalOutputChannel.text = getString(R.string.disable)
                }
            }
        })

        viewModel.digitalInputLiveData.observe(this, Observer { value ->
            when (value) {
                1 -> {
                    btnDigitalInputChannel.tag = 1
                    btnDigitalInputChannel.setEnableStyle()
                    btnDigitalInputChannel.text = getString(R.string.ch1)
                }
                2 -> {
                    btnDigitalInputChannel.tag = 2
                    btnDigitalInputChannel.setEnableStyle()
                    btnDigitalInputChannel.text = getString(R.string.ch2)
                }
                else -> {
                    btnDigitalInputChannel.tag = 0
                    btnDigitalInputChannel.setDisableStyle()
                    btnDigitalInputChannel.text = getString(R.string.disable)
                }
            }
        })

        viewModel.remoteControlModeSwitchLiveData.observe(this, Observer { value ->
            swRemoteModeConfig.isChecked = value != 0
        })

        viewModel.remoteControlModeLiveData.observe(this, Observer { value ->
            spRemoteModeConfig.setSelection(value)
        })

    }

    private fun Button.setEnableStyle() {
        val gdInactiveSubmit = GradientDrawable()
        gdInactiveSubmit.cornerRadius = 10F * rate
        gdInactiveSubmit.setColor(Color.rgb(160, 205, 99))

        val gdActiveSubmit = GradientDrawable()
        gdActiveSubmit.cornerRadius = 10F * rate
        gdActiveSubmit.setColor(Color.GRAY)

        val sldSubmit = StateListDrawable()
        sldSubmit.addState(intArrayOf(-android.R.attr.state_pressed), gdInactiveSubmit)
        sldSubmit.addState(intArrayOf(android.R.attr.state_pressed), gdActiveSubmit)
        this.background = sldSubmit
    }

    private fun Button.setDisableStyle() {
        val gdInactiveSubmit = GradientDrawable()
        gdInactiveSubmit.cornerRadius = 10F * rate
        gdInactiveSubmit.setColor(Color.rgb(176, 176, 176))

        val gdActiveSubmit = GradientDrawable()
        gdActiveSubmit.cornerRadius = 10F * rate
        gdActiveSubmit.setColor(Color.GRAY)

        val sldSubmit = StateListDrawable()
        sldSubmit.addState(intArrayOf(-android.R.attr.state_pressed), gdInactiveSubmit)
        sldSubmit.addState(intArrayOf(android.R.attr.state_pressed), gdActiveSubmit)
        this.background = sldSubmit
    }

}