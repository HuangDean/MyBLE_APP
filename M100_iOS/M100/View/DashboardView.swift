import Foundation
import UIKit

class DashboardView: UIView {
    
    private var semicircleView: UIView!
    private var circleView: UIView!
    private var arcView: UIView!
    private var indexEndpointView1: UIView!
    private var indexEndpointView2: UIView!
    private var labels: Array<UILabel>!
    private var label1: UILabel!
    private var label2: UILabel!
    private var dividerView: UIView!
    
    private var valveTargetView: UIView!    // 目標閥門位置 進度view
    private var valveCurrentView: UIView!   // 目前閥門位置 進度view
    private var motorTorqueView: UIView!    // 馬達扭力位置 進度view
    
    private var valveTargetColorPath: UIBezierPath!
    private var valveTargetColorLayer: CAShapeLayer!
    
    private var valveCurrentColorPath: UIBezierPath!
    private var valveCurrentColorLayer: CAShapeLayer!

    private var motorTorqueColorPath: UIBezierPath!
    private var motorTorqueColorLayer: CAShapeLayer!
    
    private let borderWidth: CGFloat = 4   // 底層半圓 邊線寬度
    private var semicircleRadius: CGFloat! // 底層半圓 半徑
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: - setUpView
    private func setUpView() {
        semicircleView = UIView(frame: .zero)
        semicircleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(semicircleView)
        
        valveTargetView = UIView(frame: .zero)
        valveTargetView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(valveTargetView)
        
        valveCurrentView = UIView(frame: .zero)
        valveCurrentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(valveCurrentView)
        
        motorTorqueView = UIView(frame: .zero)
        motorTorqueView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(motorTorqueView)
        
        circleView = UIView(frame: .zero)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(circleView)
        
        label1 = UILabel(frame: .zero)
        label1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label1)
        label1.font = UIFont.systemFont(ofSize: 36)
        label1.text = "0.00"
        
