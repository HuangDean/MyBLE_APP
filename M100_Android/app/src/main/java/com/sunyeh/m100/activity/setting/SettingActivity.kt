package com.sunyeh.m100.activity.setting

import android.content.Intent
import android.os.Bundle
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.sunyeh.m100.R
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.adapter.SettingAdapter
import kotlinx.android.synthetic.main.activity_setting.*
import kotlinx.android.synthetic.main.activity_setting.toolbar

class SettingActivity : BaseActivity() {

    private lateinit var adapterSettings: SettingAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_setting)

        setupViews()
        setOnClickListeners()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.setting_title)

        adapterSettings = SettingAdapter(applicationContext)
        rvSetting.apply {
            addItemDecoration(DividerItemDecoration(this@SettingActivity, DividerItemDecoration.VERTICAL))
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@SettingActivity)
            adapter = adapterSettings
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        adapterSettings.setListener(object : SettingAdapter.OnItemClickListener {
            override fun onItemClick(index: Int) {
                when (index) {
                    0 -> startActivityResult(null, ProductConfigActivity::class.java)
                    1 -> startActivityResult(null, MaintainConfigActivity::class.java)
                    2 -> startActivityResult(null, SystemConfigActivity::class.java)
                    3 -> startActivityResult(null, UngentConfigActivity::class.java)
                    4 -> startActivityResult(null, SwitchConfigActivity::class.java)
                    5 -> startActivityResult(null, ControlModeConfigActivity::class.java)
                    6 -> startActivityResult(null, OutputConfigActivity::class.java)
                }
            }
        })
    }

    override fun setObserve() {
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 200 && resultCode == RESULT_OK) {
            setResult(100)
            finish()
        }
    }

}