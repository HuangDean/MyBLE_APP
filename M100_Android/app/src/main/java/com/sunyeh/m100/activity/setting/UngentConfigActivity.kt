package com.sunyeh.m100.activity.setting

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.adapter.UngentAdapter
import com.sunyeh.m100.viewmodel.UngentConfigViewModel
import kotlinx.android.synthetic.main.activity_product_config.prograss
import kotlinx.android.synthetic.main.activity_product_config.rvProduct
import kotlinx.android.synthetic.main.activity_setting.toolbar
import kotlinx.android.synthetic.main.activity_ungent_config.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class UngentConfigActivity : BaseActivity() {

    private lateinit var adapterUngent: UngentAdapter

    private val viewModel: UngentConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ungent_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getData()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.ungent_config_title)

        adapterUngent = UngentAdapter(this)
        rvProduct.apply {
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@UngentConfigActivity)
            adapter = adapterUngent
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        adapterUngent.setListener(
            object : UngentAdapter.OnItemClickListener {
                override fun onItemClick(index: Int, value: String) {
                    when (index) {
                        2 -> {
                            if (value.toInt() !in 0..100) {
                                toastMsg("${getString(R.string.out_of_range)} 0~100")
                                return
                            }
                        }

                        4 -> {
                            if (value.toInt() !in 0..120) {
                                toastMsg("${getString(R.string.out_of_range)} 0~120")
                                return
                            }
                        }
                    }

                    viewModel.saveData(index, value)
                }
            }, object : UngentAdapter.OnItemSelectedListener {
                override fun onItemSelected(index: Int, value: String) {
                    viewModel.saveData(index, value)
                }
            }, object : UngentAdapter.SwitchChangeListener {
                override fun onSwitchChange(value: Boolean) {
                    viewModel.saveData(3, if (value) "1" else "0")
                }
            }
        )

        cbUngentIntputMode.setOnCheckedChangeListener { _, isChecked ->
            viewModel.saveData(5, if (isChecked) "1" else "0")
        }
    }

    override fun setObserve() {
        viewModel.ungentConfigStatusLiveData.observe(this, Observer { status ->
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

        viewModel.openSignalActionLiveData.observe(this, Observer { value ->
            adapterUngent.setData(0, value)
        })

        viewModel.ungentActionLiveData.observe(this, Observer { value ->
            adapterUngent.setData(1, value)
        })

        viewModel.signalUngentPositionLiveData.observe(this, Observer { value ->
            adapterUngent.setData(2, value)
        })

        viewModel.motorWarningSwitchLiveData.observe(this, Observer { value ->
            adapterUngent.setData(3, value)
        })

        viewModel.motorWarningTempeatureLiveData.observe(this, Observer { value ->
            adapterUngent.setData(4, value)
        })

        viewModel.ungentIntputSwitchLiveData.observe(this, Observer { value ->
            cbUngentIntputMode.isChecked = value != 0
            cbUngentIntputMode.text = if (cbUngentIntputMode.isChecked) "NO" else "NC"
        })
    }

}