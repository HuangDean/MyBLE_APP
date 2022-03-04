package com.sunyeh.m100.custom

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import com.sunyeh.m100.R
import kotlin.math.PI
import kotlin.math.sin

open class DashboardView : View {

    private var minValue: Int = 0
    private var maxValue: Int = 100
    private var strokeWidth: Float = 0.0F
    private var valveTarget: Float = 0.0F
    private var valveCurrent: Float = 0.0F
    private var mortorTorque: Float = 0.0F
    private var value1: Float = 0.00F
    private var value2: Int = 0

    private var semicirclePaint: Paint = Paint()    // 半圓
    private var valveTargetPaint: Paint = Paint()   // 目標閥門位置 進度view
    private var valveCurrentPaint: Paint = Paint()  // 目前閥門位置 進度view
    private var motorTorquePaint: Paint = Paint()   // 馬達扭力位置 進度view
    private var gearArcPaint: Paint = Paint()       // 刻度弧線
    private var circlePaint: Paint = Paint()        // 中心圓
    private var circleStrokePaint: Paint = Paint()  // 中心圓框
    private var dividerPaint: Paint = Paint()       // 中心圓分隔線
    private var gearValuePaint: Paint = Paint()     // 刻度文字
    private var valuePaint: Paint = Paint()         // label1, label2
    private var unitPaint: Paint = Paint()          // 單位

    private lateinit var semicircleRect: RectF
    private lateinit var centerCircleRect: RectF
    private lateinit var indexEndpointRect: RectF
    private lateinit var valveTargetRect: RectF
    private lateinit var valveCurrentRect: RectF
    private lateinit var motorTorqueRect: RectF
    private lateinit var valueRect: RectF
    private lateinit var valuePath: Path

