package com.sunyeh.m100.activity.setting

import android.os.Bundle
import android.view.View
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus.*
import com.sunyeh.m100.activity.BaseActivity
import com.sunyeh.m100.adapter.ProductAdapter
import com.sunyeh.m100.viewmodel.ProductConfigViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import kotlinx.android.synthetic.main.activity_product_config.*

class ProductConfigActivity : BaseActivity() {

    private lateinit var adapterProduct: ProductAdapter

    private val viewModel: ProductConfigViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_product_config)

        setupViews()
        setOnClickListeners()
        setObserve()

        viewModel.getData()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.setting_product_config)

        adapterProduct = ProductAdapter(this)
        rvProduct.apply {
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(this@ProductConfigActivity)
            adapter = adapterProduct
        }
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        adapterProduct.setListener(
            object : ProductAdapter.OnItemClickListener {
                override fun onItemClick(index: Int, value: String) {
                    when (index) {
                        0 -> {
                            if (value.toInt() !in 1..247) {
                                toastMsg("${getString(R.string.out_of_range)} 1~247")
                                return
                            }
                        }

                        2 -> {
                            if (value.toInt() !in 1..125) {
                                toastMsg("${getString(R.string.out_of_range)} 1~125")
                                return
                            }
                        }

                        3 -> {
                            if (value.toInt() !in 1..65535) {
                                toastMsg("${getString(R.string.out_of_range)} 1~65535")
                                return
                            }
                        }

                        4 -> {
                            if (value.toByteArray(Charsets.UTF_8).size > 10) {
                                toastMsg("${getString(R.string.out_of_range)} 10個字元")
                                return
                            }
                        }

                        5 -> {
                            if (value.toByteArray(Charsets.UTF_8).size > 16) {
                                toastMsg("${getString(R.string.out_of_range)} 16個字元")
                                return
                            }
                        }

                        6 -> {
                            if (value.toByteArray(Charsets.UTF_8).size > 10) {
                                toastMsg("${getString(R.string.out_of_range)} 10個字元")
                                return
                            }
                        }

                        7 -> {
                            if (value.toByteArray(Charsets.UTF_8).size > 16) {
                                toastMsg("${getString(R.string.out_of_range)} 16個字元")
                                return
                            }
                        }
                    }

                    viewModel.saveData(index, value)
                }
            }, object : ProductAdapter.OnItemSelectedListener {
                override fun onItemSelected(index: Int, value: String) {
                    viewModel.saveData(index, value)
                }
            })
    }

    override fun setObserve() {
        viewModel.productConfigStatusLiveData.observe(this, Observer { status ->
            when (status) {
                Loading -> {
                    prograss.visibility = View.VISIBLE
                }

                Timeout -> {
                    setResult(RESULT_OK)
                    finish()
                }

                Finish -> {
                    prograss.visibility = View.GONE
                }

                Disconnect -> {
                    setResult(RESULT_OK)
                    finish()
                }

                else -> {
                }
            }
        })

        viewModel.modbusIdLiveData.observe(this, Observer { value ->
            adapterProduct.setData(0, value)
        })

        viewModel.baudRateLiveData.observe(this, Observer { value ->
            adapterProduct.setData(1, value)
        })

        viewModel.profibusAddressLiveData.observe(this, Observer { value ->
            adapterProduct.setData(2, value)
        })

        viewModel.gearLiveData.observe(this, Observer { value ->
            adapterProduct.setData(3, value)
        })

        viewModel.oemTypeLiveData.observe(this, Observer { value ->
            adapterProduct.setData(4, value)
        })

        viewModel.oemSerialLiveData.observe(this, Observer { value ->
            adapterProduct.setData(5, value)
        })

        viewModel.dealerTypeLiveData.observe(this, Observer { value ->
            adapterProduct.setData(6, value)
        })

        viewModel.dealerSerialLiveData.observe(this, Observer { value ->
            adapterProduct.setData(7, value)
        })

        viewModel.ai1BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgAI_1.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgAI_1.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.ai2BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgAI_2.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgAI_2.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.di1BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgDI_1.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgDI_1.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.di2BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgDI_2.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgDI_2.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.modbusBoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgModbus.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgModbus.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.hartBoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgHart.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgHart.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.ao1BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgAO_1.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgAO_1.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.ao2BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgAO_2.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgAO_2.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.do1BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgDO_1.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgDO_1.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.do2BoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgDO_2.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgDO_2.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })

        viewModel.profibusBoardLiveData.observe(this, Observer { value ->
            if (value) {
                imgProfibus.setImageResource(R.drawable.ic_detect_board_light)
            } else {
                imgProfibus.setImageResource(R.drawable.ic_detect_board_normal)
            }
        })
    }
}