package com.sunyeh.m100.activity.setting

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.core.view.size
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.adapter.OutputAdapter
import com.sunyeh.m100.viewmodel.OutputConfigViewModel
import kotlinx.android.synthetic.main.activity_output_config.*
import kotlinx.android.synthetic.main.activity_setting.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class OutputConfigActivity : BaseActivity() {

    private lateinit var adapterOutput: OutputAdapter

    private val viewModel: OutputConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_output_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getChannel1Data()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.output_config_title)

        adapterOutput = OutputAdapter(this)
        rvOutput.apply {
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@OutputConfigActivity)
            adapter = adapterOutput
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        swChannel.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                imgChannel.setImageResource(R.drawable.ic_ch1)
                viewModel.getChannel1Data()
            } else {
                imgChannel.setImageResource(R.drawable.ic_ch2)
                viewModel.getChannel2Data()
            }
        }

        adapterOutput.setListener(
            object : OutputAdapter.OnItemSelected {
                override fun onItemSelected(index: Int, value: Int) {
                    viewModel.saveData(index, value)
                }
            },
            object : OutputAdapter.OnCheckChange {
                override fun onCheckChange(index: Int, value: Int) {
                    viewModel.saveData(index, value)
                }
            }
        )

//        btnOutputChannel.setOnClickListener {
//            when (it.tag) {
//                0 -> {
//                    it.tag = 1
//                    viewModel.saveData(8, it.tag as Int)
//                    btnOutputChannel.text = getString(R.string.disable)
//                }
//                1 -> {
//                    it.tag = 2
//                    viewModel.saveData(8, it.tag as Int)
//                    btnOutputChannel.text = getString(R.string.ch1)
//                }
//                2 -> {
//                    it.tag = 3
//                    viewModel.saveData(8, it.tag as Int)
//                    btnOutputChannel.text = getString(R.string.ch2)
//                }
//                3 -> {
//                    it.tag = 0
//                    viewModel.saveData(8, it.tag as Int)
//                    btnOutputChannel.text = getString(R.string.ch1_ch2)
//                }
//            }
//        }
    }

    override fun setObserve() {
        viewModel.outputConfigStatusLiveData.observe(this, Observer { status ->
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

        viewModel.output1LiveData.observe(this, Observer { value ->
            adapterOutput.setData(0, value)
        })

        viewModel.output2LiveData.observe(this, Observer { value ->
            adapterOutput.setData(1, value)
        })

        viewModel.output3LiveData.observe(this, Observer { value ->
            adapterOutput.setData(2, value)
        })

        viewModel.output4LiveData.observe(this, Observer { value ->
            adapterOutput.setData(3, value)
        })

        viewModel.output1StatusLiveData.observe(this, Observer { value ->
            adapterOutput.setStatus(0, value)
        })

        viewModel.output2StatusLiveData.observe(this, Observer { value ->
            adapterOutput.setStatus(1, value)
        })

        viewModel.output3StatusLiveData.observe(this, Observer { value ->
            adapterOutput.setStatus(2, value)
        })

        viewModel.output4StatusLiveData.observe(this, Observer { value ->
            adapterOutput.setStatus(3, value)
        })

//        viewModel.digitalOutputChannelLiveData.observe(this, Observer { value ->
//            btnOutputChannel.tag = value
//
//            when (value) {
//                0 -> {
//                    btnOutputChannel.tag = 0
//                    btnOutputChannel.text = getString(R.string.disable)
//                    btnOutputChannel.setDisableStyle()
//                }
//
//                1 -> {
//                    btnOutputChannel.tag = 1
//                    btnOutputChannel.text = getString(R.string.ch1)
//                    btnOutputChannel.setEnableStyle()
//                }
//
//                2 -> {
//                    btnOutputChannel.tag = 2
//                    btnOutputChannel.text = getString(R.string.ch2)
//                    btnOutputChannel.setEnableStyle()
//                }
//
//                3 -> {
//                    btnOutputChannel.tag = 3
//                    btnOutputChannel.text = getString(R.string.ch1_ch2)
//                    btnOutputChannel.setEnableStyle()
//                }
//            }
//        })

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