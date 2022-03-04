package com.sunyeh.m100.data

import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.exception.BleException
import com.sunyeh.m100.MyApplication
import com.sunyeh.m100.utils.ConvertUtil

class OutputConfigRepository {

    // read
    private val getDigitOutputChannelCmd: ByteArray = byteArrayOf(0x10, 0xAD.toByte(), 0x00, 0x09) // 4269~4277

    // write
    private val saveCmd: ByteArray = byteArrayOf(0x10, 0xCB.toByte(), 0x00, 0x01, 0x02, 0x03, 0x09)
    private val setOutputChannelCmd: ByteArray = byteArrayOf(0x10, 0xAD.toByte(), 0x00, 0x01, 0x02)
    private val setChannel1Output1Cmd: ByteArray = byteArrayOf(0x10, 0xAE.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel1Output2Cmd: ByteArray = byteArrayOf(0x10, 0xAF.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel1Output3Cmd: ByteArray = byteArrayOf(0x10, 0xB0.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel1Output4Cmd: ByteArray = byteArrayOf(0x10, 0xB1.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel2Output1Cmd: ByteArray = byteArrayOf(0x10, 0xB2.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel2Output2Cmd: ByteArray = byteArrayOf(0x10, 0xB3.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel2Output3Cmd: ByteArray = byteArrayOf(0x10, 0xB4.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)
    private val setChannel2Output4Cmd: ByteArray = byteArrayOf(0x10, 0xB5.toByte(), 0x00, 0x01, 0x02, 0x00, 0x00)

    private val callback: BleWriteCallback = object : BleWriteCallback() {
        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {

        }

        override fun onWriteFailure(exception: BleException?) {

        }
    }

    var isChannel1: Boolean = true

    var isCanWrite: Boolean = false

    fun getDigitOutputChannel() {
        MyApplication.writeData(getDigitOutputChannelCmd, callback, false)
    }

    fun saveCmd() {
        MyApplication.writeData(saveCmd, callback, true)
    }

    fun saveData(index: Int, value: Int) {
        if (isChannel1) {
            when (index) {
                0 -> {
                    if (value == 1) {
                        setChannel1Output1Cmd[5] = 0x00
                    } else {
                        setChannel1Output1Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel1Output1Cmd)
                }
                1 -> {
                    setChannel1Output1Cmd[6] = value.toByte()
                    setData(setChannel1Output1Cmd)
                }
                2 -> {
                    if (value == 1) {
                        setChannel1Output2Cmd[5] = 0x00
                    } else {
                        setChannel1Output2Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel1Output2Cmd)
                }
                3 -> {
                    setChannel1Output2Cmd[6] = value.toByte()
                    setData(setChannel1Output2Cmd)
                }
                4 -> {
                    if (value == 1) {
                        setChannel1Output3Cmd[5] = 0x00
                    } else {
                        setChannel1Output3Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel1Output3Cmd)
                }
                5 -> {
                    setChannel1Output3Cmd[6] = value.toByte()
                    setData(setChannel1Output3Cmd)
                }
                6 -> {
                    if (value == 1) {
                        setChannel1Output4Cmd[5] = 0x00
                    } else {
                        setChannel1Output4Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel1Output4Cmd)
                }
                7 -> {
                    setChannel1Output4Cmd[6] = value.toByte()
                    setData(setChannel1Output4Cmd)
                }
                8 -> formatIntData(setOutputChannelCmd, value)
            }
        } else {
            when (index) {
                0 -> {
                    if (value == 1) {
                        setChannel2Output1Cmd[5] = 0x00
                    } else {
                        setChannel2Output1Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel2Output1Cmd)
                }
                1 -> {
                    setChannel2Output1Cmd[6] = value.toByte()
                    setData(setChannel2Output1Cmd)
                }
                2 -> {
                    if (value == 1) {
                        setChannel2Output2Cmd[5] = 0x00
                    } else {
                        setChannel2Output2Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel2Output2Cmd)
                }
                3 -> {
                    setChannel2Output2Cmd[6] = value.toByte()
                    setData(setChannel2Output2Cmd)
                }
                4 -> {
                    if (value == 1) {
                        setChannel2Output3Cmd[5] = 0x00
                    } else {
                        setChannel2Output3Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel2Output3Cmd)
                }
                5 -> {
                    setChannel2Output3Cmd[6] = value.toByte()
                    setData(setChannel2Output3Cmd)
                }
                6 -> {
                    if (value == 1) {
                        setChannel2Output4Cmd[5] = 0x00
                    } else {
                        setChannel2Output4Cmd[5] = 0x80.toByte()
                    }

                    setData(setChannel2Output4Cmd)
                }
                7 -> {
                    setChannel2Output4Cmd[6] = value.toByte()
                    setData(setChannel2Output4Cmd)
                }
                8 -> formatIntData(setOutputChannelCmd, value)
            }
        }
    }

    private fun formatIntData(cmd: ByteArray, data: Int) {
        val dataCmd: ArrayList<Byte> = cmd.copyOf().toList() as ArrayList<Byte>

        val dataBytes: ByteArray = ConvertUtil.int2Bytes(data, true)

        for (i in dataBytes.indices step 2) {
            dataCmd.add(dataBytes[i + 1])
            dataCmd.add(dataBytes[i])
        }

        setData(dataCmd.toByteArray())
    }

    private fun setData(cmd: ByteArray) {
        MyApplication.writeData(cmd, callback, true)
    }
}