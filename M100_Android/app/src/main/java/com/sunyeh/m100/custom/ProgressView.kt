package com.sunyeh.m100.custom

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import com.sunyeh.m100.R

open class ProgressView : View {

    private var minValue: Int = 2
    private var maxValue: Int = 98
    private var radius: Float = 0.0F

    private var backgroundPaint: Paint = Paint()
    private var contentPaint: Paint = Paint()

    private lateinit var backgroundRect: RectF
    private lateinit var contentRect: RectF

    constructor(context: Context) : this(context, null)

    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(
                it,
                R.styleable.ProgressView, 0, 0
            )

            radius = dp2px(typedArray.getFloat(R.styleable.ProgressView_radius, 0.0F))
            typedArray.recycle()
            initPaint()
        }
    }

    private fun initPaint() {

        backgroundPaint.isAntiAlias = true
        backgroundPaint.style = Paint.Style.FILL_AND_STROKE
        backgroundPaint.color = Color.parseColor("#3F5D87")

        contentPaint.isAntiAlias = true
        contentPaint.style = Paint.Style.FILL_AND_STROKE
        contentPaint.color = Color.parseColor("#D8D8D8")

        backgroundRect = RectF()
        contentRect = RectF()
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        canvas?.save()

        val rate: Float = width.toFloat() / 100

        backgroundRect.left = 0f
        backgroundRect.top = 0f
        backgroundRect.right = width.toFloat()
        backgroundRect.bottom = height.toFloat()
        canvas?.drawRoundRect(backgroundRect, radius, radius, backgroundPaint)

        contentRect.left = minValue * rate
        contentRect.top = dp2px(2f )
        contentRect.right = width.toFloat() - (100 - maxValue)  * rate
        contentRect.bottom = height - dp2px(2f )
        canvas?.drawRect(contentRect, contentPaint)

        canvas?.restore()
    }

    private fun dp2px(dp: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.resources.displayMetrics)


    fun setMin(value: Int) {
        minValue = value
        postInvalidate()
    }

    fun setMax(value: Int) {
        maxValue = value
        postInvalidate()
    }
}