package com.sunyeh.m100.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.recyclerview.widget.RecyclerView
import com.sunyeh.m100.R
import kotlinx.android.synthetic.main.adapter_output.view.*
import kotlinx.android.synthetic.main.adapter_output.view.spValue

class OutputAdapter(val context: Context) : RecyclerView.Adapter<BaseViewHolder2>() {

    interface OnItemSelected {
        fun onItemSelected(index: Int, value: Int)
    }

    interface OnCheckChange {
        fun onCheckChange(index: Int, value: Int)
    }

    private var onItemSelected: OnItemSelected? = null
    private var onCheckChange: OnCheckChange? = null

    private var status: Array<Int> = arrayOf(0, 0, 0, 0)
    private var datas: Array<Int> = arrayOf(0, 0, 0, 0)

    override fun getItemCount(): Int = 4

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder2 {
        return SpinnerViewHolder(
            LayoutInflater
                .from(parent.context)
                .inflate(R.layout.adapter_output, parent, false)
        )
    }

    override fun onBindViewHolder(holder: BaseViewHolder2, position: Int) {
        holder.bind(position, status[position], datas[position])
    }

    inner class SpinnerViewHolder(itemView: View) : BaseViewHolder2(itemView) {
        private var imgNumber: ImageView = itemView.imgNumber
        private var cbStatus: CheckBox = itemView.cbStatus
        private var spValue: Spinner = itemView.spValue

        override fun bind(index: Int, status: Int, data: Int) {
            cbStatus.isChecked = status == 0

            when (index) {
                0 -> imgNumber.setImageResource(R.drawable.ic_output_1)
                1 -> imgNumber.setImageResource(R.drawable.ic_output_2)
                2 -> imgNumber.setImageResource(R.drawable.ic_output_3)
                3 -> imgNumber.setImageResource(R.drawable.ic_output_4)
            }

            if (!cbStatus.isChecked) {
                cbStatus.text = context.getString(R.string.config_nc)
            } else {
                cbStatus.text = context.getString(R.string.config_no)
            }

            spValue.tag = index
            spValue.setSelection(data)

            cbStatus.setOnCheckedChangeListener { buttonView, isChecked ->
                if (!isChecked) {
                    buttonView.text = context.getString(R.string.config_no)
                } else {
                    buttonView.text = context.getString(R.string.config_nc)
                }

                onCheckChange?.onCheckChange(index * 2, if (isChecked) 1 else 0)
            }

            spValue.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                }

                override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                    onItemSelected?.onItemSelected(index * 2 + 1, position)
                }
            }
        }
    }

    fun setListener(onItemSelected: OnItemSelected, onCheckChange: OnCheckChange) {
        this.onItemSelected = onItemSelected
        this.onCheckChange = onCheckChange
    }

    fun setStatus(index: Int, value: Int) {
        status[index] = value
        notifyDataSetChanged()
    }

    fun setData(index: Int, value: Int) {
        datas[index] = value
        notifyDataSetChanged()
    }
}