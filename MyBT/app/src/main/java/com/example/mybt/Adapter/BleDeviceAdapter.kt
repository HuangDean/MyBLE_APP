package com.example.mybt.Adapter

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.clj.fastble.data.BleDevice
import com.example.mybt.R
import kotlinx.android.synthetic.main.adapter_ble_device.view.*

class BleDeviceAdapter : RecyclerView.Adapter<BleDeviceAdapter.ViewHolder>() {

    interface OnItemClickListener {
        fun onItemClick(index: Int, deviceName: String)
    }

    private var devices: ArrayList<BleDevice> = ArrayList()
    private var clickListener: OnItemClickListener? = null

    override fun getItemCount(): Int = devices.size

    //創建ViewHolder
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.adapter_ble_device, parent, false)
        )
    }
    //綁定數據
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val device: BleDevice = devices[position]

        when (device.rssi) {
            in -30..0 -> holder.imgRssi.setImageResource(R.drawable.ic_signal_3)
            in -60..-31 -> holder.imgRssi.setImageResource(R.drawable.ic_signal_2)
            else -> holder.imgRssi.setImageResource(R.drawable.ic_signal_1)
        }
        Log.e("TEST", "name:${device.name} position${position}")
        holder.tvDeviceName.text = device.name

        holder.itemView.setOnClickListener {
            clickListener?.onItemClick(position, device.name)
        }
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var imgRssi: ImageView = itemView.imgRssi
        var tvDeviceName: TextView = itemView.tvDeviceName
    }

    fun setListener(listener: OnItemClickListener?) {
        this.clickListener = listener
    }

    fun setData(device: ArrayList<BleDevice>) {
        devices = device
        // 通知資料被變動，更新 ListView 顯示內容。
        notifyDataSetChanged()
    }
}