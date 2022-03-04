import UIKit

final class SystemConfigViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    
    private var languageTextField: SubmitTextField!
    private var lightDefinitionTextField: SubmitTextField!
    private var maxOutputTorqueTextField: SubmitTextField!
    private var acVoltagePhaseTextField: SubmitTextField!
    private var acVoltageConfigTextField: SubmitTextField!
    private var stackView: UIStackView!
    
    private var languagePickerView: UIToolbarPickerView!
    private let languages: Array<String> = Array(arrayLiteral: NSLocalizedString("system_config_english", comment: ""),
                                                 NSLocalizedString("system_config_chinese_traditional", comment: ""),
                                                 NSLocalizedString("system_config_chinese_simplified", comment: ""))
    private var language: Int!
    
    private var lightDefinitionPickerView: UIToolbarPickerView!
    private let lightDefinitions: Array<String> = Array(arrayLiteral: NSLocalizedString("system_config_red_light", comment: ""),
                                                        NSLocalizedString("system_config_red_green", comment: ""))
    private var lightDefinition: Int!
    
    private var voltagePhasePickerView: UIToolbarPickerView!
    private let voltagePhases: Array<String> = Array(arrayLiteral: NSLocalizedString("system_config_three_phase", comment: ""),
                                                     NSLocalizedString("system_config_signle_phase", comment: ""))
    private var voltagePhase: Int!
    
    private var pickerIndex: Int = 0
    
    private lazy var viewModel: SystemConfigViewModel = { SystemConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        setNSNotificationCenter()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("system_config_title"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        languagePickerView = UIToolbarPickerView()
        languagePickerView.dataSource = self
        languagePickerView.delegate = self
        languagePickerView.toolbarDelegate = self
        
        lightDefinitionPickerView = UIToolbarPickerView()
        lightDefinitionPickerView.dataSource = self
        lightDefinitionPickerView.delegate = self
        lightDefinitionPickerView.toolbarDelegate = self
        
        voltagePhasePickerView = UIToolbarPickerView()
        voltagePhasePickerView.dataSource = self
        voltagePhasePickerView.delegate = self
        voltagePhasePickerView.toolbarDelegate = self
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        languageTextField = SubmitTextField(frame: .zero)
        languageTextField.translatesAutoresizingMaskIntoConstraints = false
        languageTextField.textField.inputView = languagePickerView
        languageTextField.textField.inputAccessoryView = languagePickerView.toolbar
        languageTextField.textField.keyboardType = .asciiCapableNumberPad
        languageTextField.setButtonHide()
        languageTextField.titleLabel.text = getResString("system_config_language")
        languageTextField.textField.placeholder = getResString("config_placeholder")
        
        lightDefinitionTextField = SubmitTextField(frame: .zero)
        lightDefinitionTextField.translatesAutoresizingMaskIntoConstraints = false
        lightDefinitionTextField.textField.inputView = lightDefinitionPickerView
        lightDefinitionTextField.textField.inputAccessoryView = lightDefinitionPickerView.toolbar
        lightDefinitionTextField.textField.keyboardType = .asciiCapableNumberPad
        lightDefinitionTextField.setButtonHide()
        lightDefinitionTextField.titleLabel.text = getResString("system_config_lightDefinition")
        lightDefinitionTextField.textField.placeholder = getResString("config_placeholder")
        
        maxOutputTorqueTextField = SubmitTextField(frame: .zero)
        maxOutputTorqueTextField.translatesAutoresizingMaskIntoConstraints = false
        maxOutputTorqueTextField.textField.keyboardType = .asciiCapableNumberPad
        maxOutputTorqueTextField.titleLabel.text = getResString("system_config_max_output_torque")
        maxOutputTorqueTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        acVoltagePhaseTextField = SubmitTextField(frame: .zero)
        acVoltagePhaseTextField.translatesAutoresizingMaskIntoConstraints = false
        acVoltagePhaseTextField.textField.inputView = voltagePhasePickerView
        acVoltagePhaseTextField.textField.inputAccessoryView = voltagePhasePickerView.toolbar
        acVoltagePhaseTextField.textField.keyboardType = .asciiCapableNumberPad
        acVoltagePhaseTextField.setButtonHide()
        acVoltagePhaseTextField.titleLabel.text = getResString("system_config_ac_voltage_phase")
        acVoltagePhaseTextField.textField.placeholder = getResString("config_placeholder")
        
        acVoltageConfigTextField = SubmitTextField(frame: .zero)
        acVoltageConfigTextField.translatesAutoresizingMaskIntoConstraints = false
        acVoltageConfigTextField.textField.keyboardType = .asciiCapableNumberPad
        acVoltageConfigTextField.titleLabel.text = getResString("system_config_ac_voltage_config")
        acVoltageConfigTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [languageTextField,
                                                   lightDefinitionTextField,
                                                   maxOutputTorqueTextField,
                                                   acVoltagePhaseTextField,
                                                   acVoltageConfigTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        if UserDefaults.standard.object(forKey: "permission") as? Int == 1 {
            maxOutputTorqueTextField.isHidden = true
            acVoltagePhaseTextField.isHidden = true
            acVoltageConfigTextField.isHidden = true
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: screenWidth),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.systemConfigStatus.subscribe(onNext: { status in
            switch status {
            case .Loading:
                self.showIndicator()
            case .Complete:
                self.hideIndicator()
            case .Save:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.viewModel.didGetData()
                })
            case .DisConnect:
                self.dismiss(animated: true, completion: nil)
                self.parentVC.didReAppear()
            }
        }).disposed(by: disposeBag)
        
        viewModel.language.subscribe(onNext: { value in
            self.languageTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.lightDefinition.subscribe(onNext: { value in
            self.lightDefinitionTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.maxOutputTorque.subscribe(onNext: { value in
            self.maxOutputTorqueTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.acVoltagePhase.subscribe(onNext: { value in
            self.acVoltagePhaseTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.acVoltageConfig.subscribe(onNext: { value in
            self.acVoltageConfigTextField.textField.text = value
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender {
        case maxOutputTorqueTextField.button:
            if let value = maxOutputTorqueTextField.textField.text, !value.isEmpty {
                viewModel.didSave(index: 2, value: value)
            }
        case acVoltageConfigTextField.button:
            if let value = acVoltageConfigTextField.textField.text, !value.isEmpty {
                viewModel.didSave(index: 4, value: value)
            }
        default:
            break
        }
    }
}

// MARK: - Delegate

extension SystemConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        switch pickerView {
        case languagePickerView:
            languageTextField.textField.text = languages[pickerIndex]
            language = pickerIndex
            viewModel.didSave(index: 0, value: String(pickerIndex))
        case lightDefinitionPickerView:
            lightDefinitionTextField.textField.text = lightDefinitions[pickerIndex]
            lightDefinition = pickerIndex
            viewModel.didSave(index: 1, value: String(pickerIndex))
        default:
            acVoltagePhaseTextField.textField.text = voltagePhases[pickerIndex]
            voltagePhase = pickerIndex
            viewModel.didSave(index: 3, value: String(pickerIndex))
        }
        
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension SystemConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
    }
}

extension SystemConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case languagePickerView:
            return languages.count
        case voltagePhasePickerView:
            return voltagePhases.count
        default:
            return lightDefinitions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case languagePickerView:
            return languages[row]
        case voltagePhasePickerView:
            return voltagePhases[row]
        default:
            return lightDefinitions[row]
        }
    }
}

extension SystemConfigViewController {
    
    func setNSNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 14, right: 0)
            self.scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = .zero
    }
}
