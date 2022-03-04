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
import com.sunyeh.m100.adapter.SystemAdapter
import com.sunyeh.m100.viewmodel.SystemConfigViewModel
import kotlinx.android.synthetic.main.activity_product_config.prograss
import kotlinx.android.synthetic.main.activity_setting.toolbar
import kotlinx.android.synthetic.main.activity_system_config.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class SystemConfigActivity : BaseActivity() {

    private lateinit var adapterSystem: SystemAdapter

    private val viewModel: SystemConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_system_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getData()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.system_config_title)

        adapterSystem = SystemAdapter(this)
        rvSystem.apply {
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@SystemConfigActivity)
            adapter = adapterSystem
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        adapterSystem.setListener(
            object : SystemAdapter.OnItemClickListener {
                override fun onItemClick(index: Int, value: String) {
                    viewModel.saveData(index, value)
                }
            }, object : SystemAdapter.OnItemSelectedListener {
                override fun onItemSelected(index: Int, value: String) {
                    viewModel.saveData(index, value)
                }
            })
    }

    override fun setObserve() {
        viewModel.systemConfigStatusLiveData.observe(this, Observer { status ->
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

        viewModel.languageLiveData.observe(this, Observer { value ->
            adapterSystem.setData(0, value)
        })

        viewModel.lightDefinitionLiveData.observe(this, Observer { value ->
            adapterSystem.setData(1, value)
        })

        viewModel.maxOutputTorqueLiveData.observe(this, Observer { value ->
            adapterSystem.setData(2, value)
        })

        viewModel.acVoltagePhaseLiveData.observe(this, Observer { value ->
            adapterSystem.setData(3, value)
        })

        viewModel.acVoltageConfigLiveData.observe(this, Observer { value ->
            adapterSystem.setData(4, value)
        })
    }

}