import UIKit

protocol LoginDelegate: class {
    func loginTapped(peripheralIndex: Int?, permission: Permission ,password: String)
}

enum Permission {
    case General
    case Dealer
    case Developer
}

final class LoginViewController: BaseViewController {
    
    private var permissionTextField: UITextField!
    private var passwordTextField: UITextField!
    
    private var permissions: Array<String> = Array(arrayLiteral: NSLocalizedString("login_gernal", comment: ""), 
                                                   NSLocalizedString("login_dealer", comment: ""),
                                                   NSLocalizedString("login_developer", comment: "")
    )
    private var permission: Permission = .General
    private lazy var  permissionPickerView: UIToolbarPickerView = {
        let pickerView = UIToolbarPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.toolbarDelegate = self
        pickerView.reloadAllComponents()
        return pickerView
    }()
    
    private var deviceName: String!
    private var peripheralIndex: Int?
    private var delegate: LoginDelegate?
    
    init(deviceName: String = " ", peripheralIndex: Int?, delegate: LoginDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.deviceName = deviceName
        self.peripheralIndex = peripheralIndex
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        navigationItem.title = "User permission"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))
        
        let deviceNameTitleLabel = UILabel(frame: .zero)
        deviceNameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(deviceNameTitleLabel)
        deviceNameTitleLabel.text = getResString("login_device_name")
        
        let deviceNameLabel = UILabel(frame: .zero)
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(deviceNameLabel)
        deviceNameLabel.textColor = UIColor.init(named: "dark_text")
        deviceNameLabel.text = deviceName
        
        let userPermissionTitleLabel = UILabel(frame: .zero)
        userPermissionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(userPermissionTitleLabel)
        userPermissionTitleLabel.text = getResString("login_user_name")
        
        permissionTextField = UITextField(frame: .zero)
        permissionTextField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(permissionTextField)
        permissionTextField.layer.cornerRadius = 5
        permissionTextField.layer.borderWidth = 1
        permissionTextField.layer.borderColor = UIColor.lightGray.cgColor
        permissionTextField.inputView = permissionPickerView
        permissionTextField.inputAccessoryView = permissionPickerView.toolbar
        permissionTextField.setLeftPadding(8)
        permissionTextField.tintColor = .clear
        permissionTextField.text = getResString("login_gernal")
        
        let passwordTitleLabel = UILabel(frame: .zero)
        passwordTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(passwordTitleLabel)
        passwordTitleLabel.text = getResString("login_password")
        
        passwordTextField = UITextField(frame: .zero)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(passwordTextField)
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.setLeftPadding(8)
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = getResString("login_password")
        
        let cancelButton = UIButton(frame: .zero)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
        cancelButton.setTitle(getResString("login_cancel"), for: .normal)
        cancelButton.setTitleColor(.lightGray, for: .normal)
        cancelButton.setTitleColor(.darkGray, for: .highlighted)
        cancelButton.setBackgroundColor(color: .lightGray, forState: .highlighted)
        
        let submitButton = UIButton(frame: .zero)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(submitButton)
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: #selector(self.submitTapped), for: .touchUpInside)
        submitButton.setTitle(getResString("login"), for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(.systemPink, for: .highlighted)
        submitButton.setBackgroundColor(color: .systemPink, forState: .normal)
        submitButton.setBackgroundColor(color: .white, forState: .highlighted)
        
        NSLayoutConstraint.activate([
            deviceNameTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            deviceNameTitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            deviceNameLabel.topAnchor.constraint(equalTo: deviceNameTitleLabel.bottomAnchor, constant: 10),
            deviceNameLabel.leadingAnchor.constraint(equalTo: deviceNameTitleLabel.leadingAnchor),
            
            userPermissionTitleLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 20),
            userPermissionTitleLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.leadingAnchor),
            
            permissionTextField.topAnchor.constraint(equalTo: userPermissionTitleLabel.bottomAnchor, constant: 10),
            permissionTextField.leadingAnchor.constraint(equalTo: userPermissionTitleLabel.leadingAnchor),
            permissionTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            permissionTextField.heightAnchor.constraint(equalToConstant: 30),
            
            passwordTitleLabel.topAnchor.constraint(equalTo: permissionTextField.bottomAnchor, constant: 20),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: permissionTextField.leadingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTitleLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: permissionTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 30),
            
            cancelButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            cancelButton.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.44),
            cancelButton.heightAnchor.constraint(equalToConstant: navBar.frame.height),
            
            submitButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            submitButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            submitButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            submitButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }
    
    // MARK: - Events
    
    @objc private func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitTapped() {
        
        if let password = passwordTextField.text, !password.isEmpty {
            
            // only developer password in local
            if permission == .Developer && password != "2293" {
                showAlert(msg: getResString("login_password_error"))
                return
            }
            
            delegate?.loginTapped(peripheralIndex: peripheralIndex, permission: permission, password: password)
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(msg: getResString("login_password_empty"))
        }
    }
        
}

// MARK: - Delegate

extension LoginViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            permission = .General
            permissionTextField.text = permissions[row]
        case 1:
            permission = .Dealer
            permissionTextField.text = permissions[row]
        default:
            permission = .Developer
            permissionTextField.text = permissions[row]
        }
    }
}

extension LoginViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.permissions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.permissions[row]
    }
}
