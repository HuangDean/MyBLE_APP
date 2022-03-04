import UIKit

class CustomSlider: UISlider {

    private var label: UILabel!
    
    private var isInit: Bool = false
    private var isIntValue: Bool = false

    init(frame: CGRect, isInt: Bool = false) {
        super.init(frame: frame)
        self.isIntValue = isInt
        label = UILabel(frame: CGRect(x: self.thumbCenterX , y: 6, width: 31, height: 31))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isInit {
            if isIntValue {
                label.text = String(Int(self.value))
            } else {
                label.text = String(format: "%.1f", self.value)
            }
            
            label.sizeToFit()
            label.center.x = self.thumbCenterX
            self.addSubview(label)
        } else {
            isInit = true
            
            if isIntValue {
                label.text = String(Int(minimumValue))
            } else {
                label.text = String(format: "%.1f", minimumValue)
            }
        }
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let track = super.continueTracking(touch, with: event)
        
        
        
        return track
    }
    
//    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
//        super.endTracking(touch, with: event)
//        //label.removeFromSuperview()
//    }}
    
}


extension UISlider {
    
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        print(thumbRect)
        return thumbRect.midX + 2.5
    }
}
