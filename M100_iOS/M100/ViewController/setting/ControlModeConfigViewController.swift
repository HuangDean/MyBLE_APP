import UIKit

final class ControlModeConfigViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    private var remoteControlModeSwitch: UISwitch!
    private var remoteControlSwitchLabel: UILabel!
    private var remoteControlModeTextField: UITextField!
    private var inputSensitivitySlider: CustomSlider!
    private var digitalInputEnableButton: UIButton!
    private var digitalInputButton: UIButton!
    private var proportionalInputButton: UIButton!
    private var proportionalOutputButton: UIButton!
    private var signalInputModeSwitch: UISwitch!
    private var signalInputModeImageView: UIImageView!
    private var signalInputModeLabel: UILabel!
    private var inputModeConfigTextField: UITextField!
    private var outputModeConfigTextField: UITextField!
    private var mainStackView: UIStackView!
    
    private let remoteControlModels: Array<String> = [NSLocalizedString("control_mode_remote_config_1", comment: ""),
                                                      NSLocalizedString("control_mode_remote_config_2", comment: ""),
                                                      NSLocalizedString("control_mode_remote_config_3", comment: ""),
                                                      "Modbus",
                                                      "Profibus"]
    private var remoteControlModel: Int = 0
    private lazy var remoteControlModePickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    
    private lazy var inputConfigModes: Array<String> = {
        return Array(arrayLiteral: getResString("0_20mA"), getResString("4_20mA"), getResString("0_5V"), getResString("1_5V"), getResString("0_10V"), getResString("2_10V"))
    }()
    private var inputConfigMode: Int = 0
    private lazy var inputConfigModePickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    private var pickerIndex: Int = 0
    private var beginTextField: UITextField!
    
    private lazy var viewModel: ControlModeConfigViewModel = { ControlModeConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        setNSNotificationCenter()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("control_mode_config_title"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        let remoteControlModeLabel = UILabel(frame: .zero)
        remoteControlModeLabel.translatesAutoresizingMaskIntoConstraints = false
        remoteControlModeLabel.text = getResString("control_mode_config_remote_control_mode")
        
        remoteControlSwitchLabel = UILabel(frame: .zero)
        remoteControlSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        remoteControlSwitchLabel.text = getResString("config_off")
        
        remoteControlModeSwitch = UISwitch(frame: .zero)
        remoteControlModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        remoteControlModeSwitch.addTarget(self, action: #selector(switchChange(_:)), for: .touchUpInside)
        
        let stackView1 = UIStackView(arrangedSubviews: [remoteControlModeLabel, remoteControlSwitchLabel, remoteControlModeSwitch])
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        stackView1.axis = .horizontal
        stackView1.spacing = 10
        
        remoteControlModeTextField = UITextField(frame: .zero)
        remoteControlModeTextField.translatesAutoresizingMaskIntoConstraints = false
        remoteControlModeTextField.setLeftPadding(10)
        remoteControlModeTextField.layer.cornerRadius = 5
        remoteControlModeTextField.layer.masksToBounds = true
        remoteControlModeTextField.backgroundColor = .white
        remoteControlModeTextField.inputAccessoryView = remoteControlModePickerView.toolbar
        remoteControlModeTextField.inputView = remoteControlModePickerView
        remoteControlModeTextField.placeholder = getResString("config_placeholder")
        remoteControlModeTextField.delegate = self
        
        let stackView2 = UIStackView(arrangedSubviews: [stackView1, remoteControlModeTextField])
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        stackView2.axis = .vertical
        stackView2.distribution = .fillEqually
        stackView2.spacing = 10
        
        let inputSensitivityLabel = UILabel(frame: .zero)
        inputSensitivityLabel.translatesAutoresizingMaskIntoConstraints = false
        inputSensitivityLabel.text = getResString("control_mode_config_input_sensitivity")
        
        inputSensitivitySlider = CustomSlider(frame: .zero)
        inputSensitivitySlider.translatesAutoresizingMaskIntoConstraints = false
        inputSensitivitySlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        inputSensitivitySlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        inputSensitivitySlider.value = 0
        inputSensitivitySlider.minimumValue = 0
        inputSensitivitySlider.maximumValue = 5
        inputSensitivitySlider.addTarget(self, action: #selector(sliderChangeEnd(_:)), for: .touchUpInside)
        inputSensitivitySlider.addTarget(self, action: #selector(sliderChangeEnd(_:)), for: .touchUpOutside)
        
        let stackView3 = UIStackView(arrangedSubviews: [inputSensitivityLabel, inputSensitivitySlider])
        stackView3.translatesAutoresizingMaskIntoConstraints = false
        stackView3.axis = .vertical
        stackView3.spacing = 10
        
        let digitalInputLabel = UILabel(frame: .zero)
        digitalInputLabel.translatesAutoresizingMaskIntoConstraints = false
        digitalInputLabel.text = getResString("control_mode_config_digital_input")
        
        digitalInputEnableButton = UIButton(frame: .zero)
        digitalInputEnableButton.translatesAutoresizingMaskIntoConstraints = false
        digitalInputEnableButton.setTitle(getResString("config_nc"), for: .normal)
        digitalInputEnableButton.setTitleColor(.black, for: .normal)
        digitalInputEnableButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
        digitalInputEnableButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        digitalInputEnableButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        digitalInputEnableButton.titleLabel?.adjustsFontSizeToFitWidth = true
        digitalInputEnableButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        let stackView4 = UIStackView(arrangedSubviews: [digitalInputLabel, digitalInputEnableButton])
        stackView4.translatesAutoresizingMaskIntoConstraints = false
        stackView4.axis = .horizontal
        stackView4.spacing = 10
        
        digitalInputButton = UIButton(frame: .zero)
        digitalInputButton.translatesAutoresizingMaskIntoConstraints = false
        digitalInputButton.layer.cornerRadius = 10
        digitalInputButton.layer.masksToBounds = true
        digitalInputButton.setTitle(getResString("ch1"), for: .normal)
        digitalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
        digitalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 1), forState: .highlighted)
        digitalInputButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        let stackView5 = UIStackView(arrangedSubviews: [stackView4, digitalInputButton])
        stackView5.translatesAutoresizingMaskIntoConstraints = false
        stackView5.axis = .vertical
        stackView5.spacing = 10
        
        let proportionalInputLabel = UILabel(frame: .zero)
        proportionalInputLabel.translatesAutoresizingMaskIntoConstraints = false
        proportionalInputLabel.text = getResString("control_mode_config_proportional_input")
        
        proportionalInputButton = UIButton(frame: .zero)
        proportionalInputButton.translatesAutoresizingMaskIntoConstraints = false
        proportionalInputButton.layer.cornerRadius = 10
        proportionalInputButton.layer.masksToBounds = true
        proportionalInputButton.setTitle(getResString("ch1"), for: .normal)
        proportionalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
        proportionalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 1), forState: .highlighted)
        proportionalInputButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        let stackView6 = UIStackView(arrangedSubviews: [proportionalInputLabel, proportionalInputButton])
        stackView6.translatesAutoresizingMaskIntoConstraints = false
        stackView6.axis = .vertical
        stackView6.spacing = 10
        
        let proportionalOutputLabel = UILabel(frame: .zero)
        proportionalOutputLabel.translatesAutoresizingMaskIntoConstraints = false
        proportionalOutputLabel.text = getResString("control_mode_config_proportional_output")
        
        proportionalOutputButton = UIButton(frame: .zero)
        proportionalOutputButton.translatesAutoresizingMaskIntoConstraints = false
        proportionalOutputButton.layer.cornerRadius = 10
        proportionalOutputButton.layer.masksToBounds = true
        proportionalOutputButton.setTitle(getResString("ch1"), for: .normal)
        proportionalOutputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
        proportionalOutputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 1), forState: .highlighted)
        proportionalOutputButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        let stackView7 = UIStackView(arrangedSubviews: [proportionalOutputLabel, proportionalOutputButton])
        stackView7.translatesAutoresizingMaskIntoConstraints = false
        stackView7.axis = .vertical
        stackView7.spacing = 10
        
        signalInputModeLabel = UILabel(frame: .zero)
        signalInputModeLabel.translatesAutoresizingMaskIntoConstraints = false
        signalInputModeLabel.text = getResString("control_mode_config_signal_input_mode1")
        
        signalInputModeSwitch = UISwitch(frame: .zero)
        signalInputModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        signalInputModeSwitch.addTarget(self, action: #selector(switchChange(_:)), for: .touchUpInside)
        
        signalInputModeImageView = UIImageView()
        signalInputModeImageView.translatesAutoresizingMaskIntoConstraints = false
        signalInputModeImageView.contentMode = .scaleAspectFit
        signalInputModeImageView.image = UIImage(named: "ch1")
        
        let stackView8 = UIStackView(arrangedSubviews: [signalInputModeLabel, signalInputModeSwitch, signalInputModeImageView])
        stackView8.translatesAutoresizingMaskIntoConstraints = false
        stackView8.spacing = 10
        stackView8.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        stackView8.isLayoutMarginsRelativeArrangement = true
        
        let inputConfigImageView = UIImageView(frame: .zero)
        inputConfigImageView.translatesAutoresizingMaskIntoConstraints = false
        inputConfigImageView.contentMode = .scaleAspectFit
        inputConfigImageView.image = UIImage(named: "input_mode")
        inputConfigImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let inputConfigLabel = UILabel(frame: .zero)
        inputConfigLabel.translatesAutoresizingMaskIntoConstraints = false
        inputConfigLabel.text = getResString("control_mode_config_input_config")
        inputConfigLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        inputModeConfigTextField = UITextField(frame: .zero)
        inputModeConfigTextField.translatesAutoresizingMaskIntoConstraints = false
        inputModeConfigTextField.setLeftPadding(10)
        inputModeConfigTextField.layer.cornerRadius = 5
        inputModeConfigTextField.layer.masksToBounds = true
        inputModeConfigTextField.backgroundColor = .white
        inputModeConfigTextField.inputAccessoryView = inputConfigModePickerView.toolbar
        inputModeConfigTextField.inputView = inputConfigModePickerView
        inputModeConfigTextField.placeholder = getResString("config_placeholder")
        inputModeConfigTextField.delegate = self
        
        let stackView9 = UIStackView(arrangedSubviews: [inputConfigImageView, inputConfigLabel, inputModeConfigTextField])
        stackView9.translatesAutoresizingMaskIntoConstraints = false
        stackView9.axis = .horizontal
        stackView9.spacing = 10
        
        let outputConfigImageView = UIImageView(frame: .zero)
        outputConfigImageView.translatesAutoresizingMaskIntoConstraints = false
        outputConfigImageView.contentMode = .scaleAspectFit
        outputConfigImageView.image = UIImage(named: "output_mode")
        outputConfigImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let outputConfigLabel = UILabel(frame: .zero)
        outputConfigLabel.translatesAutoresizingMaskIntoConstraints = false
        outputConfigLabel.text = getResString("control_mode_config_output_config")
        outputConfigLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        outputModeConfigTextField = UITextField(frame: .zero)
        outputModeConfigTextField.translatesAutoresizingMaskIntoConstraints = false
        outputModeConfigTextField.setLeftPadding(10)
        outputModeConfigTextField.layer.cornerRadius = 5
        outputModeConfigTextField.layer.masksToBounds = true
        outputModeConfigTextField.backgroundColor = .white
        outputModeConfigTextField.inputAccessoryView = inputConfigModePickerView.toolbar
        outputModeConfigTextField.inputView = inputConfigModePickerView
        outputModeConfigTextField.placeholder = getResString("config_placeholder")
        outputModeConfigTextField.delegate = self
        
        let stackView10 = UIStackView(arrangedSubviews: [outputConfigImageView, outputConfigLabel, outputModeConfigTextField])
        stackView10.translatesAutoresizingMaskIntoConstraints = false
        stackView10.axis = .horizontal
        stackView10.spacing = 10
        
        mainStackView = UIStackView(arrangedSubviews: [ stackView2,
                                                        stackView3,
                                                        stackView5,
                                                        stackView6,
                                                        stackView7,
                                                        stackView8,
                                                        stackView9,
                                                        stackView10 ])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: screenWidth),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            
            signalInputModeImageView.heightAnchor.constraint(equalToConstant: 35),
            signalInputModeImageView.widthAnchor.constraint(equalTo: signalInputModeImageView.heightAnchor)
        ])
        
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.controlModeConfigStatus.subscribe(onNext: { status in
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
        
        viewModel.remoteControlModeSwitch.subscribe(onNext: { isOn in
            self.remoteControlModeSwitch.isOn = isOn
            self.remoteControlSwitchLabel.text = isOn ? self.getResString("config_on") : self.getResString("config_off")
        }).disposed(by: disposeBag)
        
        viewModel.remoteControlMode.subscribe(onNext: { value in
            self.remoteControlModeTextField.text = self.remoteControlModels[value]
        }).disposed(by: disposeBag)
        
        viewModel.inputSensitivity.subscribe(onNext: { value in
            self.inputSensitivitySlider.value = value * 0.1
        }).disposed(by: disposeBag)
        
        viewModel.digitalInput.subscribe(onNext: { value in
            let mode = self.viewModel.getDigitalInputMode()
            
            if mode != 0 {
                self.digitalInputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                               green: 205 / 255,
                                                                               blue: 99 / 255,
                                                                               alpha: 1), forState: .normal)
            }
            
            self.digitalInputButton.tag = mode
            self.digitalInputButton.setTitle(value, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.digitalInputEnable.subscribe(onNext: { value in
            self.digitalInputEnableButton.tag = value
            
            if value == 0 {
                self.digitalInputEnableButton.setTitle(self.getResString("config_nc"), for: .normal)
                self.digitalInputEnableButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            } else {
                self.digitalInputEnableButton.setTitle(self.getResString("config_no"), for: .normal)
                self.digitalInputEnableButton.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
        viewModel.proportionalInput.subscribe(onNext: { value in
            let mode = self.viewModel.getProportionalInputMode()
            
            if mode != 0 {
                self.proportionalInputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                                    green: 205 / 255,
                                                                                    blue: 99 / 255,
                                                                                    alpha: 1), forState: .normal)
            }
            self.proportionalInputButton.tag = mode
            self.proportionalInputButton.setTitle(value, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.proportionalOutput.subscribe(onNext: { value in
            let mode = self.viewModel.getProportionalOutputMode()
            
            if mode != 0 {
                self.proportionalOutputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                                     green: 205 / 255,
                                                                                     blue: 99 / 255,
                                                                                     alpha: 1), forState: .normal)
            }
            
            self.proportionalOutputButton.tag = mode
            self.proportionalOutputButton.setTitle(value, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.inputModeConfig.subscribe(onNext: { value in
            self.inputModeConfigTextField.text = self.inputConfigModes[value]
        }).disposed(by: disposeBag)
        
        viewModel.outputConfig.subscribe(onNext: { value in
            self.outputModeConfigTextField.text = self.inputConfigModes[value]
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case digitalInputButton:
            switch digitalInputButton.tag {
            case 0:
                digitalInputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                          green: 205 / 255,
                                                                          blue: 99 / 255,
                                                                          alpha: 1), forState: .normal)
                digitalInputButton.setTitle(getResString("ch1"), for: .normal)
                digitalInputButton.tag = 1
            case 1:
                digitalInputButton.setTitle(getResString("ch2"), for: .normal)
                digitalInputButton.tag = 2
            default:
                digitalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
                digitalInputButton.setTitle(getResString("disable"), for: .normal)
                digitalInputButton.tag = 0
            }
            viewModel.didSave(index: 4)
        case proportionalInputButton:
            switch proportionalInputButton.tag {
            case 0:
                proportionalInputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                               green: 205 / 255,
                                                                               blue: 99 / 255,
                                                                               alpha: 1), forState: .normal)
                proportionalInputButton.setTitle(getResString("ch1"), for: .normal)
                proportionalInputButton.tag = 1
            case 1:
                proportionalInputButton.setTitle(getResString("ch2"), for: .normal)
                proportionalInputButton.tag = 2
            default:
                proportionalInputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
                proportionalInputButton.setTitle(getResString("disable"), for: .normal)
                proportionalInputButton.tag = 0
            }
            viewModel.didSave(index: 5)
        case proportionalOutputButton:
            switch proportionalOutputButton.tag {
            case 0:
                proportionalOutputButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
                                                                                green: 205 / 255,
                                                                                blue: 99 / 255,
                                                                                alpha: 1), forState: .normal)
                proportionalOutputButton.setTitle(getResString("ch1"), for: .normal)
                proportionalOutputButton.tag = 1
            case 1:
                proportionalOutputButton.setTitle(getResString("ch2"), for: .normal)
                proportionalOutputButton.tag = 2
            default:
                proportionalOutputButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
                proportionalOutputButton.setTitle(getResString("disable"), for: .normal)
                proportionalOutputButton.tag = 0
            }
            viewModel.didSave(index: 6)
        default:
            let enable = sender.tag == 0 ? 1 : 0
            sender.tag = enable
            
            if enable == 0 {
                self.digitalInputEnableButton.setTitle(getResString("config_nc"), for: .normal)
                self.digitalInputEnableButton.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            } else {
                self.digitalInputEnableButton.setTitle(getResString("config_no"), for: .normal)
                self.digitalInputEnableButton.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            }
            
            viewModel.didSave(index: 3, value: String(enable))
        }
    }
    
    @objc private func switchChange(_ sender: UISwitch) {
        
        switch sender {
        case remoteControlModeSwitch:
            if sender.isOn {
                remoteControlSwitchLabel.text = getResString("config_on")
            } else {
                remoteControlSwitchLabel.text = getResString("config_off")
            }
            viewModel.didSave(index: 0, value: sender.isOn ? "1" : "0")
        default:
            if !sender.isOn {
                signalInputModeLabel.text = getResString("control_mode_config_signal_input_mode1")
                signalInputModeImageView.image = getResImage("ch1")
            } else {
                signalInputModeLabel.text = getResString("control_mode_config_signal_input_mode2")
                signalInputModeImageView.image = getResImage("ch2")
            }
            viewModel.didChangeChannel()
        }
        
    }
    
    @objc private func sliderChangeEnd(_ sender: UISlider) {
        
        if sender == inputSensitivitySlider {
            print(sender.value)
            viewModel.didSave(index: 2, value: String(Int(lroundf(sender.value * 10))))
        }
    }
}

// MARK: - Delegate

extension ControlModeConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        switch pickerView {
        case remoteControlModePickerView:
            remoteControlModeTextField.text = remoteControlModels[pickerIndex]
            remoteControlModel = pickerIndex
            viewModel.didSave(index: 1, value: String(remoteControlModel))
        default:
            beginTextField.text = inputConfigModes[pickerIndex]
            inputConfigMode = pickerIndex
            
            if beginTextField == inputModeConfigTextField {
                viewModel.didSave(index: 7, value: String(inputConfigMode))
            } else {
                viewModel.didSave(index: 8, value: String(inputConfigMode))
            }
        }
        
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension ControlModeConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
    }
}

extension ControlModeConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case remoteControlModePickerView:
            return remoteControlModels.count
        default:
            return inputConfigModes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case remoteControlModePickerView:
            return remoteControlModels[row]
        default:
            return inputConfigModes[row]
        }
    }
}

extension ControlModeConfigViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerIndex = 0
        self.remoteControlModePickerView.selectRow(0, inComponent: 0, animated: true)
        self.inputConfigModePickerView.selectRow(0, inComponent: 0, animated: true)
        self.beginTextField = textField
    }
}

extension ControlModeConfigViewController {
    
    func setNSNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = .zero
    }
}
