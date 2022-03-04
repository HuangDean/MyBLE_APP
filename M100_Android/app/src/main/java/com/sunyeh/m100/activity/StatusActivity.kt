package com.sunyeh.m100.activity

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.adapter.StatusAdapter
import com.sunyeh.m100.viewmodel.StatusViewModel
import kotlinx.android.synthetic.main.activity_status.*
import kotlinx.android.synthetic.main.activity_status.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel

class StatusActivity : BaseActivity() {

    private lateinit var adapterStatus: StatusAdapter

    private val viewModel: StatusViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_status)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.isSystemStatus = intent.extras?.getBoolean("isSystemStatus")!!
        viewModel.getData()
    }

    override fun onDestroy() {
        viewModel.onDestory()
        super.onDestroy()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)

        intent.extras?.getBoolean("isSystemStatus")?.let {
            toolbar.title = if (it) getString(R.string.status_title_system) else getString(R.string.status_title_error)
            adapterStatus = StatusAdapter(this, it)
            rvStatus.apply {
                setHasFixedSize(true)
                addItemDecoration(DividerItemDecoration(this@StatusActivity, DividerItemDecoration.VERTICAL))
                layoutManager = LinearLayoutManager(this@StatusActivity)
                adapter = adapterStatus
            }
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }
    }

    override fun setObserve() {
        viewModel.uiStatusLiveData.observe(this, Observer { status ->
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

        viewModel.statusCodeLiveData.observe(this, Observer { status ->
            adapterStatus.updateContent(status)
        })
    }

}