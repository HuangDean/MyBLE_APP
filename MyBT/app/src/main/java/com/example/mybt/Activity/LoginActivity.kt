package com.example.mybt.Activity

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.text.Editable
import android.util.Log
import com.example.mybt.R
import kotlinx.android.synthetic.main.activity_login.*

class LoginActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        Log.e("TEST", "onCreate")
        setupViews()
        setOnClickListeners()
    }

    override fun setupViews() {
        tvDeviceName.text = intent.extras?.getString("deviceName")

        // cancel樣式
        val gdInactiveCancel = GradientDrawable()
        gdInactiveCancel.cornerRadius = 10F * rate
        gdInactiveCancel.setColor(Color.WHITE)

        val gdActiveCancel = GradientDrawable()
        gdActiveCancel.cornerRadius = 10F * rate
        gdActiveCancel.setColor(Color.GRAY)

        val sldCancel = StateListDrawable()
        sldCancel.addState(intArrayOf(-android.R.attr.state_pressed), gdInactiveCancel)
        sldCancel.addState(intArrayOf(android.R.attr.state_pressed), gdActiveCancel)
        btnCancel.background = sldCancel

        // login樣式
        val gdInactiveSubmit = GradientDrawable()
        gdInactiveSubmit.cornerRadius = 10F * rate
        gdInactiveSubmit.setColor(Color.rgb(255, 44, 85))

        val gdActiveSubmit = GradientDrawable()
        gdActiveSubmit.cornerRadius = 10F * rate
        gdActiveSubmit.setColor(Color.LTGRAY)

        val sldSubmit = StateListDrawable()
        sldSubmit.addState(intArrayOf(-android.R.attr.state_pressed), gdInactiveSubmit)
        sldSubmit.addState(intArrayOf(android.R.attr.state_pressed), gdActiveSubmit)
        btnSubmit.background = sldSubmit
    }

    override fun setOnClickListeners() {
        btnCancel.setOnClickListener {
            finish()
        }

        btnSubmit.setOnClickListener {
            val password: Editable? = edtPassword.text

            if (password.isNullOrBlank()) {
                toastMsg(getString(R.string.login_password_empty))
                return@setOnClickListener
            }

            val bundle = Bundle()
            bundle.putInt("index", intent.extras!!.getInt("index"))
            bundle.putString("password", password.toString())
            bundle.putInt("permission", spUserPermission.selectedItemPosition)
            val intent = Intent()
            intent.putExtras(bundle)

            setResult(Activity.RESULT_OK, intent)
            finish()
        }
    }

    override fun setObserve() {
    }

}