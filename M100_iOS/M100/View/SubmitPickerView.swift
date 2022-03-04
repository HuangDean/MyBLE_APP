import UIKit

class SubmitPickerView: UIView {
    
    open var titleLabel: UILabel!
    open var titleImageView: UIImageView!
    open var button: UIButton!
    open var textField: UITextField!
    
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
        
        titleImageView = UIImageView(frame: .zero)
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleImageView)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        button.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "checkbox_normal"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        textField.setLeftPadding(10)
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.placeholder = NSLocalizedString("config_placeholder", comment: "")
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            titleImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20),
            
            button.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            
            textField.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
