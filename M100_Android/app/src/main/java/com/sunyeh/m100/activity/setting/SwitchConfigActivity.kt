package com.sunyeh.m100.activity.setting

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.Spinner
import androidx.lifecycle.Observer
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.viewmodel.SwitchConfigViewModel
import com.xw.repo.BubbleSeekBar
import kotlinx.android.synthetic.main.activity_setting.toolbar
import kotlinx.android.synthetic.main.activity_switch_config.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class SwitchConfigActivity : BaseActivity() {

    private val viewModel: SwitchConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_switch_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getDataOff()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.switch_config_title)

        customPrograss.tag = 0
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        swCenter.setOnCheckedChangeListener { view, isChecked ->
            if (isChecked) {
                view.text = getString(R.string.switch_config_open)

                customPrograss.tag = 1

                sbRangeOfEnd.configBuilder
                    .min(80F)
                    .max(98F)
                    .build()
                viewModel.getDataOn()
            } else {
                view.text = getString(R.string.switch_config_close)

                customPrograss.tag = 0

                sbRangeOfEnd.configBuilder
                    .min(2F)
                    .max(20F)
                    .build()
                viewModel.getDataOff()
            }
        }

        sbOutputRpm.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
                viewModel.saveData(0, progress)
            }

            override fun getProgressOnFinally(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }
        }

        sbUngentRpm.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
                viewModel.saveData(1, progress)
            }

            override fun getProgressOnFinally(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }
        }

        sbRangeOfEnd.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
                if (!fromUser) {
                    return
                }
                if (customPrograss.tag == 0) {
                    customPrograss.setMin(progress)
                } else {
                    customPrograss.setMax(progress)
                }

            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
                viewModel.saveData(2, progress)
            }

            override fun getProgressOnFinally(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float, fromUser: Boolean) {
            }
        }

        spRetry.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(4, parent?.selectedItem.toString().split("%")[0].toInt())
            }
        }

        spRangeOfEndMode.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(5, position)
            }
        }

        spRangeOfEndTorque.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(6, parent?.selectedItem.toString().split("%")[0].toInt())
            }
        }

        spRangeOfEndStroke.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(7, parent?.selectedItem.toString().split("%")[0].toInt())
            }
        }

        swCloseTighly.setOnCheckedChangeListener { buttonView, isChecked ->
            if (isChecked) {
                buttonView.text = getString(R.string.config_on)
                viewModel.saveData(8, 1)
            } else {
                buttonView.text = getString(R.string.config_off)
                viewModel.saveData(8, 0)
            }
        }

        spCloseDefinition.onItemSelectedListener = object : AdapterView.OnItemSelectedListener{
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                viewModel.saveData(9, position)
            }
        }

    }

    override fun setObserve() {
        viewModel.switchConfigStatusLiveData.observe(this, Observer { status ->
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

        viewModel.outputRpmLiveData.observe(this, Observer { value ->
            sbOutputRpm.setProgress(value)
        })

        viewModel.ungentRpmLiveData.observe(this, Observer { value ->
            sbUngentRpm.setProgress(value)
        })

        viewModel.rangeOfEndLiveData.observe(this, Observer { value ->
            sbRangeOfEnd.setProgress(value)
        })

        viewModel.limitLiveData.observe(this, Observer { value ->
            tvLimitPosition.text = value
        })

        viewModel.torqueRetryLiveData.observe(this, Observer { value ->
            spRetry.setText(value)
        })

        viewModel.rangeOfEndModeLiveData.observe(this, Observer { value ->
            spRangeOfEndMode.setText(value)
        })

        viewModel.rangeOfEndTorqueLiveData.observe(this, Observer { value ->
            spRangeOfEndTorque.setText(value)
        })

        viewModel.strokeTorqueLiveData.observe(this, Observer { value ->
            spRangeOfEndStroke.setText(value)
        })

        viewModel.closeTightlyLiveData.observe(this, Observer { value ->
            swCloseTighly.isChecked = value != 0
        })

        viewModel.closeDefinitionLiveData.observe(this, Observer { value ->
            spCloseDefinition.setText(value)
        })

        // prograss 用
        viewModel.prograssMinLiveData.observe(this, Observer { value ->
            customPrograss.setMin(value)
        })

        viewModel.prograssMaxLiveData.observe(this, Observer { value ->
            customPrograss.setMax(value)
        })

        viewModel.prograssStrokeOffLiveData.observe(this, Observer { value ->
            tvStrokeOff.text = value
        })

        viewModel.prograssStrokeOnLiveData.observe(this, Observer { value ->
            tvStrokeOn.text = value
        })

        viewModel.prograssRangeOfEndOffLiveData.observe(this, Observer { value ->
            tvRangeOfEndOff.text = value
        })

        viewModel.prograssRangeOfEndOnLiveData.observe(this, Observer { value ->
            tvRangeOfEndOn.text = value
        })

    }

    private fun Spinner.setText(text: String) {
        for (i in 0 until this.adapter.count) {
            if (this.adapter.getItem(i).toString().contains(text)) {
                this.setSelection(i)
            }
        }
    }
}