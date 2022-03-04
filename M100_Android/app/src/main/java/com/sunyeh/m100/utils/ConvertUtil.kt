package com.sunyeh.m100.utils

import java.nio.ByteBuffer
import java.nio.ByteOrder

object ConvertUtil {

    fun utf2byte(value: String): ByteArray = value.toByteArray(Charsets.UTF_8)

    fun uShort2Bytes(value: Int, isLittleEnian: Boolean): ByteArray {
        val bytes = ByteArray(2)

        if (isLittleEnian) {
            bytes[0] = (value and 0xFF).toByte()
            bytes[1] = ((value ushr 8) and 0xFF).toByte()
        } else {
            bytes[0] = ((value ushr 8) and 0xFF).toByte()
            bytes[1] = ((value) and 0xFF).toByte()
        }
        return bytes
    }

    fun int2Bytes(value: Int, isLittleEnian: Boolean): ByteArray {
        val bufferSize: Int = Int.SIZE_BYTES
        val buffer: ByteBuffer = ByteBuffer.allocate(bufferSize)

        if (isLittleEnian) {
            buffer.order(ByteOrder.LITTLE_ENDIAN)
        } else {
            buffer.order(ByteOrder.BIG_ENDIAN)
        }

        return buffer.putInt(value).array()
    }

    fun long2Bytes(value: Long, isLittleEnian: Boolean): ByteArray {
        val bufferSize: Int = Long.SIZE_BYTES
        val buffer: ByteBuffer = ByteBuffer.allocate(bufferSize)

        if (isLittleEnian) {
            buffer.order(ByteOrder.LITTLE_ENDIAN)
        } else {
            buffer.order(ByteOrder.BIG_ENDIAN)
        }

        return buffer.putLong(value).array()
    }

    /**
     * 帶符號
     */

    fun convertInt16(byteArray: ByteArray): Int {
        val bytes: ByteArray = orderBytes(byteArray)
        return (bytes[1].toInt() shl 8) or (bytes[0].toInt() and 0xFF)
    }

    fun convertInt32(byteArray: ByteArray): Int {
        val bytes: ByteArray = orderBytes(byteArray)
        return ((bytes[3].toInt() shl 24) or (bytes[2].toInt() and 0xFF)) or
                (bytes[1].toInt() shl 8) or (bytes[0].toInt() and 0xFF)
    }

    /**
     * 不帶符號
     */

    fun convertUInt8(byte: Byte): Int {
        return byte.toInt() and 0xFF
    }

    fun convertUInt16(byteArray: ByteArray): Int {
        val bytes: ByteArray = orderBytes(byteArray)
        return ((bytes[1].toInt() and 0xFF) shl 8) or ((bytes[0].toInt() and 0xFF))
    }


    fun convertUInt32(byteArray: ByteArray): Int {
        val bytes: ByteArray = orderBytes(byteArray)
        return ((bytes[3].toInt() and 0xFF) shl 24) or
                ((bytes[2].toInt() and 0xFF) shl 16) or
                ((bytes[1].toInt() and 0xFF) shl 8) or
                (bytes[0].toInt() and 0xFF)
    }

    fun convertFloat(byteArray: ByteArray): Float = ByteBuffer.wrap(orderBytes(byteArray)).order(ByteOrder.LITTLE_ENDIAN).float

    // UTF8

    fun convertUtf8(byteArray: ByteArray) = orderBytes(byteArray).toString(Charsets.UTF_8)

    private fun orderBytes(bytes: ByteArray): ByteArray {
        val newBytes: ByteArray = bytes.copyOf()

        for (i in bytes.indices step 2) {
            newBytes[i] = bytes[i + 1]
            newBytes[i + 1] = bytes[i]
        }

        return newBytes
    }

    private fun Short.reverseBytes(): Short {
        val v0 = ((this.toInt() ushr 0) and 0xFF)
        val v1 = ((this.toInt() ushr 8) and 0xFF)
        return ((v1 and 0xFF) or (v0 shl 8)).toShort()
    }

    private fun Int.reverseBytes(): Int {
        val v0 = ((this ushr 0) and 0xFF)
        val v1 = ((this ushr 8) and 0xFF)
        val v2 = ((this ushr 16) and 0xFF)
        val v3 = ((this ushr 24) and 0xFF)
        return (v0 shl 24) or (v1 shl 16) or (v2 shl 8) or (v3 shl 0)
    }

    private fun Long.reverseBytes(): Long {
        val v0 = (this ushr 0).toInt().reverseBytes().toLong() and 0xFFFFFFFFL
        val v1 = (this ushr 32).toInt().reverseBytes().toLong() and 0xFFFFFFFFL
        return (v0 shl 32) or (v1 shl 0)
    }
}