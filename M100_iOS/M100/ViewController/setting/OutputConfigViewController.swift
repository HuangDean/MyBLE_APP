import UIKit

final class OutputConfigViewController: BaseViewController {
    
    private var centerSwitch: UISwitch!
    private var centerImageView: UIImageView!
    
    private var scrollView: UIScrollView!
    private var outputSPickerView1: SubmitPickerView!
    private var outputSPickerView2: SubmitPickerView!
    private var outputSPickerView3: SubmitPickerView!
    private var outputSPickerView4: SubmitPickerView!
//    private var digitalOutputChannelButton: UIButton!
    
    private var endEditingTextField: UITextField!
    private let outputConfigModes: Array<String> = [NSLocalizedString("output_config_output_config_mode_1", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_2", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_3", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_4", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_5", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_6", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_7", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_8", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_9", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_10", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_11", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_12", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_13", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_14", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_15", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_16", comment: ""),
                                                    NSLocalizedString("output_config_output_config_mode_17", comment: "")]
    private var outputConfigMode: Int = 0
    private lazy var outputConfigModePickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    private lazy var viewModel: OutputConfigViewModel = { OutputConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        setNSNotificationCenter()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("output_config_title"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: makeNavigationRightView())
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        outputSPickerView1 = SubmitPickerView(frame: .zero)
        outputSPickerView1.translatesAutoresizingMaskIntoConstraints = false
        outputSPickerView1.titleLabel.text = getResString("output_config_output")
        outputSPickerView1.titleImageView.image = UIImage(named: "output_1")
        outputSPickerView1.button.setTitle(getResString("config_nc"), for: .normal)
        outputSPickerView1.textField.inputView = outputConfigModePickerView
        outputSPickerView1.textField.inputAccessoryView = outputConfigModePickerView.toolbar
        outputSPickerView1.textField.delegate = self
        outputSPickerView1.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        outputSPickerView2 = SubmitPickerView(frame: .zero)
        outputSPickerView2.translatesAutoresizingMaskIntoConstraints = false
        outputSPickerView2.titleLabel.text = getResString("output_config_output")
        outputSPickerView2.titleImageView.image = UIImage(named: "output_2")
        outputSPickerView2.button.setTitle(getResString("config_nc"), for: .normal)
        outputSPickerView2.textField.inputView = outputConfigModePickerView
        outputSPickerView2.textField.inputAccessoryView = outputConfigModePickerView.toolbar
        outputSPickerView2.textField.delegate = self
        outputSPickerView2.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        outputSPickerView3 = SubmitPickerView(frame: .zero)
        outputSPickerView3.translatesAutoresizingMaskIntoConstraints = false
        outputSPickerView3.titleLabel.text = getResString("output_config_output")
        outputSPickerView3.titleImageView.image = UIImage(named: "output_3")
        outputSPickerView3.button.setTitle(getResString("config_nc"), for: .normal)
        outputSPickerView3.textField.inputView = outputConfigModePickerView
        outputSPickerView3.textField.inputAccessoryView = outputConfigModePickerView.toolbar
        outputSPickerView3.textField.delegate = self
        outputSPickerView3.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        outputSPickerView4 = SubmitPickerView(frame: .zero)
        outputSPickerView4.translatesAutoresizingMaskIntoConstraints = false
        outputSPickerView4.titleLabel.text = getResString("output_config_output")
        outputSPickerView4.titleImageView.image = UIImage(named: "output_4")
        outputSPickerView4.button.setTitle(getResString("config_nc"), for: .normal)
        outputSPickerView4.textField.inputView = outputConfigModePickerView
        outputSPickerView4.textField.inputAccessoryView = outputConfigModePickerView.toolbar
        outputSPickerView4.textField.delegate = self
        outputSPickerView4.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
//        let digitalOutputChannelLabel = UILabel(frame: .zero)
//        digitalOutputChannelLabel.translatesAutoresizingMaskIntoConstraints = false
//        digitalOutputChannelLabel.text = getResString("output_config_digital_output_channel")
        
//        digitalOutputChannelButton = UIButton(frame: .zero)
//        digitalOutputChannelButton.translatesAutoresizingMaskIntoConstraints = false
//        digitalOutputChannelButton.layer.cornerRadius = 10
//        digitalOutputChannelButton.layer.masksToBounds = true
//        digitalOutputChannelButton.layer.borderColor = UIColor.black.cgColor
//        digitalOutputChannelButton.layer.borderWidth = 1
//        digitalOutputChannelButton.setTitle("DISABLE", for: .normal)
//        digitalOutputChannelButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
//        digitalOutputChannelButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 1), forState: .highlighted)
//        digitalOutputChannelButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
//        let stackView1 = UIStackView(arrangedSubviews: [ digitalOutputChannelLabel, digitalOutputChannelButton])
//        stackView1.translatesAutoresizingMaskIntoConstraints = false
//        stackView1.axis = .horizontal
        
        let mainStackView = UIStackView(arrangedSubviews: [ outputSPickerView1, outputSPickerView2, outputSPickerView3, outputSPickerView4])
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
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            
//            digitalOutputChannelButton.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor, multiplier: 0.32),
//            digitalOutputChannelButton.heightAnchor.constraint(equalTo: digitalOutputChannelButton.widthAnchor, multiplier: 0.4)
        ])
        
    }
    
    private func makeNavigationRightView() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        
        centerSwitch = UISwitch(frame: .zero)
        centerSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerSwitch)
        centerSwitch.addTarget(self, action: #selector(switchChange(_:)), for: .touchUpInside)
        
        centerImageView = UIImageView(frame: .zero)
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerImageView)
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.image = UIImage(named: "ch1")
        
        NSLayoutConstraint.activate([
            centerSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            centerSwitch.trailingAnchor.constraint(equalTo: centerImageView.leadingAnchor, constant: -15),
            centerSwitch.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            centerSwitch.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            centerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            centerImageView.centerYAnchor.constraint(equalTo: centerSwitch.centerYAnchor),
            centerImageView.heightAnchor.constraint(equalToConstant: 35),
            centerImageView.widthAnchor.constraint(equalTo: centerImageView.heightAnchor)
        ])
        
        return view
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.outputConfigStatus.subscribe(onNext: { status in
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
        
        viewModel.output1.subscribe(onNext: { value in
            self.outputSPickerView1.textField.text = self.outputConfigModes[value]
        }).disposed(by: disposeBag)
        
        viewModel.output2.subscribe(onNext: { value in
            self.outputSPickerView2.textField.text = self.outputConfigModes[value]
        }).disposed(by: disposeBag)
        
        viewModel.output3.subscribe(onNext: { value in
            self.outputSPickerView3.textField.text = self.outputConfigModes[value]
        }).disposed(by: disposeBag)
        
        viewModel.output4.subscribe(onNext: { value in
            self.outputSPickerView4.textField.text = self.outputConfigModes[value]
        }).disposed(by: disposeBag)
        
        viewModel.output1Status.subscribe(onNext: { isOn in
            if isOn {
                self.outputSPickerView1.button.setTitle(self.getResString("config_no"), for: .normal)
                self.outputSPickerView1.button.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            } else {
                self.outputSPickerView1.button.setTitle(self.getResString("config_nc"), for: .normal)
                self.outputSPickerView1.button.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output2Status.subscribe(onNext: { isOn in
            if isOn {
                self.outputSPickerView2.button.setTitle(self.getResString("config_no"), for: .normal)
                self.outputSPickerView2.button.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            } else {
                self.outputSPickerView2.button.setTitle(self.getResString("config_nc"), for: .normal)
                self.outputSPickerView2.button.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output3Status.subscribe(onNext: { isOn in
            if isOn {
                self.outputSPickerView3.button.setTitle(self.getResString("config_no"), for: .normal)
                self.outputSPickerView3.button.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            } else {
                self.outputSPickerView3.button.setTitle(self.getResString("config_nc"), for: .normal)
                self.outputSPickerView3.button.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output4Status.subscribe(onNext: { isOn in
            if isOn {
                self.outputSPickerView4.button.setTitle(self.getResString("config_no"), for: .normal)
                self.outputSPickerView4.button.setImage(UIImage(named: "checkbox_enable"), for: .normal)
            } else {
                self.outputSPickerView4.button.setTitle(self.getResString("config_nc"), for: .normal)
                self.outputSPickerView4.button.setImage(UIImage(named: "checkbox_normal"), for: .normal)
            }
        }).disposed(by: disposeBag)
        
//        viewModel.digitalOutputChannel.subscribe(onNext: { value in
//            switch self.viewModel.getOutputChannelMode() {
//            case 0:
//                self.digitalOutputChannelButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .normal)
//            default:
//                self.digitalOutputChannelButton.setBackgroundColor(color: UIColor.init(red: 160 / 255,
//                                                                                       green: 205 / 255,
//                                                                                       blue: 99 / 255,
//                                                                                       alpha: 1), forState: .normal)
//            }
//
//            self.digitalOutputChannelButton.setTitle(value, for: .normal)
//        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case outputSPickerView1.button:
            viewModel.didSave(index: 1)
        case outputSPickerView2.button:
            viewModel.didSave(index: 3)
        case outputSPickerView3.button:
            viewModel.didSave(index: 5)
        case outputSPickerView4.button:
            viewModel.didSave(index: 7)
        default:
            break
            //viewModel.didSave(index: 0)
        }
    }
    
    @objc private func switchChange(_ sender: UISwitch) {
        viewModel.didChangeChannel()
        
        if sender.isOn {
            centerImageView.image = UIImage(named: "ch2")
        } else {
            centerImageView.image = UIImage(named: "ch1")
        }
    }
    
}


// MARK: - Delegate

extension OutputConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        self.endEditingTextField.text = outputConfigModes[outputConfigMode]
        
        switch endEditingTextField {
        case outputSPickerView1.textField:
            viewModel.didSave(index: 2, value: String(outputConfigMode))
        case outputSPickerView2.textField:
            viewModel.didSave(index: 4, value: String(outputConfigMode))
        case outputSPickerView3.textField:
            viewModel.didSave(index: 6, value: String(outputConfigMode))
        case outputSPickerView4.textField:
            viewModel.didSave(index: 8, value: String(outputConfigMode))
        default:
            break
        }
        
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension OutputConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        outputConfigMode = row
    }
}

extension OutputConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return outputConfigModes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return outputConfigModes[row]
    }
}

extension OutputConfigViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditingTextField = textField
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.outputConfigMode = 0
        self.outputConfigModePickerView.selectRow(0, inComponent: 0, animated: true)
        self.endEditingTextField = textField
    }

}

extension OutputConfigViewController {
    
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
