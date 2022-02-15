package com.example.mybt.Activity

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import java.util.*


@SuppressLint("Registered")
abstract class BaseActivity : AppCompatActivity() {

    open var rate: Float = 0.0F
    open var screenWidth: Float = 0.0F
    open var screenHeight: Float = 0.0F

    open val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            var flags = window.decorView.systemUiVisibility
//            if (flags != 8192) { //8192為SYSTEM_UI_FLAG_LIGHT_STATUS_BAR的值
//                flags = flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR //淺色背景搭配灰色文字、圖示
//                window.statusBarColor = getColor(R.color.black)
//            }
//            window.decorView.systemUiVisibility = flags
//        }
//
//        val baseRate: Float = 640F / 360F
//        screenWidth = resources.displayMetrics.widthPixels.toFloat()
//        screenHeight = resources.displayMetrics.heightPixels.toFloat()
//        rate = screenHeight / screenWidth / baseRate

    }

    override fun onDestroy() {
        coroutineScope.cancel()
        super.onDestroy()
    }

    abstract fun setupViews()

    abstract fun setOnClickListeners()

    abstract fun setObserve()

    fun setStatusBarColor(color: Int) {
        window.statusBarColor = getResColor(color)
    }

    fun getResColor(name: Int): Int = ContextCompat.getColor(this, name)

    fun startActivity(targetClass: Class<*>) {
        val intent = Intent(this, targetClass)
        startActivity(intent)
    }

    fun startActivity(bundle: Bundle, targetClass: Class<*>) {
        val intent = Intent(this, targetClass)
        intent.putExtras(bundle)
        startActivity(intent)
    }

    fun startActivityResult(bundle: Bundle?, targetClass: Class<*>) {
        val intent = Intent(this, targetClass)
        bundle?.let {
            intent.putExtras(it)
        }
        startActivityForResult(intent, 200)
    }

    fun toastMsg(msg: String) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()

    fun toastMsg(msg: Int) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()

    fun hideKeyBoard() {
        try {
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(Objects.requireNonNull(currentFocus)?.windowToken, 0)
        } catch (e: NullPointerException) {
            Log.e("hideKeyBoard", e.toString())
        }

    }

}
