import UIKit

final class SwitchConfigViewController: BaseViewController {
    
    private var centerSwitch: UISwitch!
    private var centerLabel: UILabel!
    
    private var scrollView: UIScrollView!
    
    private var valveCloseImageView: UIImageView!
    private var rangeOfEndTorqueOffLabel: UILabel!
    private var rangeOfEndTorqueOnLabel: UILabel!
    private var switchProgressView: SwitchProgressView!
    
    private var outputRpmSlider: CustomSlider!
    private var ungentRpmSlider: CustomSlider!
    private var rangeOfEndSlider: CustomSlider!
    
    private var limitTextField: UITextField!
    private var torqueRetryTextField: UITextField!
    private var rangeOfEndModeTextField: UITextField!
    private var rangeOfEndTorqueTextField: UITextField!
    private var strokeTorqueTextField: UITextField!
    
    private var switchTitleLabel: UILabel!
    private var closeTightlySwitch: UISwitch!
    private var closeDefinitionTextField: UITextField!
    
    private let retrys: Array<String> = Array(arrayLiteral: "0", "1", "2", "3", "4", "5")
    private var retry: Int = 0
    private lazy var retryPickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    
    private let rangeOfEndModes: Array<String> = Array(arrayLiteral: NSLocalizedString("switch_config_range_of_end_mode1", comment: ""),
                                                       NSLocalizedString("switch_config_range_of_end_mode2", comment: ""))
    private var rangeOfEndMode: Int = 0
    private lazy var rangeOfEndModePickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    private let closeTorques: Array<String> = Array(arrayLiteral: "30", "40", "50", "60", "70", "80", "90", "100")
    private var closeTorque: Int = 0
    private lazy var closeTorquePickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    private let closeDefinitions: Array<String> = Array(arrayLiteral: "CCW", "CW")
    private var closeDefinition: Int = 0
    private lazy var closeDefinitionPickerView: UIToolbarPickerView = {
        let toolbarPickerView = UIToolbarPickerView()
        toolbarPickerView.dataSource = self
        toolbarPickerView.delegate = self
        toolbarPickerView.toolbarDelegate = self
        return toolbarPickerView
    }()
    
    private var pickerIndex: Int = 0
    private var beginTextField: UITextField!
    
    private lazy var viewModel: SwitchConfigViewModel = { SwitchConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        setNSNotificationCenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(self.view.frame.width - 60 - valveCloseImageView.frame.width * 2)
        switchProgressView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 60 - valveCloseImageView.frame.width * 2).isActive = true
        switchProgressView.heightAnchor.constraint(equalToConstant: valveCloseImageView.frame.height).isActive = true
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        
        setBackButton(imgNamed: "back", title: getResString("switch_config_title"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: makeNavigationRightView())
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        valveCloseImageView = UIImageView(frame: .zero)
        valveCloseImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(valveCloseImageView)
        valveCloseImageView.image = UIImage(named: "valve_close")
        valveCloseImageView.contentMode = .scaleAspectFit
        
        let valveOpenImageView = UIImageView(frame: .zero)
        valveOpenImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(valveOpenImageView)
        valveOpenImageView.image = UIImage(named: "valve_open")
        valveOpenImageView.contentMode = .scaleAspectFit
        
        switchProgressView = SwitchProgressView(frame: .zero)
        switchProgressView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(switchProgressView)
        switchProgressView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let outputRpmLabel = UILabel(frame: .zero)
        outputRpmLabel.translatesAutoresizingMaskIntoConstraints = false
        outputRpmLabel.text = getResString("switch_config_output_rpm")
        
        let ungentRpmLabel = UILabel(frame: .zero)
        ungentRpmLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ungentRpmLabel)
        ungentRpmLabel.text = getResString("switch_config_ungent_rpm")
        
        let rangeOfEndLabel = UILabel(frame: .zero)
        rangeOfEndLabel.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndLabel.text = getResString("switch_config_range_of_end")
        
