import UIKit

class SubmitTextField: UIView {
    
    open var titleLabel: UILabel!
    open var textField: UITextField!
    open var unitLabel: UILabel!
    open var button: UIButton!
    open var switchLabel: UILabel!
    open var `switch`: UISwitch!
    
    private var textFieldTrailingAnchor1: NSLayoutConstraint!
    private var textFieldTrailingAnchor2: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        textField.autocorrectionType = .no
        
        unitLabel = UILabel(frame: .zero)
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(unitLabel)
        unitLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
        button.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 1), forState: .highlighted)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        switchLabel = UILabel(frame: .zero)
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(switchLabel)
        switchLabel.text = NSLocalizedString("config_off", comment: "")
        switchLabel.isHidden = true
        
        `switch` = UISwitch(frame: .zero)
        `switch`.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(`switch`)
        `switch`.isHidden = true
        
        textFieldTrailingAnchor1 = textField.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor, constant: -10)
        textFieldTrailingAnchor2 = textField.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            `switch`.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            `switch`.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            switchLabel.centerYAnchor.constraint(equalTo: `switch`.centerYAnchor),
            switchLabel.trailingAnchor.constraint(equalTo: `switch`.leadingAnchor, constant: -10),
            
            view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            view.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldTrailingAnchor1,
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            unitLabel.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10),
            unitLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
    }
    
    open func setButtonHide() {
        button.isHidden = true
        NSLayoutConstraint.deactivate([textFieldTrailingAnchor1])
        NSLayoutConstraint.activate([textFieldTrailingAnchor2])
    }
    
    open func setSwitchDesplay() {
        `switch`.isHidden = false
        switchLabel.isHidden = false
    }
}
