package com.sunyeh.m100.adapter

import android.view.View
import androidx.recyclerview.widget.RecyclerView

abstract class BaseViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    abstract fun bind(index: Int, title: String, data: String)
}

abstract class BaseViewHolder2(itemView: View) : RecyclerView.ViewHolder(itemView) {
    abstract fun bind(index: Int, status: Int, data: Int)
}