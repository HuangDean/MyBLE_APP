package com.sunyeh.m100.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.sunyeh.m100.R
import kotlinx.android.synthetic.main.adapter_setting.view.*

class SettingAdapter(context: Context) : RecyclerView.Adapter<SettingAdapter.ViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(index: Int)
    }

    private val items: Array<String> by lazy {
        arrayOf(
            context.getString(R.string.setting_product_config),
            context.getString(R.string.setting_maintain_config),
            context.getString(R.string.setting_system_config),
            context.getString(R.string.setting_ungent_config),
            context.getString(R.string.setting_switch_config),
            context.getString(R.string.setting_control_mode_config),
            context.getString(R.string.setting_output_config)
        )
    }

    private var clickListener: OnItemClickListener? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.adapter_setting, parent, false)
        )
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.tvItem.text = items[position]

        holder.itemView.setOnClickListener {
            clickListener?.onItemClick(position)
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvItem: TextView = itemView.tvItem
    }

    fun setListener(listener: OnItemClickListener?) {
        this.clickListener = listener
    }

}