    constructor(context: Context) : this(context, null)

    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        attrs?.let {
            val typedArray = context.obtainStyledAttributes(
                it,
                R.styleable.DashboardView, 0, 0
            )

            strokeWidth = typedArray.getDimension(R.styleable.DashboardView_stroke_width, 0.0F)
            typedArray.recycle()
            initPaint()
        }
    }

    private fun initPaint() {

        semicirclePaint.isAntiAlias = true
        semicirclePaint.style = Paint.Style.STROKE
        semicirclePaint.color = Color.parseColor("#ADA9AC")
        semicirclePaint.strokeWidth = strokeWidth

        valveTargetPaint.isAntiAlias = true
        valveTargetPaint.style = Paint.Style.FILL
        valveTargetPaint.color = Color.parseColor("#FF9F0A")
        valveTargetPaint.strokeWidth = strokeWidth

        valveCurrentPaint.isAntiAlias = true
        valveCurrentPaint.style = Paint.Style.FILL
        valveCurrentPaint.color = Color.parseColor("#FFD60A")
        valveCurrentPaint.strokeWidth = strokeWidth

        motorTorquePaint.isAntiAlias = true
        motorTorquePaint.style = Paint.Style.FILL
        motorTorquePaint.color = Color.parseColor("#0A84FF")
        motorTorquePaint.strokeWidth = strokeWidth

        gearArcPaint.isAntiAlias = true
        gearArcPaint.style = Paint.Style.STROKE
        gearArcPaint.color = Color.BLACK
        gearArcPaint.strokeWidth = strokeWidth * 2

        circlePaint.isAntiAlias = true
        circlePaint.style = Paint.Style.FILL_AND_STROKE
        circlePaint.color = Color.WHITE
        circlePaint.strokeWidth = strokeWidth

        circleStrokePaint.isAntiAlias = true
        circleStrokePaint.style = Paint.Style.STROKE
        circleStrokePaint.color = Color.parseColor("#ADA9AC")
        circleStrokePaint.strokeWidth = strokeWidth

        dividerPaint.isAntiAlias = true
        dividerPaint.style = Paint.Style.FILL
        dividerPaint.color = Color.BLACK
        dividerPaint.strokeWidth = dp2px(3F)

        gearValuePaint.isAntiAlias = true
        gearValuePaint.style = Paint.Style.FILL_AND_STROKE
        gearValuePaint.color = Color.BLACK
        gearValuePaint.textSize = dp2px(18F)

        valuePaint.isAntiAlias = true
        valuePaint.style = Paint.Style.FILL
        valuePaint.color = Color.BLACK
        valuePaint.textAlign = Paint.Align.CENTER
        valuePaint.textSize = dp2px(35F)

        unitPaint.isAntiAlias = true
        unitPaint.style = Paint.Style.FILL
        unitPaint.color = Color.BLACK
        unitPaint.textAlign = Paint.Align.CENTER
        unitPaint.textSize = dp2px(20F)

        semicircleRect = RectF()
        centerCircleRect = RectF()
        indexEndpointRect = RectF()
        valveTargetRect = RectF()
        valveCurrentRect = RectF()
        motorTorqueRect = RectF()
        valueRect = RectF()

        valuePath = Path()
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        canvas?.save()

        val semicircleRadius: Float = width / 2F

        valveTargetRect.top = strokeWidth
        valveTargetRect.left = strokeWidth
        valveTargetRect.right = semicircleRadius * 2 - strokeWidth
        valveTargetRect.bottom = semicircleRadius * 2 - strokeWidth
        canvas?.drawArc(valveTargetRect, -165F, value2Deg(valveTarget), true, valveTargetPaint)

        valveCurrentRect.top = strokeWidth
        valveCurrentRect.left = strokeWidth
        valveCurrentRect.right = semicircleRadius * 2 - strokeWidth
        valveCurrentRect.bottom = semicircleRadius * 2 - strokeWidth
        canvas?.drawArc(valveCurrentRect, -165F, value2Deg(valveCurrent), true, valveCurrentPaint)

        motorTorqueRect.top = semicircleRadius * 0.25F + dp2px(5F)
        motorTorqueRect.left = semicircleRadius * 0.25F + dp2px(5F)
        motorTorqueRect.right = semicircleRadius * 1.75F - dp2px(5F)
        motorTorqueRect.bottom = semicircleRadius * 1.75F - dp2px(5F)
        canvas?.drawArc(motorTorqueRect, -165F, value2Deg(mortorTorque), true, motorTorquePaint)

        // 半圓
        semicircleRect.top = strokeWidth
        semicircleRect.left = strokeWidth
        semicircleRect.right = semicircleRadius * 2 - strokeWidth
        semicircleRect.bottom = semicircleRadius * 2 - strokeWidth
        canvas?.drawArc(semicircleRect, 0F, -180F, true, semicirclePaint)

        indexEndpointRect.top = strokeWidth
        indexEndpointRect.left = strokeWidth
        indexEndpointRect.right = semicircleRadius * 2 - strokeWidth
        indexEndpointRect.bottom = semicircleRadius * 2 - strokeWidth
        canvas?.drawArc(indexEndpointRect, 0F, -180F, true, semicirclePaint)

        // 刻度弧度
        canvas?.drawArc(
            semicircleRadius * 0.25F + dp2px(5F),
            semicircleRadius * 0.25F + dp2px(5F),
            semicircleRadius * 1.75F - dp2px(5F),
            semicircleRadius * 1.75F - dp2px(5F),
            -15F,
            -150F,
            false,
            gearArcPaint
        )

        // 最兩邊刻度
        indexEndpointRect.top =
            (circleYPoint(semicircleRadius, semicircleRadius * 0.75F, -15F) - strokeWidth * 2).toFloat() + dp2px(5F)
        indexEndpointRect.left = semicircleRadius * 0.25F + dp2px(5F)
        indexEndpointRect.right = semicircleRadius * 0.25F + strokeWidth * 1.5F + dp2px(5F)
        indexEndpointRect.bottom = (circleYPoint(semicircleRadius, semicircleRadius * 0.75F, -15F)).toFloat() + dp2px(5F)
        canvas?.drawRect(indexEndpointRect, gearArcPaint)

        indexEndpointRect.top =
            (circleYPoint(semicircleRadius, semicircleRadius * 0.75F, -15F) - strokeWidth * 2).toFloat() + dp2px(5F)
        indexEndpointRect.left = semicircleRadius * 1.75F - strokeWidth * 1.5F - dp2px(5F)
        indexEndpointRect.right = semicircleRadius * 1.75F - dp2px(5F)
        indexEndpointRect.bottom = (circleYPoint(semicircleRadius, semicircleRadius * 0.75F, -15F)).toFloat() + dp2px(5F)
        canvas?.drawRect(indexEndpointRect, gearArcPaint)

        // 刻度
        for (i in 1..4) {
            canvas?.drawArc(
                semicircleRadius * 0.25F - strokeWidth * 2 + dp2px(5F),
                semicircleRadius * 0.25F - strokeWidth * 2 + dp2px(5F),
                semicircleRadius * 1.75F + strokeWidth * 2 - dp2px(5F),
                semicircleRadius * 1.75F + strokeWidth * 2 - dp2px(5F),
                i * -30F - 15 - 2,
                4F, // 刻度寬為4°
                false,
                gearArcPaint
            )
        }

        //刻度文字
        valueRect.top = semicircleRadius * 0.125F + dp2px(5F)
        valueRect.left = semicircleRadius * 0.125F + dp2px(5F)
        valueRect.right = semicircleRadius * 1.875F - dp2px(5F)
        valueRect.bottom = semicircleRadius * 1.875F - dp2px(5F)

        valuePath.addArc(valueRect, -165F, 180F)
        canvas?.drawTextOnPath("0", valuePath, 0f, 0f, gearValuePaint)
        canvas?.drawTextOnPath("20", valuePath, (valueRect.width() * PI / 12).toFloat() - dp2px(10F), 0f, gearValuePaint)
        canvas?.drawTextOnPath("40", valuePath, (valueRect.width() * PI / 6).toFloat() - dp2px(10F), 0f, gearValuePaint)
        canvas?.drawTextOnPath("60", valuePath, (valueRect.width() * PI / 4).toFloat() - dp2px(10F), 0f, gearValuePaint)
        canvas?.drawTextOnPath("80", valuePath, (valueRect.width() * PI / 3).toFloat() - dp2px(10F), 0f, gearValuePaint)
        canvas?.drawTextOnPath("100%", valuePath, (valueRect.width() * PI * 5 / 12).toFloat() - dp2px(20F), 0f, gearValuePaint)

        // 中心圓
        centerCircleRect.top = semicircleRadius * 0.5F + strokeWidth
        centerCircleRect.left = semicircleRadius * 0.5F + strokeWidth
        centerCircleRect.right = semicircleRadius * 1.5F - strokeWidth
        centerCircleRect.bottom = semicircleRadius * 1.5F - strokeWidth
        canvas?.drawArc(centerCircleRect, 0F, 360F, true, circlePaint)

        // 中心圓的外框
        centerCircleRect.top = semicircleRadius * 0.5F + strokeWidth
        centerCircleRect.left = semicircleRadius * 0.5F + strokeWidth
        centerCircleRect.right = semicircleRadius * 1.5F - strokeWidth
        centerCircleRect.bottom = semicircleRadius * 1.5F - strokeWidth
        canvas?.drawArc(centerCircleRect, 0F, 360F, true, circleStrokePaint)

        // 中心圓分隔線
        canvas?.drawLine(
            semicircleRadius * 0.5F + strokeWidth * 3F,
            semicircleRadius,
            semicircleRadius * 1.5F - strokeWidth * 3F,
            semicircleRadius,
            dividerPaint
        )

        // value1
        canvas?.drawText(
            String.format("%.2f", value1),
            semicircleRadius,
            semicircleRadius - dp2px(15F),
            valuePaint
        )

        canvas?.drawText(
            "%",
            semicircleRadius + dp2px(10F) + String.format("%.2f", value1).length * dp2px(10F),
            semicircleRadius - dp2px(15F),
            unitPaint
        )

        // value2
        canvas?.drawText(
            "$value2",
            semicircleRadius,
            semicircleRadius + dp2px(40F),
            valuePaint
        )

        canvas?.drawText(
            "Nm",
            semicircleRadius + dp2px(20F) + "$value2".length * dp2px(10F),
            semicircleRadius + dp2px(40F),
            unitPaint
        )

        canvas?.restore()
    }

    private fun dp2px(dp: Float): Float =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.resources.displayMetrics)

    private fun circleYPoint(centerY: Float, radius: Float, angle: Float): Double {
        return centerY + radius * sin(deg2rad(angle))
    }

    private fun deg2rad(number: Float): Double = number * PI / 180

    private fun value2Deg(value: Float): Float {
        return if (value > 100F) {
            100.0F * 1.5F - 1F
        } else {
            if (value > 0) {
                value * 1.5F - 1F
            } else {
                value * 1.5F
            }
        }
    }

    fun setMin(value: Int) {
        minValue = value
        postInvalidate()
    }

    fun setMax(value: Int) {
        maxValue = value
        postInvalidate()
    }

    fun setValveTarget(value: Float) {
        valveTarget = when {
            value > 100 -> {
                100F
            }
            value < 0 -> {
                0F
            }
            else -> {
                value
            }
        }

        postInvalidate()
    }

    fun setValveCurrent(value: Float) {
        value1 = value

        valveCurrent = when {
            value > 100 -> {
                100F
            }
            value < 0 -> {
                0F
            }
            else -> {
                value
            }
        }
        postInvalidate()
    }

    fun setMortorTorque(value: Float) {
        mortorTorque = when {
            value > 100 -> {
                100F
            }
            value < 0 -> {
                0F
            }
            else -> {
                value
            }
        }
        postInvalidate()
    }

    fun setNm(value: Int) {
        value2 = value
        postInvalidate()
    }
}