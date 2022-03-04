import UIKit

class SwitchProgressView: UIView {
    
    private var view: UIView!
    
    private var image1: UIImageView!
    private var image2: UIImageView!

    private var label1: UILabel!
    private var label2: UILabel!
    
    private var image1LeadingAnchor: NSLayoutConstraint!
    private var image2TrailingAnchor: NSLayoutConstraint!
    
    private var minLeadingAnchor: NSLayoutConstraint!
    private var maxTrailingAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.init(rgb: 0x3F5D87)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.backgroundColor = UIColor.init(rgb: 0xDEE6F1)
        
        image1 = UIImageView(frame: .zero)
        image1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image1)
        image1.image = UIImage(named: "left_arrow")
        image1.contentMode = .scaleAspectFit
        
        image2 = UIImageView(frame: .zero)
        image2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image2)
        image2.image = UIImage(named: "right_arrow")
        image2.contentMode = .scaleAspectFit
    
        label1 = UILabel(frame: .zero)
        label1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label1)
        label1.font = UIFont.systemFont(ofSize: 12)
        
        label2 = UILabel(frame: .zero)
        label2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label2)
        label2.font = UIFont.systemFont(ofSize: 12)
        
        let width = UIScreen.main.bounds.width - 176
        
        minLeadingAnchor = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.02 * width)
        maxTrailingAnchor = view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0.02 * width)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            minLeadingAnchor,
            maxTrailingAnchor,
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            
            image1.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            image1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            image1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.15 * width),
            
            image2.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            image2.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            image2.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0.15 * width),
            
            label1.centerXAnchor.constraint(equalTo: image1.centerXAnchor),
            label1.centerYAnchor.constraint(equalTo: image1.centerYAnchor),

            label2.centerXAnchor.constraint(equalTo: image2.centerXAnchor),
            label2.centerYAnchor.constraint(equalTo: image2.centerYAnchor),
        ])
    }
    
    func setMinValue(minValue: String) {
        if let value = Int(minValue) {
            minLeadingAnchor.constant = CGFloat(value) / 100 * self.frame.width
        }
    }
    
    func setMaxValue(maxValue: String) {
        if let value = Int(maxValue) {
            maxTrailingAnchor.constant = CGFloat(value - 100) / 100 * self.frame.width
        }
    }
    
    func setCloseLabel(value: String) {
        label1.text = "\(value)%"
    }
    
    func setOpenLabel(value: String) {
        label2.text = "\(value)%"
    }
}



