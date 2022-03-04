package com.sunyeh.m100.adapter

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.recyclerview.widget.RecyclerView
import com.sunyeh.m100.R
import kotlinx.android.synthetic.main.adapter_spinner.view.*
import kotlinx.android.synthetic.main.adapter_submit.view.*
import kotlinx.android.synthetic.main.adapter_submit.view.tvTitle

class UngentAdapter(val context: Context) : RecyclerView.Adapter<BaseViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(index: Int, value: String)
    }

    interface OnItemSelectedListener {
        fun onItemSelected(index: Int, value: String)
    }

    interface SwitchChangeListener {
        fun onSwitchChange(value: Boolean)
    }

    private var clickListener: OnItemClickListener? = null
    private var selectedListener: OnItemSelectedListener? = null
    private var switchChangeListener: SwitchChangeListener? = null

    private val titles: Array<String> = context.resources.getStringArray(R.array.ungent_title)
    private var datas: Array<String> = arrayOf("", "", "", "", "")

    private val singleActions: Array<String> = arrayOf(
        context.getString(R.string.ungent_config_open_signal_action1),
        context.getString(R.string.ungent_config_open_signal_action2),
        context.getString(R.string.ungent_config_open_signal_action3)
    )

    private val ungentActions: Array<String> = arrayOf(
        context.getString(R.string.ungent_config_ungent_action1),
        context.getString(R.string.ungent_config_ungent_action2),
        context.getString(R.string.ungent_config_ungent_action3),
        context.getString(R.string.ungent_config_ungent_action4)
    )

    override fun getItemCount(): Int = titles.size

    override fun getItemViewType(position: Int): Int {
        return when (position) {
            0, 1 -> R.layout.adapter_spinner
            else -> R.layout.adapter_submit
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder {
        return when (viewType) {
            R.layout.adapter_spinner -> SpinnerViewHolder(
                LayoutInflater
                    .from(parent.context)
                    .inflate(R.layout.adapter_spinner, parent, false)
            )
            else -> SubmitViewHolder(
                LayoutInflater
                    .from(parent.context)
                    .inflate(R.layout.adapter_submit, parent, false)
            )
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder, position: Int) {
        holder.bind(position, titles[position], datas[position])
    }

    inner class SubmitViewHolder(itemView: View) : BaseViewHolder(itemView) {
        private var rlView: RelativeLayout = itemView.rlView
        private var tvTitle: TextView = itemView.tvTitle
        private var switchBtn: Switch = itemView.switchBtn
        private var edtValue: EditText = itemView.edtValue
        private var tvUnit: TextView = itemView.tvUnit
        private var btnSumbit: Button = itemView.btnSubmit

        override fun bind(index: Int, title: String, data: String) {
            val gdValveStatus = GradientDrawable()
            gdValveStatus.cornerRadius = 8F
            gdValveStatus.setColor(Color.WHITE)
            rlView.background = gdValveStatus

            tvTitle.text = title

            edtValue.inputType = InputType.TYPE_CLASS_NUMBER

            if (index == 2) {
                tvUnit.text = "%"
                switchBtn.visibility = View.INVISIBLE
                edtValue.setText(data)
            } else {
                edtValue.setText(datas[4])
                
                if (data == "0") {
                    switchBtn.isChecked = false
                    switchBtn.text = context.getText(R.string.config_off)
                } else {
                    switchBtn.isChecked = true
                    switchBtn.text = context.getText(R.string.config_on)
                }
                switchBtn.visibility = View.VISIBLE

                switchBtn.setOnCheckedChangeListener { _, isChecked ->
                    switchChangeListener?.onSwitchChange(isChecked)
                }

                tvUnit.text = "°C"
            }

            tvUnit.visibility = View.VISIBLE

            btnSumbit.setOnClickListener {
                if (!edtValue.text.isNullOrBlank()) {
                    if (index == 2) {
                        clickListener?.onItemClick(index, edtValue.text.toString())
                    } else {
                        clickListener?.onItemClick(index + 1, edtValue.text.toString())
                    }
                }
            }
        }
    }

    inner class SpinnerViewHolder(itemView: View) : BaseViewHolder(itemView) {
        private var tvTitle: TextView = itemView.tvTitle
        private var spValue: Spinner = itemView.spValue

        override fun bind(index: Int, title: String, data: String) {
            tvTitle.text = title

            when (index) {
                0 -> spValue.adapter = ArrayAdapter(context, R.layout.support_simple_spinner_dropdown_item, singleActions)
                1 -> spValue.adapter = ArrayAdapter(context, R.layout.support_simple_spinner_dropdown_item, ungentActions)
            }

            if (data != "") {
                spValue.setSpinnerText(data)
            }

            spValue.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                }

                override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                    selectedListener?.onItemSelected(index, position.toString())
                }
            }
        }
    }

    fun setListener(
        clicklistener: OnItemClickListener,
        selectedlistener: OnItemSelectedListener,
        switchChangeListener: SwitchChangeListener
    ) {
        this.clickListener = clicklistener
        this.selectedListener = selectedlistener
        this.switchChangeListener = switchChangeListener
    }

    fun setData(index: Int, value: String) {
        datas[index] = value
        notifyDataSetChanged()
    }

    fun Spinner.setSpinnerText(text: String) {
        for (i in 0 until this.adapter.count) {
            if (this.adapter.getItem(i).toString().contains(text)) {
                this.setSelection(i)
            }
        }
    }
}