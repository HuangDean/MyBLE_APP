import UIKit

class ProgressView: UIView {
    
    private var progressView: UIProgressView!
    private var titleLabel: UILabel!
    
    private var maxValue: Float = 0.0
    private var minValue: Float = 100.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        progressView = UIProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progressView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .right
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.bounds.height / 3),
            progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -10),
            progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.bounds.height / 3),
            
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            titleLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    open func setTitle(title: String) {
        titleLabel.text = title
    }
    
    open func setBackgroundColor(color: UIColor) {
        progressView.backgroundColor = color
    }
    
    open func setProgressColor(color: UIColor) {
        progressView.progressTintColor = color
    }
    
    open func getMaxValue() -> Float { maxValue }
    
    open func setMaxValue(value: Float) {
        self.maxValue = value
    }
    
    open func getMinValue()  -> Float { minValue }
    
    open func setMinValue(value: Float) {
        self.minValue = value
    }
    
    open func updateProgress(progress: Float) {
        progressView.progress = progress / maxValue
    }
}