        let stackView2 = UIStackView(arrangedSubviews: [outputRpmLabel, ungentRpmLabel, rangeOfEndLabel])
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        stackView2.axis = .vertical
        stackView2.distribution = .fillEqually
        
        outputRpmSlider = CustomSlider(frame: .zero, isInt: true)
        outputRpmSlider.translatesAutoresizingMaskIntoConstraints = false
        outputRpmSlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        outputRpmSlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        outputRpmSlider.value = 0
        outputRpmSlider.minimumValue = 0
        outputRpmSlider.maximumValue = 4
        outputRpmSlider.isContinuous = false
        outputRpmSlider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        
        ungentRpmSlider = CustomSlider(frame: .zero, isInt: true)
        ungentRpmSlider.translatesAutoresizingMaskIntoConstraints = false
        ungentRpmSlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        ungentRpmSlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        ungentRpmSlider.minimumValue = 0
        ungentRpmSlider.maximumValue = 4
        ungentRpmSlider.value = 0
        ungentRpmSlider.isContinuous = false
        ungentRpmSlider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        
        rangeOfEndSlider = CustomSlider(frame: .zero, isInt: true)
        rangeOfEndSlider.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndSlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        rangeOfEndSlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        rangeOfEndSlider.value = 2
        rangeOfEndSlider.minimumValue = 2
        rangeOfEndSlider.maximumValue = 20
        rangeOfEndSlider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        rangeOfEndSlider.addTarget(self, action: #selector(sliderChangeEnd(_:)), for: .touchUpInside)
        
        rangeOfEndTorqueOffLabel = UILabel(frame: .zero)
        rangeOfEndTorqueOffLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(rangeOfEndTorqueOffLabel)
        
        rangeOfEndTorqueOnLabel = UILabel(frame: .zero)
        rangeOfEndTorqueOnLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(rangeOfEndTorqueOnLabel)
        
        let stackView3 = UIStackView(arrangedSubviews: [outputRpmSlider, ungentRpmSlider, rangeOfEndSlider])
        stackView3.translatesAutoresizingMaskIntoConstraints = false
        stackView3.axis = .vertical
        stackView3.distribution = .fillEqually
        stackView3.spacing = 20
        stackView3.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        stackView3.isLayoutMarginsRelativeArrangement = true
        
        let stackView4 = UIStackView(arrangedSubviews: [stackView2, stackView3])
        stackView4.translatesAutoresizingMaskIntoConstraints = false
        stackView4.axis = .horizontal
        stackView4.spacing = 20
        
        let limitLabel = UILabel(frame: .zero)
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        limitLabel.text = getResString("switch_config_limit")
        
        let torqueRetryLabel = UILabel(frame: .zero)
        torqueRetryLabel.translatesAutoresizingMaskIntoConstraints = false
        torqueRetryLabel.text = getResString("switch_config_torque_retry")
        torqueRetryLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let rangeOfEndModeLabel = UILabel(frame: .zero)
        rangeOfEndModeLabel.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndModeLabel.text = getResString("switch_config_range_of_end_mode")
        
        let rangeOfEndTorqueLabel = UILabel(frame: .zero)
        rangeOfEndTorqueLabel.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndTorqueLabel.text = getResString("switch_config_range_of_end_torque")
        
        let strokeTorqueLabel = UILabel(frame: .zero)
        strokeTorqueLabel.translatesAutoresizingMaskIntoConstraints = false
        strokeTorqueLabel.text = getResString("switch_config_stroke_torque")
        
        let stackView5 = UIStackView(arrangedSubviews: [limitLabel, torqueRetryLabel, rangeOfEndModeLabel, rangeOfEndTorqueLabel, strokeTorqueLabel])
        stackView5.translatesAutoresizingMaskIntoConstraints = false
        stackView5.axis = .vertical
        stackView5.distribution = .equalSpacing
        stackView5.spacing = 40
        stackView5.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        stackView5.isLayoutMarginsRelativeArrangement = true
        
        limitTextField = UITextField(frame: .zero)
        limitTextField.translatesAutoresizingMaskIntoConstraints = false
        limitTextField.setLeftPadding(10)
        limitTextField.isEnabled = false
        limitTextField.layer.cornerRadius = 5
        limitTextField.layer.masksToBounds = true
        limitTextField.backgroundColor = UIColor.init(named: "theme")
        
        torqueRetryTextField = UITextField(frame: .zero)
        torqueRetryTextField.translatesAutoresizingMaskIntoConstraints = false
        torqueRetryTextField.setLeftPadding(10)
        torqueRetryTextField.layer.cornerRadius = 5
        torqueRetryTextField.layer.masksToBounds = true
        torqueRetryTextField.backgroundColor = .white
        torqueRetryTextField.inputAccessoryView = retryPickerView.toolbar
        torqueRetryTextField.inputView = retryPickerView
        torqueRetryTextField.placeholder = getResString("config_placeholder")
        
        rangeOfEndModeTextField = UITextField(frame: .zero)
        rangeOfEndModeTextField.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndModeTextField.setLeftPadding(10)
        rangeOfEndModeTextField.layer.cornerRadius = 5
        rangeOfEndModeTextField.layer.masksToBounds = true
        rangeOfEndModeTextField.backgroundColor = .white
        rangeOfEndModeTextField.inputAccessoryView = rangeOfEndModePickerView.toolbar
        rangeOfEndModeTextField.inputView = rangeOfEndModePickerView
        rangeOfEndModeTextField.placeholder = getResString("config_placeholder")
        
        rangeOfEndTorqueTextField = UITextField(frame: .zero)
        rangeOfEndTorqueTextField.translatesAutoresizingMaskIntoConstraints = false
        rangeOfEndTorqueTextField.setLeftPadding(10)
        rangeOfEndTorqueTextField.layer.cornerRadius = 5
        rangeOfEndTorqueTextField.layer.masksToBounds = true
        rangeOfEndTorqueTextField.backgroundColor = .white
        rangeOfEndTorqueTextField.inputAccessoryView = closeTorquePickerView.toolbar
        rangeOfEndTorqueTextField.inputView = closeTorquePickerView
        rangeOfEndTorqueTextField.placeholder = getResString("config_placeholder")
        rangeOfEndTorqueTextField.delegate = self
        
        strokeTorqueTextField = UITextField(frame: .zero)
        strokeTorqueTextField.translatesAutoresizingMaskIntoConstraints = false
        strokeTorqueTextField.setLeftPadding(10)
        strokeTorqueTextField.layer.cornerRadius = 5
        strokeTorqueTextField.layer.masksToBounds = true
        strokeTorqueTextField.backgroundColor = .white
        strokeTorqueTextField.inputAccessoryView = closeTorquePickerView.toolbar
        strokeTorqueTextField.inputView = closeTorquePickerView
        strokeTorqueTextField.placeholder = getResString("config_placeholder")
        strokeTorqueTextField.delegate = self
        
        let stackView6 = UIStackView(arrangedSubviews: [limitTextField,
                                                        torqueRetryTextField,
                                                        rangeOfEndModeTextField,
                                                        rangeOfEndTorqueTextField,
                                                        strokeTorqueTextField])
        stackView6.translatesAutoresizingMaskIntoConstraints = false
        stackView6.axis = .vertical
        stackView6.distribution = .fillEqually
        stackView6.spacing = 20
        
        let stackView7 = UIStackView(arrangedSubviews: [stackView5, stackView6])
        stackView7.translatesAutoresizingMaskIntoConstraints = false
        stackView7.axis = .horizontal
        stackView7.spacing = 20
        
        let divderView = UIView(frame: .zero)
        divderView.translatesAutoresizingMaskIntoConstraints = false
        divderView.layer.cornerRadius = 2
        divderView.layer.masksToBounds = true
        divderView.backgroundColor = .white
        
        let closeTightlyLabel = UILabel(frame: .zero)
        closeTightlyLabel.translatesAutoresizingMaskIntoConstraints = false
        closeTightlyLabel.text = getResString("switch_config_close_tightly")
        
        switchTitleLabel = UILabel(frame: .zero)
        switchTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchTitleLabel.textColor = .darkText
        switchTitleLabel.text = getResString("config_off")
        
        closeTightlySwitch = UISwitch(frame: .zero)
        closeTightlySwitch.translatesAutoresizingMaskIntoConstraints = false
        closeTightlySwitch.addTarget(self, action: #selector(switchChange(_:)), for: .touchUpInside)
        
        let stackView8 = UIStackView(arrangedSubviews: [closeTightlyLabel, switchTitleLabel, closeTightlySwitch])
        stackView8.translatesAutoresizingMaskIntoConstraints = false
        stackView8.axis = .horizontal
        stackView8.spacing = 10
        
        let closeDefinitionLabel = UILabel(frame: .zero)
        closeDefinitionLabel.translatesAutoresizingMaskIntoConstraints = false
        closeDefinitionLabel.text = getResString("switch_config_close_definition")
        closeDefinitionLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        closeDefinitionTextField = UITextField(frame: .zero)
        closeDefinitionTextField.translatesAutoresizingMaskIntoConstraints = false
        closeDefinitionTextField.setLeftPadding(10)
        closeDefinitionTextField.layer.cornerRadius = 5
        closeDefinitionTextField.layer.masksToBounds = true
        closeDefinitionTextField.backgroundColor = .white
        closeDefinitionTextField.inputAccessoryView = closeDefinitionPickerView.toolbar
        closeDefinitionTextField.inputView = closeDefinitionPickerView
        closeDefinitionTextField.placeholder = getResString("config_placeholder")
        
        let stackView9 = UIStackView(arrangedSubviews: [closeDefinitionLabel, closeDefinitionTextField])
        stackView9.translatesAutoresizingMaskIntoConstraints = false
        stackView9.axis = .horizontal
        stackView9.spacing = 30
        
        let mainStackView = UIStackView(arrangedSubviews: [stackView4, stackView7, divderView, stackView8, stackView9])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.spacing = 20
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: screenWidth),
            
            valveCloseImageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            valveCloseImageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            valveCloseImageView.widthAnchor.constraint(equalToConstant: 68),
            valveCloseImageView.heightAnchor.constraint(equalToConstant: 66),
            
            switchProgressView.leadingAnchor.constraint(equalTo: valveCloseImageView.trailingAnchor, constant: 10),
            switchProgressView.trailingAnchor.constraint(equalTo: valveOpenImageView.leadingAnchor, constant: -10),
            switchProgressView.topAnchor.constraint(equalTo: valveCloseImageView.topAnchor, constant: 10),
            switchProgressView.bottomAnchor.constraint(equalTo: valveCloseImageView.bottomAnchor, constant: -10),
                        
            valveOpenImageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            valveOpenImageView.widthAnchor.constraint(equalTo: valveCloseImageView.widthAnchor),
            valveOpenImageView.heightAnchor.constraint(equalTo: valveCloseImageView.heightAnchor),
            valveOpenImageView.centerYAnchor.constraint(equalTo: valveCloseImageView.centerYAnchor),
            
            rangeOfEndTorqueOffLabel.leadingAnchor.constraint(equalTo: switchProgressView.leadingAnchor),
            rangeOfEndTorqueOffLabel.bottomAnchor.constraint(equalTo: switchProgressView.topAnchor),
            
            rangeOfEndTorqueOnLabel.trailingAnchor.constraint(equalTo: switchProgressView.trailingAnchor),
            rangeOfEndTorqueOnLabel.bottomAnchor.constraint(equalTo: switchProgressView.topAnchor),
            
            divderView.heightAnchor.constraint(equalToConstant: 2),
            closeDefinitionTextField.heightAnchor.constraint(equalToConstant: 38),
            
            mainStackView.topAnchor.constraint(equalTo: valveCloseImageView.bottomAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
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
        
        centerLabel = UILabel(frame: .zero)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLabel)
        centerLabel.textColor = .darkText
        centerLabel.text = getResString("switch_config_close")
        
        NSLayoutConstraint.activate([
            centerSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            centerSwitch.trailingAnchor.constraint(equalTo: centerLabel.leadingAnchor, constant: -15),
            centerSwitch.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor),
            
            centerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            centerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            centerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
        
        return view
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.switchConfigStatus.subscribe(onNext: { status in
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
        
        viewModel.outputRpm.subscribe(onNext: { value in
            self.outputRpmSlider.value = value
        }).disposed(by: disposeBag)
        
        viewModel.ungentRpm.subscribe(onNext: { value in
            self.ungentRpmSlider.value = value
        }).disposed(by: disposeBag)
        
        viewModel.rangeOfEndOff.subscribe(onNext: { value in
            self.switchProgressView.setMinValue(minValue: String(Int(value)))
            
            if !self.viewModel.isOpen() {
                self.rangeOfEndSlider.value = value
            }
        }).disposed(by: disposeBag)
        
        viewModel.rangeOfEndOn.subscribe(onNext: { value in
            self.switchProgressView.setMaxValue(maxValue: String(Int(value)))
            
            if self.viewModel.isOpen() {
                self.rangeOfEndSlider.value = value
            }
        }).disposed(by: disposeBag)
        
        viewModel.limit.subscribe(onNext: { value in
            self.limitTextField.text = String(format: "%.5f", value)
        }).disposed(by: disposeBag)
        
        viewModel.torqueRetry.subscribe(onNext: { value in
            self.torqueRetryTextField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.rangeOfEndMode.subscribe(onNext: { value in
            self.rangeOfEndModeTextField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.rangeOfEndTorqueOff.subscribe(onNext: { value in
            self.rangeOfEndTorqueOffLabel.text = "\(String(describing: Int(value) ?? 0))%"
            
            if !self.viewModel.isOpen() {
                self.rangeOfEndTorqueTextField.text = "\(value)%"
            }
        }).disposed(by: disposeBag)
        
        viewModel.strokeTorqueOff.subscribe(onNext: { value in
            self.switchProgressView.setCloseLabel(value: value)
            
            if !self.viewModel.isOpen() {
                self.strokeTorqueTextField.text = "\(value)%"
            }
        }).disposed(by: disposeBag)
        
        viewModel.rangeOfEndTorqueOn.subscribe(onNext: { value in
            self.rangeOfEndTorqueOnLabel.text = "\(String(describing: Int(value) ?? 0))%"
            
            if self.viewModel.isOpen() {
                self.rangeOfEndTorqueTextField.text = "\(value)%"
            }
        }).disposed(by: disposeBag)
        
        viewModel.strokeTorqueOn.subscribe(onNext: { value in
            self.switchProgressView.setOpenLabel(value: value)
            
            if self.viewModel.isOpen() {
                self.strokeTorqueTextField.text = "\(value)%"
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.closeTightly.subscribe(onNext: { value in
            if value == 0 {
                self.closeTightlySwitch.isOn = false
                self.switchTitleLabel.text = self.getResString("config_off")
            } else {
                self.closeTightlySwitch.isOn = true
                self.switchTitleLabel.text = self.getResString("config_on")
            }
        }).disposed(by: disposeBag)
        
        viewModel.closeDefinition.subscribe(onNext: { value in
            self.closeDefinitionTextField.text = value
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func switchChange(_ sender: UISwitch) {
        switch sender {
        case centerSwitch:
            if sender.isOn {
                rangeOfEndSlider.minimumValue = 80
                rangeOfEndSlider.maximumValue = 98
                centerLabel.text = getResString("switch_config_open")
            } else {
                rangeOfEndSlider.minimumValue = 2
                rangeOfEndSlider.maximumValue = 20
                centerLabel.text = getResString("switch_config_close")
            }
            
            viewModel.didCenterSwitch()
        default:
            if sender.isOn {
                switchTitleLabel.text = getResString("config_on")
            } else {
                switchTitleLabel.text = getResString("config_off")
            }
            viewModel.didSave(index: 8, value: sender.isOn ? "1" : "0" )
        }
    }
    
    @objc private func sliderChange(_ sender: UISlider) {
        
        sender.setValue(sender.value.rounded(.down), animated: false)
        
        switch sender {
        case outputRpmSlider:
            viewModel.didSave(index: 0, value: String(Int(sender.value)))
        case ungentRpmSlider:
            viewModel.didSave(index: 1, value: String(Int(sender.value)))
        default:
            if !viewModel.isOpen() {
                self.switchProgressView.setMinValue(minValue: String(Int(sender.value)))
            } else {
                self.switchProgressView.setMaxValue(maxValue: String(Int(sender.value)))
            }
        }

    }
    
    @objc private func sliderChangeEnd(_ sender: UISlider) {
        if sender == rangeOfEndSlider {
            viewModel.didSave(index: 2, value: String(Int(sender.value)))
        }
    }
}

// MARK: - Delegate

extension SwitchConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        switch pickerView {
        case retryPickerView:
            torqueRetryTextField.text = retrys[pickerIndex]
            retry = pickerIndex
            viewModel.didSave(index: 4, value: String(retry))
        case rangeOfEndModePickerView:
            rangeOfEndModeTextField.text = rangeOfEndModes[pickerIndex]
            rangeOfEndMode = pickerIndex
            viewModel.didSave(index: 5, value: String(rangeOfEndMode))
        case closeDefinitionPickerView:
            closeDefinitionTextField.text = closeDefinitions[pickerIndex]
            closeDefinition = pickerIndex
            viewModel.didSave(index: 9, value: String(closeDefinition))
        default:
            beginTextField.text = "\(closeTorques[pickerIndex])%"
            closeTorque = pickerIndex
            
            if self.beginTextField == rangeOfEndTorqueTextField {
                if !viewModel.isOpen() {
                    self.rangeOfEndTorqueOffLabel.text = "\(closeTorques[pickerIndex])%"
                } else {
                    self.rangeOfEndTorqueOnLabel.text = "\(closeTorques[pickerIndex])%"
                }
                
                viewModel.didSave(index: 6, value: String(closeTorques[pickerIndex]))
            } else {
                if !viewModel.isOpen() {
                    switchProgressView.setCloseLabel(value: closeTorques[pickerIndex])
                } else {
                    switchProgressView.setOpenLabel(value: closeTorques[pickerIndex])
                }
                    
                viewModel.didSave(index: 7, value: String(closeTorques[pickerIndex]))
            }
        }
        
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

// MARK: - Delegate

extension SwitchConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
    }
}

extension SwitchConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case retryPickerView:
            return retrys.count
        case rangeOfEndModePickerView:
            return rangeOfEndModes.count
        case closeTorquePickerView:
            return closeTorques.count
        default:
            return closeDefinitions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case retryPickerView:
            return retrys[row]
        case rangeOfEndModePickerView:
            return rangeOfEndModes[row]
        case closeTorquePickerView:
            return "\(closeTorques[row])%"
        default:
            return closeDefinitions[row]
        }
    }
}

extension SwitchConfigViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerIndex = 0
        self.retryPickerView.selectRow(0, inComponent: 0, animated: true)
        self.rangeOfEndModePickerView.selectRow(0, inComponent: 0, animated: true)
        self.closeTorquePickerView.selectRow(0, inComponent: 0, animated: true)
        self.closeDefinitionPickerView.selectRow(0, inComponent: 0, animated: true)
        self.beginTextField = textField
    }
    
}

extension SwitchConfigViewController {
    
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
