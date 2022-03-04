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
import com.sunyeh.m100.adapter.MaintainAdapter
import com.sunyeh.m100.viewmodel.MaintainConfigViewModel
import kotlinx.android.synthetic.main.activity_maintain_config.*
import kotlinx.android.synthetic.main.activity_setting.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class MaintainConfigActivity : BaseActivity() {

    private lateinit var adapterMaintain: MaintainAdapter

    private val viewModel: MaintainConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_maintain_config)

        setupViews()
        setOnClickListeners()
        setObserve()
        viewModel.getData()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.maintain_config_title)

        adapterMaintain = MaintainAdapter(this)
        rvMaintain.apply {
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@MaintainConfigActivity)
            adapter = adapterMaintain
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        adapterMaintain.setListener(object : MaintainAdapter.OnItemClickListener {
            override fun onItemClick(index: Int, value: String) {
                when (index) {
                    0 -> {
                        if (value.toInt() !in 3000..10000000) {
                            toastMsg("${getString(R.string.out_of_range)} 3000~10000000")
                            return
                        }
                    }

                    1 -> {
                        if (value.toInt() !in 3000..10000) {
                            toastMsg("${getString(R.string.out_of_range)} 3000~10000")
                            return
                        }
                    }

                    2 -> {
                        if (value.toInt() !in 100..2500) {
                            toastMsg("${getString(R.string.out_of_range)} 100~2500")
                            return
                        }
                    }

                }

                viewModel.saveData(index, value)
            }
        })
    }

    override fun setObserve() {
        viewModel.maintainConfigStatusLiveData.observe(this, Observer { status ->
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

        viewModel.switchTimesLiveData.observe(this, Observer { value ->
            adapterMaintain.setData(0, value)
        })

        viewModel.torqueTimesLiveData.observe(this, Observer { value ->
            adapterMaintain.setData(1, value)
        })

        viewModel.motorWorkTimeLiveData.observe(this, Observer { value ->
            adapterMaintain.setData(2, value)
        })

    }

}