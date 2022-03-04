package com.sunyeh.m100.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.sunyeh.m100.R
import kotlinx.android.synthetic.main.adapter_status.view.*

class StatusAdapter(val context: Context, val isSystemStatus: Boolean) : RecyclerView.Adapter<StatusAdapter.ViewHolder>() {

    private val statusCodes: Array<String> = context.resources.getStringArray(R.array.status_array)
    private val errorCodes: Array<String> = context.resources.getStringArray(R.array.error_array)

    private var codes: ArrayList<Int>? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.adapter_status, parent, false)
        )
    }

    override fun getItemCount(): Int {
        codes?.let {
            if (isSystemStatus && it.size > 21) {
                return statusCodes.size
            } else if (!isSystemStatus && it.size > 30) {
                return errorCodes.size
            }

            return it.size
        }

        return 0
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        codes?.let { it ->
            holder.tvCode.text = "${it[position] + 1}"

            if (isSystemStatus) {
                holder.tvContent.text = statusCodes[it[position]]
            } else {
                holder.tvContent.text = errorCodes[it[position]]
            }
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvCode: TextView = itemView.tvCode
        var tvContent: TextView = itemView.tvContent
    }

    fun updateContent(status: ArrayList<Int>) {
        codes = status
        notifyDataSetChanged()
    }
}