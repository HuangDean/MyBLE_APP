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
import com.sunyeh.m100.data.db.UserConfig
import kotlinx.android.synthetic.main.adapter_spinner.view.*
import kotlinx.android.synthetic.main.adapter_submit.view.*
import kotlinx.android.synthetic.main.adapter_submit.view.tvTitle

class ProductAdapter(val context: Context) : RecyclerView.Adapter<BaseViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(index: Int, value: String)
    }

    interface OnItemSelectedListener {
        fun onItemSelected(index: Int, value: String)
    }

    private var clickListener: OnItemClickListener? = null
    private var selectedListener: OnItemSelectedListener? = null

    private val titles: Array<String> = context.resources.getStringArray(R.array.product_title)
    private val titles2: Array<String> = context.resources.getStringArray(R.array.product_title2)
    private var datas: Array<String> = arrayOf("", "", "", "", "", "", "", "")

    private var permission: String = "0"

    private val baudRates: Array<String> = arrayOf(
        "1200",
        "9600",
        "19200",
        "38400",
        "57600",
        "115200"
    )

    init {
        permission = UserConfig.getPermission(context)
    }

    override fun getItemCount(): Int {
        return if (permission != "1") {
            titles.size
        } else {
            titles2.size
        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (position) {
            1 -> R.layout.adapter_spinner
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
        if (permission == "1") {
            if (position == 3 || position == 4) {
                holder.bind(position, titles2[position], datas[position + 3])
            } else {
                holder.bind(position, titles2[position], datas[position])
            }
        } else {
            holder.bind(position, titles[position], datas[position])
        }
    }

    inner class SubmitViewHolder(itemView: View) : BaseViewHolder(itemView) {
        private var rlView: RelativeLayout = itemView.rlView
        private var tvTitle: TextView = itemView.tvTitle
        private var edtValue: EditText = itemView.edtValue
        private var btnSumbit: Button = itemView.btnSubmit

        override fun bind(index: Int, title: String, data: String) {
            val gdValveStatus = GradientDrawable()
            gdValveStatus.cornerRadius = 8F
            gdValveStatus.setColor(Color.WHITE)
            rlView.background = gdValveStatus

            tvTitle.text = title
            edtValue.setText(data)
            when (index) {
                0, 1, 2, 3 -> edtValue.inputType = InputType.TYPE_CLASS_NUMBER
                else -> edtValue.inputType = InputType.TYPE_CLASS_TEXT
            }

            btnSumbit.setOnClickListener {
                if (!edtValue.text.isNullOrBlank()) {
                    if (permission == "1" && (index == 3 || index == 4)) {
                        clickListener?.onItemClick(index + 3, edtValue.text.toString())
                    } else {
                        clickListener?.onItemClick(index, edtValue.text.toString())
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
            spValue.adapter = ArrayAdapter(context, R.layout.support_simple_spinner_dropdown_item, baudRates)

            if (data != "") {
                spValue.setSpinnerText(data)
            }

            spValue.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                }

                override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                    selectedListener?.onItemSelected(1, baudRates[position])
                }
            }
        }
    }

    fun setListener(clicklistener: OnItemClickListener, selectedlistener: OnItemSelectedListener) {
        this.clickListener = clicklistener
        this.selectedListener = selectedlistener
    }

    fun setData(index: Int, value: String) {
        if (permission == "1") {
            when (index) {
                0, 1, 2, 6, 7 -> datas[index] = value
            }
        } else {
            datas[index] = value
        }

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