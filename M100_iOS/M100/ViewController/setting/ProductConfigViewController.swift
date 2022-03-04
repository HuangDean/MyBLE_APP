import UIKit

final class ProductConfigViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    
    private var modbusIdTextField: SubmitTextField!
    private var baundRateTextField: SubmitTextField!
    private var gearTextField: SubmitTextField!
    private var profibusAddressTextField: SubmitTextField!
    private var oemTypeTextField: SubmitTextField!
    private var oemSerialTextField: SubmitTextField!
    private var dealerTypeTextField: SubmitTextField!
    private var dealerSerialTextField: SubmitTextField!
    private var stackView: UIStackView!
    
    private var detectTitleUILabel: UILabel!
    private var detectBoardAIView: DetectBoardView!
    private var detectBoardDIView: DetectBoardView!
    private var detectBoardModbusView: DetectBoardView!
    private var detectBoardHartView: DetectBoardView!
    private var detectBoardAOView: DetectBoardView!
    private var detectBoardDOView: DetectBoardView!
    private var detectBoardProfibusView: DetectBoardView!
    private var stackView1: UIStackView!
    private var stackView2: UIStackView!
    
    private var baundRatePickerView: UIToolbarPickerView!
    private let baundRates: Array<String> = Array(arrayLiteral: "1200", "9600", "19200", "38400", "52600", "115200")
    private var baubdRate: String = "1200"
    

    private lazy var viewModel: ProductConfigViewModel = { ProductConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        setNSNotificationCenter()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("setting_product_config"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        baundRatePickerView = UIToolbarPickerView()
        baundRatePickerView.dataSource = self
        baundRatePickerView.delegate = self
        baundRatePickerView.toolbarDelegate = self
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.init(named: "theme")
        
        modbusIdTextField = SubmitTextField(frame: .zero)
        modbusIdTextField.translatesAutoresizingMaskIntoConstraints = false
        modbusIdTextField.textField.delegate = self
        modbusIdTextField.textField.keyboardType = .asciiCapableNumberPad
        modbusIdTextField.titleLabel.text = getResString("product_config_modbus_id")
        modbusIdTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        baundRateTextField = SubmitTextField(frame: .zero)
        baundRateTextField.translatesAutoresizingMaskIntoConstraints = false
        baundRateTextField.textField.inputView = baundRatePickerView
        baundRateTextField.textField.inputAccessoryView = baundRatePickerView.toolbar
        baundRateTextField.setButtonHide()
        baundRateTextField.titleLabel.text = getResString("product_config_baund_rate")
        baundRateTextField.textField.placeholder = getResString("config_placeholder")
        
        profibusAddressTextField = SubmitTextField(frame: .zero)
        profibusAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        profibusAddressTextField.textField.delegate = self
        profibusAddressTextField.textField.keyboardType = .asciiCapableNumberPad
        profibusAddressTextField.titleLabel.text = getResString("product_config_profibus_address")
        profibusAddressTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        gearTextField = SubmitTextField(frame: .zero)
        gearTextField.translatesAutoresizingMaskIntoConstraints = false
        gearTextField.textField.delegate = self
        gearTextField.textField.keyboardType = .asciiCapableNumberPad
        gearTextField.titleLabel.text = getResString("product_config_gear")
        gearTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        oemTypeTextField = SubmitTextField(frame: .zero)
        oemTypeTextField.translatesAutoresizingMaskIntoConstraints = false
        oemTypeTextField.textField.delegate = self
        oemTypeTextField.titleLabel.text = getResString("product_config_oem_type")
        oemTypeTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        oemSerialTextField = SubmitTextField(frame: .zero)
        oemSerialTextField.translatesAutoresizingMaskIntoConstraints = false
        oemSerialTextField.textField.delegate = self
        oemSerialTextField.titleLabel.text = getResString("product_config_oem_serial")
        oemSerialTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        dealerTypeTextField = SubmitTextField(frame: .zero)
        dealerTypeTextField.translatesAutoresizingMaskIntoConstraints = false
        dealerTypeTextField.textField.delegate = self
        dealerTypeTextField.titleLabel.text = getResString("product_config_dealer_type")
        dealerTypeTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        dealerSerialTextField = SubmitTextField(frame: .zero)
        dealerSerialTextField.translatesAutoresizingMaskIntoConstraints = false
        dealerSerialTextField.textField.delegate = self
        dealerSerialTextField.titleLabel.text = getResString("product_config_dealer_serial")
        dealerSerialTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [modbusIdTextField,
                                                   baundRateTextField,
                                                   profibusAddressTextField,
                                                   gearTextField,
                                                   oemTypeTextField,
                                                   oemSerialTextField,
                                                   dealerTypeTextField,
                                                   dealerSerialTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        if UserDefaults.standard.object(forKey: "permission") as? Int == 1 {
            gearTextField.isHidden = true
            oemTypeTextField.isHidden = true
            oemSerialTextField.isHidden = true
        }
        
        detectTitleUILabel = UILabel(frame: .zero)
        detectTitleUILabel.translatesAutoresizingMaskIntoConstraints = false
        detectTitleUILabel.text = getResString("product_detect_title")
        scrollView.addSubview(detectTitleUILabel)
        
        detectBoardAIView = DetectBoardView(count: 2)
        detectBoardAIView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardAIView.titleLabel.text = getResString("product_detect_board_ai")
        
        detectBoardDIView = DetectBoardView(count: 2)
        detectBoardDIView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardDIView.titleLabel.text = getResString("product_detect_board_di")
        
        detectBoardModbusView = DetectBoardView(count: 1)
        detectBoardModbusView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardModbusView.titleLabel.text = getResString("product_detect_board_modbus")
        
        // 目前無銷售暫時移除
        // detectBoardHartView = DetectBoardView(count: 1)
        // detectBoardHartView.translatesAutoresizingMaskIntoConstraints = false
        // detectBoardHartView.titleLabel.text = getResString("product_detect_board_hart")
        
        let detectBoardEmptyView1 = DetectBoardView(count: 1)
        detectBoardEmptyView1.translatesAutoresizingMaskIntoConstraints = false
        detectBoardEmptyView1.imageView1.isHidden = true
        
        stackView1 = UIStackView(arrangedSubviews: [detectBoardAIView,
                                                    detectBoardDIView,
                                                    detectBoardModbusView,
                                                    detectBoardEmptyView1])
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView1)
        stackView1.axis = .horizontal
        stackView1.distribution = .equalCentering
        
        detectBoardAOView = DetectBoardView(count: 2)
        detectBoardAOView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardAOView.titleLabel.text = getResString("product_detect_board_ao")
        
        detectBoardDOView = DetectBoardView(count: 2)
        detectBoardDOView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardDOView.titleLabel.text = getResString("product_detect_board_do")
        
        detectBoardProfibusView = DetectBoardView(count: 1)
        detectBoardProfibusView.translatesAutoresizingMaskIntoConstraints = false
        detectBoardProfibusView.titleLabel.text = getResString("product_detect_board_profibuso")
        
        let detectBoardEmptyView2 = DetectBoardView(count: 1)
        detectBoardEmptyView2.translatesAutoresizingMaskIntoConstraints = false
        detectBoardEmptyView2.imageView1.isHidden = true
        
        stackView2 = UIStackView(arrangedSubviews: [detectBoardAOView,
                                                    detectBoardDOView,
                                                    detectBoardProfibusView,
                                                    detectBoardEmptyView2])
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView2)
        stackView2.axis = .horizontal
        stackView2.distribution = .equalCentering
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: screenWidth),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            
            detectTitleUILabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            detectTitleUILabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            
            stackView1.topAnchor.constraint(equalTo: detectTitleUILabel.bottomAnchor, constant: 10),
            stackView1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView1.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.833),
            
            stackView2.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 30),
            stackView2.centerXAnchor.constraint(equalTo: stackView1.centerXAnchor),
            stackView2.widthAnchor.constraint(equalTo: stackView1.widthAnchor),
            stackView2.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
    // Observer
    
    private func setObserver() {
        viewModel.productStatus.subscribe(onNext: { status in
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
        
        viewModel.modbusId.subscribe(onNext: { value in
            self.modbusIdTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.baundRate.subscribe(onNext: { value in
            self.baundRateTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.gear.subscribe(onNext: { value in
            self.gearTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.profibusAddress.subscribe(onNext: { value in
            self.profibusAddressTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.oemType.subscribe(onNext: { value in
            self.oemTypeTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.oemSerial.subscribe(onNext: { value in
            self.oemSerialTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.dealerType.subscribe(onNext: { value in
            self.dealerTypeTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.dealerSerial.subscribe(onNext: { value in
            self.dealerSerialTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.ai1Board.subscribe(onNext: { isLight in
            self.detectBoardAIView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.ai2Board.subscribe(onNext: { isLight in
            self.detectBoardAIView.updateLamp(lampIndex: 2, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.di1Board.subscribe(onNext: { isLight in
            self.detectBoardDIView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.di2Board.subscribe(onNext: { isLight in
            self.detectBoardDIView.updateLamp(lampIndex: 2, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.modbusBoard.subscribe(onNext: { isLight in
            self.detectBoardModbusView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
        
        // 目前無銷售暫時移除
        // viewModel.hartBoard.subscribe(onNext: { isLight in
        //     self.detectBoardHartView.updateLamp(lampIndex: 1, isLight: isLight)
        // }).disposed(by: disposeBag)
        
        viewModel.ao1Board.subscribe(onNext: { isLight in
            self.detectBoardAOView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.ao2Board.subscribe(onNext: { isLight in
            self.detectBoardAOView.updateLamp(lampIndex: 2, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.do1Board.subscribe(onNext: { isLight in
            self.detectBoardDOView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.do2Board.subscribe(onNext: { isLight in
            self.detectBoardDOView.updateLamp(lampIndex: 2, isLight: isLight)
        }).disposed(by: disposeBag)
        
        viewModel.profibusBoard.subscribe(onNext: { isLight in
            self.detectBoardProfibusView.updateLamp(lampIndex: 1, isLight: isLight)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender {
        case modbusIdTextField.button:
            if let value = modbusIdTextField.textField.text, !value.isEmpty {
                if 1...247 ~= Int(value)! {
                    viewModel.didSave(index: 0, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("1_247")]))
                }
            }
        case profibusAddressTextField.button:
            if let value = profibusAddressTextField.textField.text, !value.isEmpty {
                if 1...125 ~= Int(value)! {
                    viewModel.didSave(index: 2, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("1_125")]))
                }
            }
        case gearTextField.button:
            if let value = gearTextField.textField.text, !value.isEmpty {
                if 0...65535 ~= Int(value)! {
                    viewModel.didSave(index: 3, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("1_65535")]))
                }
            }
        case oemTypeTextField.button:
            if let value = oemTypeTextField.textField.text, !value.isEmpty {
                if value.lengthOfBytes(using: .utf8) <= 10 {
                    viewModel.didSave(index: 4, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ 10個字元", arguments: [getResString("out_of_range")]))
                }
            }
        case oemSerialTextField.button:
            if let value = oemSerialTextField.textField.text, !value.isEmpty {
                if value.lengthOfBytes(using: .utf8) <= 16 {
                    viewModel.didSave(index: 5, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ 16個字元", arguments: [getResString("out_of_range")]))
                }
            }
        case dealerTypeTextField.button:
            if let value = dealerTypeTextField.textField.text, !value.isEmpty {
                if value.lengthOfBytes(using: .utf8) <= 10 {
                    viewModel.didSave(index: 6, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ 10個字元", arguments: [getResString("out_of_range")]))
                }
            }
        case dealerSerialTextField.button:
            if let value = dealerSerialTextField.textField.text, !value.isEmpty {
                if value.lengthOfBytes(using: .utf8) <= 16 {
                    viewModel.didSave(index: 7, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ 16個字元", arguments: [getResString("out_of_range")]))
                }
            }
        default:
            break
        }
    }
}

// MARK: - Delegate

extension ProductConfigViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ProductConfigViewController: UIToolbarPickerViewDelegate {
    
    func didTapDone(pickerView: UIPickerView) {
        baundRateTextField.textField.text = baubdRate
        viewModel.didSave(index: 1, value: baubdRate)
        self.view.endEditing(true)
    }
    
    func didTapCancel() {
        self.view.endEditing(true)
    }
}

extension ProductConfigViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        baubdRate = baundRates[row]
    }
}

extension ProductConfigViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.baundRates.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.baundRates[row]
    }
}


extension ProductConfigViewController {
    
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