        let lavel1uUnit = UILabel(frame: .zero)
        lavel1uUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lavel1uUnit)
        lavel1uUnit.font = UIFont.systemFont(ofSize: 20)
        lavel1uUnit.text = "%"
        
        dividerView = UIView(frame: .zero)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dividerView)
        dividerView.backgroundColor = .black
        
        label2 = UILabel(frame: .zero)
        label2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label2)
        label2.textColor = .darkGray
        label2.font = UIFont.systemFont(ofSize: 36)
        label2.text = "0"
        
        let lavel2uUnit = UILabel(frame: .zero)
        lavel2uUnit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lavel2uUnit)
        lavel2uUnit.textColor = .darkGray
        lavel2uUnit.font = UIFont.systemFont(ofSize: 15)
        lavel2uUnit.text = "Nm"
        
        arcView = UIView(frame: .zero)
        self.addSubview(arcView)
        
        indexEndpointView1 = UIView(frame: .zero)
        indexEndpointView1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indexEndpointView1)
        indexEndpointView1.backgroundColor = .black

        indexEndpointView2 = UIView(frame: .zero)
        indexEndpointView2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indexEndpointView2)
        indexEndpointView2.backgroundColor = .black
        
        labels = Array<UILabel>()
        for i in 0...5 {
            let label = UILabel(frame: .zero)
            self.addSubview(label)
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = "\(i * 20)"
            
            if (i == 5) { label.text?.append("%") }
            label.sizeToFit()
            
            labels.append(label)
        }
        
        self.valveTargetColorPath = UIBezierPath()
        self.valveTargetColorLayer = CAShapeLayer()

        self.valveCurrentColorPath = UIBezierPath()
        self.valveCurrentColorLayer = CAShapeLayer()
        
        self.motorTorqueColorPath = UIBezierPath()
        self.motorTorqueColorLayer = CAShapeLayer()
        
        NSLayoutConstraint.activate([
            lavel1uUnit.leadingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 4),
            lavel1uUnit.bottomAnchor.constraint(equalTo: label1.bottomAnchor),
            
            lavel2uUnit.leadingAnchor.constraint(equalTo: label2.trailingAnchor, constant: 10),
            lavel2uUnit.bottomAnchor.constraint(equalTo: label2.bottomAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    
        semicircleRadius = self.bounds.width / 2
        let circleRadius: CGFloat = semicircleRadius / 2  // 中心圓半徑
        
        let semicircleHeightBorder: CGFloat = semicircleRadius + self.borderWidth / 2
        
        let indexEndpointViewConstant: CGFloat = circleYPoint(centerY: semicircleRadius,
                                                              radius: semicircleRadius * 0.75,
                                                              angle: -15) - borderWidth * 3
        
        let indexEndpointView1Margin: CGFloat = semicircleRadius * 0.25 - borderWidth * 1.5
        
        NSLayoutConstraint.activate([
            semicircleView.topAnchor.constraint(equalTo: self.topAnchor),
            semicircleView.widthAnchor.constraint(equalToConstant: self.bounds.width),
            semicircleView.heightAnchor.constraint(equalToConstant: semicircleHeightBorder), // 調整下邊因有描邊寬度被切邊問題
            
            valveTargetView.topAnchor.constraint(equalTo: self.topAnchor),
            valveTargetView.widthAnchor.constraint(equalToConstant: self.bounds.width),
            valveTargetView.heightAnchor.constraint(equalToConstant: semicircleHeightBorder), // 調整下邊因有描邊寬度被切邊問題
            
            valveCurrentView.topAnchor.constraint(equalTo: self.topAnchor),
            valveCurrentView.widthAnchor.constraint(equalToConstant: self.bounds.width),
            valveCurrentView.heightAnchor.constraint(equalToConstant: semicircleHeightBorder), // 調整下邊因有描邊寬度被切邊問題
            
            motorTorqueView.topAnchor.constraint(equalTo: self.topAnchor),
            motorTorqueView.widthAnchor.constraint(equalToConstant: self.bounds.width),
            motorTorqueView.heightAnchor.constraint(equalToConstant: semicircleHeightBorder), // 調整下邊因有描邊寬度被切邊問題
            
            circleView.centerXAnchor.constraint(equalTo: semicircleView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: semicircleView.centerYAnchor, constant: circleRadius),
            circleView.widthAnchor.constraint(equalToConstant: self.bounds.width * 0.5),
            circleView.heightAnchor.constraint(equalToConstant: self.bounds.width * 0.5),
            
            label1.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label1.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -4),
            
            dividerView.leadingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: 10),
            dividerView.trailingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: -10),
            dividerView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 2),
            
            label2.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            label2.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 4),
            
            indexEndpointView1.topAnchor.constraint(equalTo: self.topAnchor, constant: indexEndpointViewConstant),
            indexEndpointView1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: indexEndpointView1Margin),
            indexEndpointView1.widthAnchor.constraint(equalToConstant: borderWidth * 4.5),
            indexEndpointView1.heightAnchor.constraint(equalToConstant: borderWidth * 5),

            indexEndpointView2.topAnchor.constraint(equalTo: self.topAnchor, constant: indexEndpointViewConstant),
            indexEndpointView2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(indexEndpointView1Margin)),
            indexEndpointView2.widthAnchor.constraint(equalToConstant: borderWidth * 4.5),
            indexEndpointView2.heightAnchor.constraint(equalToConstant: borderWidth * 5),
        ])
        
        // label位置
        for i in 0...5 {
            labels[i].center = circleXYPoint(center: semicircleRadius, radius: semicircleRadius * 7 / 8 + borderWidth * 3 / 2, angle: Double(i * 30 + 195))
            
            // 選轉角度 -75, -45, -15, 15, 45, 75
            switch i {
            case 0...2:
                labels[i].transform = CGAffineTransform(rotationAngle: deg2rad(Double(i * 30 - 75)))
            default:
                labels[i].transform = CGAffineTransform(rotationAngle: deg2rad(Double((i - 3) * 30 + 15)))
            }
        }
        
        // MARK: 底層半圓描邊
        let semicirclePath = UIBezierPath()
        semicirclePath.addArc(withCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                    radius: semicircleRadius - borderWidth / 2, // 調整因有描邊寬度被切邊問題
                    startAngle: 0,
                    endAngle: CGFloat.pi,
                    clockwise: false)
        semicirclePath.close()

        let semicircleLayer = CAShapeLayer()
        semicircleLayer.path = semicirclePath.cgPath
        semicircleLayer.fillColor = UIColor.clear.cgColor
        semicircleLayer.strokeColor = UIColor.lightGray.cgColor
        semicircleLayer.lineWidth = borderWidth
        semicircleView.layer.addSublayer(semicircleLayer)
        
        // MARK: 圓描邊
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: circleRadius, y: circleRadius),
                                      radius: circleRadius - borderWidth / 2, // 調整因有描邊寬度被切邊問題
                                      startAngle: 0,
                                      endAngle: CGFloat.pi * 2,
                                      clockwise: false)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.lineWidth = borderWidth
        circleView.layer.addSublayer(circleLayer)
        
        // MARK: 弧形指示線
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                                   radius: semicircleRadius * 3 / 4,
                                   startAngle: deg2rad(345),
                                   endAngle: deg2rad(195),
                                   clockwise: false)

        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.black.cgColor
        arcLayer.lineWidth = borderWidth * 2
        arcView.layer.addSublayer(arcLayer)
        
        // MARK: 齒輪的刻度
        let gearMaskPath = UIBezierPath()
        
        for i in 1...4 {
            gearMaskPath.move(to: circleXYPoint(center: semicircleRadius, radius: semicircleRadius * 3 / 4 + borderWidth * 3 / 2, angle: -Double(i * 30 + 15 + 2)))
            gearMaskPath.addArc(withCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                                radius: semicircleRadius * 3 / 4 + borderWidth * 3 / 2,
                                startAngle: deg2rad(-Double(i * 30 + 15 - 2)), // 刻度寬為4°
                                endAngle: deg2rad(-Double(i * 30 + 15 + 2)),
                                clockwise: false)
        }
        
        let gearMaskLayer = CAShapeLayer()
        gearMaskLayer.path = gearMaskPath.cgPath
        gearMaskLayer.fillColor = UIColor.clear.cgColor
        gearMaskLayer.strokeColor = UIColor.black.cgColor
        gearMaskLayer.lineWidth = borderWidth * 3
        arcView.layer.addSublayer(gearMaskLayer)
    }
    
    private func deg2rad(_ number: Double) -> CGFloat {
        return CGFloat(number * .pi / 180)
    }
    
    private func value2rad(value: Double) -> CGFloat {
        return deg2rad(value * 1.5 - 165)
    }
    
    private func circleXYPoint(center: CGFloat, radius: CGFloat, angle: Double) -> CGPoint {
        return CGPoint(x: circleXPoint(centerX: center, radius: radius, angle: angle),
                       y: circleYPoint(centerY: center, radius: radius, angle: angle))
    }
    
    private func circleXPoint(centerX: CGFloat, radius: CGFloat, angle: Double) -> CGFloat {
        return centerX + radius * cos(deg2rad(angle))
    }
    
    private func circleYPoint(centerY: CGFloat, radius: CGFloat, angle: Double) -> CGFloat {
        return centerY + radius * sin(deg2rad(angle))
    }
    
    // MARK: - public func
    
    public func updateValveTarget(value: Float) {
        // if !String(value).isInt { return } // 檢查是否通過-Inf
        var value = value
        
        if value > 100 {
            value = 100
        } else if value < 0 {
            value = 0
        }
        
        valveTargetColorPath.removeAllPoints()
        valveTargetColorPath.move(to: CGPoint(x: semicircleRadius, y: semicircleRadius))
        valveTargetColorPath.addArc(withCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                                    radius: semicircleRadius - borderWidth, // 調整因有描邊寬度被切邊問題
                                    startAngle: deg2rad(Double(-165)),
                                    endAngle: value2rad(value: Double(value)),
                                    clockwise: true)

        valveTargetColorLayer.path = valveTargetColorPath.cgPath
        valveTargetColorLayer.fillColor = UIColor.systemOrange.cgColor
        valveTargetView.layer.addSublayer(valveTargetColorLayer)
    }
    
    public func updateValveCurrent(value: Float) {
        // if !String(value).isInt { return } // 檢查是否通過-Inf
        
        var limitValue = value
        
        if value > 100 {
            limitValue = 100
        } else if value < 0 {
            limitValue = 0
        }
        
        valveCurrentColorPath.removeAllPoints()
        valveCurrentColorPath.move(to: CGPoint(x: semicircleRadius, y: semicircleRadius))
        valveCurrentColorPath.addArc(withCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                                     radius: semicircleRadius - borderWidth, // 調整因有描邊寬度被切邊問題
                                     startAngle: deg2rad(Double(-165)),
                                     endAngle: value2rad(value: Double(limitValue)),
                                     clockwise: true)

        valveCurrentColorLayer.path = valveCurrentColorPath.cgPath
        valveCurrentColorLayer.fillColor = UIColor.yellow.cgColor
        valveCurrentView.layer.addSublayer(valveCurrentColorLayer)
        
        label1.text = String(format: "%.2f", value)
    }
    
    public func updateMotorTorque(value: Float) {
        // if !String(value).isInt { return } // 檢查是否通過-Inf
        
        var value = value
        
        if value > 100 {
            value = 100
        } else if value < 0 {
            value = 0
        }
        
        motorTorqueColorPath.removeAllPoints()
        motorTorqueColorPath.move(to: CGPoint(x: semicircleRadius, y: semicircleRadius))
        motorTorqueColorPath.addArc(withCenter: CGPoint(x: semicircleRadius, y: semicircleRadius),
                                    radius: semicircleRadius * 3 / 4 , // 調整因有描邊寬度被切邊問題
                                    startAngle: deg2rad(Double(-165)),
                                    endAngle: value2rad(value: Double(value)),
                                    clockwise: true)

        motorTorqueColorLayer.path = motorTorqueColorPath.cgPath
        motorTorqueColorLayer.fillColor = UIColor.systemBlue.cgColor
        motorTorqueView.layer.addSublayer(motorTorqueColorLayer)
    }
    
    public func updateCorrectionMotorTorque(value: Float) {
        label2.text = String(Int(value))
    }
}


extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isFloat: Bool {
        return Int(self) != nil
    }
}
