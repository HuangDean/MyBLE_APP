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
import kotlinx.android.synthetic.main.adapter_submit.view.*
import kotlinx.android.synthetic.main.adapter_submit.view.tvTitle

class MaintainAdapter(val context: Context) : RecyclerView.Adapter<BaseViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(index: Int, value: String)
    }

    private var clickListener: OnItemClickListener? = null

    private val titles: Array<String> = context.resources.getStringArray(R.array.maintain_title)
    private var datas: Array<String> = arrayOf("", "", "")

    override fun getItemCount(): Int = titles.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder {
        return SubmitViewHolder(
            LayoutInflater
                .from(parent.context)
                .inflate(R.layout.adapter_submit, parent, false)
        )
    }

    override fun onBindViewHolder(holder: BaseViewHolder, position: Int) {
        holder.bind(position, titles[position], datas[position])
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
                    clickListener?.onItemClick(index, edtValue.text.toString())
                }
            }
        }
    }

    fun setListener(clicklistener: OnItemClickListener) {
        this.clickListener = clicklistener
    }

    fun setData(index: Int, value: String) {
        datas[index] = value
        notifyDataSetChanged()
    }
}