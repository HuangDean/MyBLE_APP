import UIKit

final class MaintainConfigViewController: BaseViewController {
    
    private var switchTimesTextField: SubmitTextField!
    private var torqueTimesTextField: SubmitTextField!
    private var motorWorkTimeTextField: SubmitTextField!
    
    private var stackView: UIStackView!
    
    private lazy var viewModel: MaintainConfigViewModel = { MaintainConfigViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setObserver()
        viewModel.didGetData()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("maintain_config_title"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        switchTimesTextField = SubmitTextField(frame: .zero)
        switchTimesTextField.translatesAutoresizingMaskIntoConstraints = false
        switchTimesTextField.textField.keyboardType = .asciiCapableNumberPad
        switchTimesTextField.titleLabel.text = getResString("maintain_config_switchTimes")
        switchTimesTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        torqueTimesTextField = SubmitTextField(frame: .zero)
        torqueTimesTextField.translatesAutoresizingMaskIntoConstraints = false
        torqueTimesTextField.textField.keyboardType = .asciiCapableNumberPad
        torqueTimesTextField.titleLabel.text = getResString("maintain_config_torqueTimes")
        torqueTimesTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        motorWorkTimeTextField = SubmitTextField(frame: .zero)
        motorWorkTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        motorWorkTimeTextField.textField.keyboardType = .asciiCapableNumberPad
        motorWorkTimeTextField.titleLabel.text = getResString("maintain_config_motorWorkTime")
        motorWorkTimeTextField.button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [switchTimesTextField, torqueTimesTextField, motorWorkTimeTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.maintainStatus.subscribe(onNext: { status in
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
        
        viewModel.switchTimes.subscribe(onNext: { value in
            self.switchTimesTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.torqueTimes.subscribe(onNext: { value in
            self.torqueTimesTextField.textField.text = value
        }).disposed(by: disposeBag)
        
        viewModel.motorWorkTime.subscribe(onNext: { value in
            self.motorWorkTimeTextField.textField.text = value
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        switch sender {
        case switchTimesTextField.button:
            if let value = switchTimesTextField.textField.text, !value.isEmpty {
                if 3000...10000000 ~= Int(value)! {
                    viewModel.didSave(index: 0, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("3000_10000000")]))
                }
            }
        case torqueTimesTextField.button:
            if let value = torqueTimesTextField.textField.text, !value.isEmpty {
                if 3000...10000 ~= Int(value)! {
                    viewModel.didSave(index: 1, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("3000_10000")]))
                }
            }
        case motorWorkTimeTextField.button:
            if let value = motorWorkTimeTextField.textField.text, !value.isEmpty {
                if 100...2500 ~= Int(value)! {
                    viewModel.didSave(index: 2, value: value)
                } else {
                    self.showToast(msg: String(format: "%@ %@", arguments: [getResString("out_of_range"), getResString("100_2500")]))
                }
            }
        default:
            break
        }
    }
}
