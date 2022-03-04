package com.sunyeh.m100.utils

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import com.sunyeh.m100.MyApplication.Companion.context

object CommonUtil {

    fun isNullOrEmpty(str: String?): Boolean {
        return str == null || str.trim { it <= ' ' }.isEmpty()
    }

    fun handlerPost(runnable: Runnable) {
        Handler(Looper.getMainLooper()).post(runnable)
    }

    fun handlerPostDelay(delayMillis: Int, runnable: () -> Unit) {
        Handler(Looper.getMainLooper()).postDelayed(runnable, delayMillis.toLong())
    }

    fun handlerPostDelay(delayMillis: Int, runnable: Runnable) {
        Handler(Looper.getMainLooper()).postDelayed(runnable, delayMillis.toLong())
    }

    fun createThread(runnable: Runnable) {
        Thread(runnable).start()
    }

    fun dp2px(context: Context, dp: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.resources.displayMetrics)
}