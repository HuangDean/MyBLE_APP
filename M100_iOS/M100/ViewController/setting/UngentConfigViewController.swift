import UIKit

final class UngentConfigViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    
    private var openSignalActionTextField: SubmitTextField!
    private var ungentActionTextField: SubmitTextField!
    private var signalUngentPositionTextField: SubmitTextField!
    private var motorWarningTempeatureTextField: SubmitTextField!
    private var ungentIntputModeLabel: UILabel!
    private var ungentIntputModeButton: UIButton!
    private var mainStackView: UIStackView!
    
    private var openSignalActionPickerView: UIToolbarPickerView!
    private let openSignalActions: Array<String> = Array(arrayLiteral: NSLocalizedString("ungent_config_open_signal_action1", comment: ""),
                                                         NSLocalizedString("ungent_config_open_signal_action2", comment: ""),
                                                         NSLocalizedString("ungent_config_open_signal_action3", comment: ""))
    private var openSignalAction: Int!
    
    private var ungentActionPickerView: UIToolbarPickerView!
    private let ungentActions: Array<String> = Array(arrayLiteral: NSLocalizedString("ungent_config_ungent_action1", comment: ""),
                                                     NSLocalizedString("ungent_config_ungent_action2", comment: ""),
                                                     NSLocalizedString("ungent_config_ungent_action3", comment: ""),
                                                     NSLocalizedString("ungent_config_ungent_action4", comment: ""))
    private var ungentAction: Int!
    
    private var pickerIndex: Int = 0
    
    private lazy var viewModel: UngentConfigViewModel = { UngentConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("ungent_config_title"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        openSignalActionPickerView = UIToolbarPickerView()
        openSignalActionPickerView.dataSource = self
        openSignalActionPickerView.delegate = self
        openSignalActionPickerView.toolbarDelegate = self
        
        ungentActionPickerView = UIToolbarPickerView()
        ungentActionPickerView.dataSource = self
        ungentActionPickerView.delegate = self
        ungentActionPickerView.toolbarDelegate = self
        
        openSignalActionTextField = SubmitTextField(frame: .zero)
        openSignalActionTextField.translatesAutoresizingMaskIntoConstraints = false
        openSignalActionTextField.textField.inputView = openSignalActionPickerView
        openSignalActionTextField.textField.inputAccessoryView = openSignalActionPickerView.toolbar
        openSignalActionTextField.textField.keyboardType = .asciiCapableNumberPad
        openSignalActionTextField.setButtonHide()
        openSignalActionTextField.titleLabel.text = getResString("ungent_config_open_signal_action")
        openSignalActionTextField.textField.placeholder = getResString("config_placeholder")
        
        ungentActionTextField = SubmitTextField(frame: .zero)
        ungentActionTextField.translatesAutoresizingMaskIntoConstraints = false
        ungentActionTextField.textField.inputView = ungentActionPickerView
        ungentActionTextField.textField.inputAccessoryView = ungentActionPickerView.toolbar
        ungentActionTextField.textField.keyboardType = .asciiCapableNumberPad
        ungentActionTextField.setButtonHide()
        ungentActionTextField.titleLabel.text = getResString("ungent_config_ungent_action")
        ungentActionTextField.textField.placeholder = getResString("config_placeholder")
        
        signalUngentPositionTextField = SubmitTextField(frame: .zero)
        signalUngentPositionTextField.translatesAutoresizingMaskIntoConstraints = false
        signalUngentPositionTextField.textField.keyboardType = .asciiCapableNumberPad
        signalUngentPositionTextField.titleLabel.text = getResString("ungent_config_signal_ungent_position")
        signalUngentPositionTextField.unitLabel.text = "%"
        signalUngentPositionTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        motorWarningTempeatureTextField = SubmitTextField(frame: .zero)
        motorWarningTempeatureTextField.translatesAutoresizingMaskIntoConstraints = false
        motorWarningTempeatureTextField.setSwitchDesplay()
        motorWarningTempeatureTextField.textField.keyboardType = .asciiCapableNumberPad
        motorWarningTempeatureTextField.titleLabel.text = getResString("ungent_config_motorWarning_tempeature")
        motorWarningTempeatureTextField.unitLabel.text = "°C"
        motorWarningTempeatureTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        motorWarningTempeatureTextField.switch.addTarget(self, action: #selector(switchChange(_:)), for: .touchUpInside)
        
        let ungentIntputModeTitleLabel = UILabel(frame: .zero)
        ungentIntputModeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ungentIntputModeTitleLabel.text = getResString("ungent_config_ungent_intput_mode")
        
        ungentIntputModeButton = UIButton(frame: .zero)
        ungentIntputModeButton.translatesAutoresizingMaskIntoConstraints = false
        ungentIntputModeButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
        ungentIntputModeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        ungentIntputModeButton.setTitle(getResString("config_nc"), for: .normal)
        ungentIntputModeButton.setTitleColor(.black, for: .normal)
        ungentIntputModeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        ungentIntputModeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let ungentInputModeStackView = UIStackView(arrangedSubviews: [ungentIntputModeTitleLabel, ungentIntputModeButton])
        ungentInputModeStackView.axis = .horizontal
        ungentInputModeStackView.spacing = 10
        
        mainStackView = UIStackView(arrangedSubviews: [openSignalActionTextField,
                                                       ungentActionTextField,
                                                       signalUngentPositionTextField,
                                                       motorWarningTempeatureTextField,
                                                       ungentInputModeStackView])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.distribution = .fillProportionally
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: screenWidth),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
        ])
        
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.ungentConfigStatus.subscribe(onNext: { status in
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
        
        viewModel.openSignalAction.subscribe(onNext: { value in
            self.openSignalActionTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.ungentAction.subscribe(onNext: { value in
            self.ungentActionTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.signalUngentPosition.subscribe(onNext: { value in
            self.signalUngentPositionTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.motorWarningSwitch.subscribe(onNext: { isOn in
            self.motorWarningTempeatureTextField.switch.isOn = isOn
        }).disposed(by: disposeBag)
        
        viewModel.motorWarningTempeature.subscribe(onNext: { value in
            self.motorWarningTempeatureTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.ungentIntputSwitch.subscribe(onNext: { value in
            self.ungentIntputModeButton.tag = value
            
            if value == 1 {
                self.ungentIntputModeButton.setImage(UIImage(named: "checkbox_enable"), for: .normal)
                self.ungentIntputModeButton.setTitle(self.getResString("config_no"), for: .normal)
            } else {
                self.ungentIntputModeButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
                self.ungentIntputModeButton.setTitle(self.getResString("config_nc"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
    }
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func switchChange(_ sender: UISwitch) {
        viewModel.didSave(index: 3, value: sender.isOn ? "1" : "0")
        
        if motorWarningTempeatureTextField.switch.isOn {
            motorWarningTempeatureTextField.switchLabel.text = getResString("config_on")
        } else {
            motorWarningTempeatureTextField.switchLabel.text = getResString("config_off")
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender {
        case signalUngentPositionTextField.button:
            if let value = signalUngentPositionTextField.textField.text, !value.isEmpty {
                if 0...100 ~= Int(value)! {
                    viewModel.didSave(index: 2, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("0_100")]))
                }
            }
        case motorWarningTempeatureTextField.button:
            if let value = motorWarningTempeatureTextField.textField.text, !value.isEmpty {
                if 0...120 ~= Int(value)! {
                    viewModel.didSave(index: 4, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("0_120")]))
                }
            }
        default:
            let mode = ungentIntputModeButton.tag
            if mode == 0 {
                ungentIntputModeButton.tag = 1
                self.ungentIntputModeButton.setImage(UIImage(named: "checkbox_enable"), for: .normal)
                self.ungentIntputModeButton.setTitle(getResString("config_no"), for: .normal)
            } else {
                ungentIntputModeButton.tag = 0
                self.ungentIntputModeButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
                self.ungentIntputModeButton.setTitle(getResString("config_nc"), for: .normal)
            }
            viewModel.didSave(index: 5, value: String(ungentIntputModeButton!.tag))
        }
    }
}

// MARK: - Delegate

extension UngentConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        if pickerView == openSignalActionPickerView {
            openSignalActionTextField.textField.text = openSignalActions[pickerIndex]
            openSignalAction = pickerIndex
            viewModel.didSave(index: 0, value: String(pickerIndex))
        } else {
            ungentActionTextField.textField.text = ungentActions[pickerIndex]
            ungentAction = pickerIndex
            viewModel.didSave(index: 1, value: String(pickerIndex))
        }
        
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension UngentConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
    }
}

extension UngentConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == openSignalActionPickerView {
            return self.openSignalActions.count
        } else {
            return self.ungentActions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == openSignalActionPickerView {
            return self.openSignalActions[row]
        } else {
            return self.ungentActions[row]
        }
    }
}

