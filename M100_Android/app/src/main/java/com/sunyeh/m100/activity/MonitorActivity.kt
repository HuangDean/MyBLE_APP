package com.sunyeh.m100.activity

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.Button
import androidx.core.content.FileProvider
import androidx.lifecycle.Observer
import com.clj.fastble.BleManager
import com.github.mikephil.charting.components.AxisBase
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.components.XAxis
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.data.LineDataSet
import com.github.mikephil.charting.formatter.ValueFormatter
import com.opencsv.CSVWriter
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.R
import com.sunyeh.m100.SettingStatus
import com.sunyeh.m100.data.MonitorRepository
import com.sunyeh.m100.viewmodel.MonitorViewModel
import com.xw.repo.BubbleSeekBar
import kotlinx.android.synthetic.main.activity_monitor.*
import kotlinx.android.synthetic.main.activity_status.toolbar
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.io.File
import java.io.FileWriter

class MonitorActivity : BaseActivity() {

    private lateinit var lineDataSet: LineDataSet
    private lateinit var lineData: LineData
    private var entrys = ArrayList<Entry>()  // 數據
    private var dataCount: Int = 1

    private var lastTappedButon: Button? = null

    private val viewModel: MonitorViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_monitor)

        setupViews()
        setOnClickListeners()
        setObserve()
    }

    override fun setupViews() {
        setStatusBarColor(R.color.colorTheme)

        toolbar.setNavigationIcon(R.drawable.ic_back)
        toolbar.title = getString(R.string.monitor_title)

        imgRecord.tag = 0

        lineChart.isScaleXEnabled = false
        lineChart.description.isEnabled = false
        lineChart.legend.form = Legend.LegendForm.NONE
        lineChart.axisRight.isEnabled = false
        lineChart.description.isEnabled = false
        lineChart.axisLeft.axisMinimum = 0F
        lineChart.axisLeft.axisMaximum = 210F
        lineChart.xAxis.position = XAxis.XAxisPosition.BOTTOM
        lineChart.xAxis.textSize = 12F
        lineChart.xAxis.textColor = Color.BLACK
        lineChart.xAxis.valueFormatter = DateFormat()
        lineChart.xAxis.granularity = 1.0F
        lineChart.xAxis.setLabelCount(6, true)
        lineChart.setScaleEnabled(true)
        lineChart.setDrawGridBackground(false)
        lineChart.setTouchEnabled(false)

        lineChart.xAxis.valueFormatter = DateFormat()

        // line style
        lineDataSet = LineDataSet(entrys, "")
        lineDataSet.color = Color.BLACK
        lineDataSet.circleColors = listOf(Color.BLACK)
        lineDataSet.circleRadius = 4F
        lineDataSet.circleHoleRadius = 4F
        lineDataSet.valueTextSize = 12F

        lineData = LineData(lineDataSet)
        lineChart.data = lineData
    }

    override fun setOnClickListeners() {
        toolbar.setNavigationOnClickListener {
            finish()
        }

        sbTimeline.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(
                bubbleSeekBar: BubbleSeekBar?,
                progress: Int,
                progressFloat: Float,
                fromUser: Boolean
            ) {
                updateXAxisMaximum(progress)
            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
//                viewModel.saveData(2, (progressFloat * 10).toInt())
            }

            override fun getProgressOnFinally(
                bubbleSeekBar: BubbleSeekBar?,
                progress: Int,
                progressFloat: Float,
                fromUser: Boolean
            ) {
            }
        }

        sbGetDataTimer.onProgressChangedListener = object : BubbleSeekBar.OnProgressChangedListener {
            override fun onProgressChanged(
                bubbleSeekBar: BubbleSeekBar?,
                progress: Int,
                progressFloat: Float,
                fromUser: Boolean
            ) {
            }

            override fun getProgressOnActionUp(bubbleSeekBar: BubbleSeekBar?, progress: Int, progressFloat: Float) {
                viewModel.setDelayTimeSeconds(progress)
            }

            override fun getProgressOnFinally(
                bubbleSeekBar: BubbleSeekBar?,
                progress: Int,
                progressFloat: Float,
                fromUser: Boolean
            ) {
            }
        }

        btnValvePosition.setOnClickListener {
            lastTappedButon?.isSelected = false
            btnValvePosition.isSelected = true
            lastTappedButon = btnValvePosition

            viewModel.setFeature(0)
            updateYAxisMaximum(200)
        }

        btnRpm.setOnClickListener {
            lastTappedButon?.isSelected = false
            btnRpm.isSelected = true
            lastTappedButon = btnRpm

            viewModel.setFeature(1)
            updateYAxisMaximum(2000)
        }

        btnTorque.setOnClickListener {
            lastTappedButon?.isSelected = false
            btnTorque.isSelected = true
            lastTappedButon = btnTorque

            viewModel.setFeature(2)
            updateYAxisMaximum(200)
        }

        btnMortorTempeature.setOnClickListener {
            lastTappedButon?.isSelected = false
            btnMortorTempeature.isSelected = true
            lastTappedButon = btnMortorTempeature

            viewModel.setFeature(3)
            updateYAxisMaximum(200)
        }

        btnModuleTempeature.setOnClickListener {
            lastTappedButon?.isSelected = false
            btnModuleTempeature.isSelected = true
            lastTappedButon = btnModuleTempeature

            viewModel.setFeature(4)
            updateYAxisMaximum(200)
        }

        imgRecord.setOnClickListener {
            if (BleManager.getInstance().isConnected(MyApplication.bleDevice)) {

                imgRecord.tag = if (imgRecord.tag == 0) 1 else 0

                if (imgRecord.tag == 0) {
                    // 移除上次紀錄
                    deleteCsvFile("M100")

                    imgRecord.setImageResource(R.drawable.ic_record)
                    val csvData = viewModel.saveCVS()
                    saveData("M100", csvData)
                } else {
                    this.entrys.clear()
                    lineDataSet.notifyDataSetChanged()
                    lineData.notifyDataChanged()
                    lineChart.notifyDataSetChanged()
                    lineChart.invalidate()

                    imgRecord.setImageResource(R.drawable.ic_save)
                    viewModel.getData(true)
                }
            }
        }
    }

    override fun setObserve() {
        viewModel.monitorStatus.observe(this, Observer { status ->
            when (status) {
                SettingStatus.Timeout -> {
                    setResult(100)
                    finish()
                }

                SettingStatus.Disconnect -> {
                    setResult(100)
                    finish()
                }

                else -> {
                }
            }
        })

        viewModel.valveCurrentLiveData.observe(this, Observer { entrys ->
            upadteLineChart(entrys)
        })

        viewModel.rpmLiveData.observe(this, Observer { entrys ->
            upadteLineChart(entrys)
        })

        viewModel.motorTorqueLiveData.observe(this, Observer { entrys ->
            upadteLineChart(entrys)
        })

        viewModel.moduleTemperatureLiveData.observe(this, Observer { entrys ->
            upadteLineChart(entrys)
        })

        viewModel.motorTemperatureLiveData.observe(this, Observer { entrys ->
            upadteLineChart(entrys)
        })
    }

    private fun upadteLineChart(entrys: ArrayList<Entry>) {
        this.entrys.clear()
        this.entrys.addAll(entrys)
        lineDataSet.notifyDataSetChanged()
        lineData.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        lineChart.invalidate()
    }

    private fun updateXAxisMaximum(count: Int) {
        lineChart.xAxis.setLabelCount(count + 1, true)
        lineChart.notifyDataSetChanged()
        lineChart.invalidate()
    }

    private fun updateYAxisMaximum(count: Int) {
        lineChart.axisLeft.axisMaximum = count.toFloat()
        lineChart.notifyDataSetChanged()
        lineChart.invalidate()
    }

    open class DateFormat : ValueFormatter() {
        override fun getAxisLabel(value: Float, axis: AxisBase?): String {
            val timeLine: String = value.toInt().toString()
            return "${timeLine.substring(0, 2)}:${timeLine.subSequence(2, 4)}:${timeLine.subSequence(4, 6)}"
        }
    }

    private fun saveData(fileName: String, datas: ArrayList<MonitorRepository.MonitorData>) {
        val baseDir: String = filesDir.absolutePath
        val filePath: String = baseDir + File.separator + fileName + ".csv"
        val file = File(filePath)

        val csvWriter: CSVWriter
        val fileWriter: FileWriter

        try {
            if (file.exists() && !file.isDirectory) {
                fileWriter = FileWriter(filePath, true)
                csvWriter = CSVWriter(fileWriter)
            } else {
                csvWriter = CSVWriter(FileWriter(filePath))
            }

            val titles = arrayOf("時間", "位置(%)", "扭力(Nm)", "模組溫度(℃)", "馬達溫度(℃)", "馬達轉速(rpm)")
            csvWriter.writeNext(titles)

            for (data in datas) {
                val csvDatas: Array<String?> = arrayOfNulls(6)
                csvDatas[0] = data.time
                csvDatas[1] = data.position.toString()
                csvDatas[2] = data.torque.toString()
                csvDatas[3] = data.moduleTemp.toString()
                csvDatas[4] = data.motorTemp.toString()
                csvDatas[5] = data.rpm.toString()
                csvWriter.writeNext(csvDatas)
            }

            csvWriter.close()

            exportCSV(fileName)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun exportCSV(fileName: String) {
        val baseDir: String = filesDir.absolutePath
        val filePath: String = baseDir + File.separator + fileName + ".csv"
        val file = File(filePath)

        val uri: Uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
        val intent = Intent(Intent.ACTION_SEND)
        intent.type = "text/csv"
        intent.putExtra(Intent.EXTRA_SUBJECT, "M100")
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.putExtra(Intent.EXTRA_STREAM, uri)
        startActivity(Intent.createChooser(intent, "Send mail"))

        viewModel.clearData()
    }

    private fun deleteCsvFile(fileName: String) {
        val baseDir: String = filesDir.absolutePath
        val filePath: String = baseDir + File.separator + fileName + ".csv"
        val file = File(filePath)

        if (file.exists()) {
            file.delete()
        }
    }
}