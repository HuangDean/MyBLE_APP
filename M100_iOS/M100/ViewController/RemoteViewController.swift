import UIKit
import CoreBluetooth
import RxSwift

final class RemoteViewController: BaseViewController {
    
    private let getValveRealPositionCmd = [UInt8]([0x10, 0x06, 0x00, 0x56]) // 12: 4102~4187
//    private let getValveRealPositionCmd = [UInt8]([0x10, 0x06, 0x00, 0x0C]) // 12: 4102~4112
//    private let getSoftwareVersionCmd = [UInt8]([0x10, 0x16, 0x00, 0x14]) // 20: 4118~4136
//    private let getMotorRPMCmd = [UInt8]([0x10, 0x5B, 0x00, 0x01]) // 1: 4187
    
    private var controlImageView: UIImageView!
    private var exitButton: UIButton!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    private var enterButton: UIButton!
    
    private var progressView: UIView!
    private var rpmImageView: UIImageView!
    private var tempImageView: UIImageView!
    private var rpmLabel: UILabel!
    private var tempPrgressView: ProgressView!
    
    private var dashboardView: DashboardView!
    private var valveStatusLabel: UILabel!
    private var versionLabel: UILabel!
    
    init(parentVC: MainViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BLEManager.default.delegate = self
        setUpViews()
        startGatDataTimer()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopGatDataTimer()
    }
    
    // MARK: - SetupViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("remote_title"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        controlImageView = UIImageView(frame: .zero)
        controlImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(controlImageView)
        controlImageView.contentMode = .scaleAspectFit
        controlImageView.image = UIImage(named: "controls")
        
        exitButton = UIButton(frame: .zero)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(exitButton)
        exitButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .highlighted)
        exitButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpOutside)
        exitButton.addTarget(self, action: #selector(self.buttonDown(_:)), for: .touchDown)
        
        previousButton = UIButton(frame: .zero)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(previousButton)
        previousButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .highlighted)
        previousButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpOutside)
        previousButton.addTarget(self, action: #selector(self.buttonDown(_:)), for: .touchDown)
        
        nextButton = UIButton(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(nextButton)
        nextButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .highlighted)
        nextButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpOutside)
        nextButton.addTarget(self, action: #selector(self.buttonDown(_:)), for: .touchDown)
        
        enterButton = UIButton(frame: .zero)
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(enterButton)
        enterButton.setBackgroundColor(color: UIColor.init(white: 0.5, alpha: 0.5), forState: .highlighted)
        enterButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpInside)
        enterButton.addTarget(self, action: #selector(self.buttonUp), for: .touchUpOutside)
        enterButton.addTarget(self, action: #selector(self.buttonDown(_:)), for: .touchDown)
        
        progressView = UIView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressView)
        
        rpmImageView = UIImageView(frame: .zero)
        rpmImageView.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(rpmImageView)
        rpmImageView.contentMode = .scaleAspectFit
        rpmImageView.image = UIImage(named: "motor_rpm")
        
        tempImageView = UIImageView(frame: .zero)
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(tempImageView)
        tempImageView.contentMode = .scaleAspectFit
        tempImageView.image = UIImage(named: "temp_meter")
        
        rpmLabel = UILabel(frame: .zero)
        rpmLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(rpmLabel)
//        rpmLabel.setMinValue(value: 0.0)
//        rpmLabel.setMaxValue(value: 1800.0)
//        rpmLabel.setProgressColor(color: .systemBlue)
        rpmLabel.layer.borderWidth = 3
        rpmLabel.layer.borderColor = UIColor.lightGray.cgColor
        rpmLabel.textAlignment = .center
        rpmLabel.text = "0 " + getResString("main_rpm")
        
        tempPrgressView = ProgressView(frame: .zero)
        tempPrgressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(tempPrgressView)
        tempPrgressView.setMinValue(value: 0.0)
        tempPrgressView.setMaxValue(value: 100.0)
        tempPrgressView.setProgressColor(color: .systemOrange)
        tempPrgressView.setTitle(title: "0 °C")
        
        dashboardView = DashboardView(frame: .zero)
        dashboardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dashboardView)
        
        valveStatusLabel = UILabel(frame: .zero)
        valveStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valveStatusLabel)
        valveStatusLabel.layer.masksToBounds = true
        valveStatusLabel.layer.cornerRadius = 10
        valveStatusLabel.layer.borderColor = UIColor.systemYellow.cgColor
        valveStatusLabel.layer.borderWidth = 1
        valveStatusLabel.textAlignment = .center
        valveStatusLabel.backgroundColor = .white
        valveStatusLabel.font = UIFont.systemFont(ofSize: 18)
        valveStatusLabel.text = getResString("main_open")
        valveStatusLabel.textColor = .systemYellow
        
        versionLabel = UILabel(frame: .zero)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(versionLabel)
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = .lightGray
        versionLabel.text = getResString("main_version")
        
        NSLayoutConstraint.activate([
            controlImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            controlImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            controlImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            controlImageView.heightAnchor.constraint(equalTo: controlImageView.widthAnchor, multiplier: 228 / 392),
            
            progressView.topAnchor.constraint(equalTo: controlImageView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: dashboardView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: dashboardView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: dashboardView.topAnchor),
            
            rpmImageView.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 5),
            rpmImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            rpmImageView.widthAnchor.constraint(equalToConstant: 39 * rate / baseRate),
            rpmImageView.heightAnchor.constraint(equalToConstant: 38 * rate / baseRate),
            
            tempImageView.topAnchor.constraint(equalTo: rpmImageView.bottomAnchor, constant: 10),
            tempImageView.leadingAnchor.constraint(equalTo: rpmImageView.leadingAnchor),
            tempImageView.widthAnchor.constraint(equalTo: rpmImageView.widthAnchor),
            tempImageView.heightAnchor.constraint(equalTo: rpmImageView.heightAnchor),
            
            rpmLabel.leadingAnchor.constraint(equalTo: rpmImageView.trailingAnchor, constant: 10),
            rpmLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor),
            rpmLabel.centerYAnchor.constraint(equalTo: rpmImageView.centerYAnchor),
            rpmLabel.heightAnchor.constraint(equalTo: rpmImageView.heightAnchor),
            
            tempPrgressView.leadingAnchor.constraint(equalTo: rpmLabel.leadingAnchor),
            tempPrgressView.trailingAnchor.constraint(equalTo: rpmLabel.trailingAnchor),
            tempPrgressView.centerYAnchor.constraint(equalTo: tempImageView.centerYAnchor),
            tempPrgressView.heightAnchor.constraint(equalTo: tempImageView.heightAnchor),
            
            dashboardView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            dashboardView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            dashboardView.heightAnchor.constraint(equalTo: dashboardView.widthAnchor, multiplier: 0.85),
            dashboardView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            valveStatusLabel.leadingAnchor.constraint(equalTo: dashboardView.leadingAnchor, constant: 10),
            valveStatusLabel.bottomAnchor.constraint(equalTo: dashboardView.bottomAnchor, constant: -10),
            valveStatusLabel.widthAnchor.constraint(equalTo: dashboardView.widthAnchor, multiplier: 0.2),
            valveStatusLabel.heightAnchor.constraint(equalTo: valveStatusLabel.widthAnchor, multiplier: 0.7),
            
            versionLabel.trailingAnchor.constraint(equalTo: dashboardView.trailingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: dashboardView.bottomAnchor, constant: -10)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        exitButton.layer.cornerRadius = exitButton.frame.height / 2
        previousButton.layer.cornerRadius = exitButton.frame.height / 2
        nextButton.layer.cornerRadius = exitButton.frame.height / 2
        enterButton.layer.cornerRadius = exitButton.frame.height / 2
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: controlImageView.topAnchor, constant: controlImageView.bounds.height * 0.32),
            exitButton.leadingAnchor.constraint(equalTo: controlImageView.leadingAnchor, constant: controlImageView.bounds.width * 0.0433),
            exitButton.widthAnchor.constraint(equalToConstant: controlImageView.bounds.width * 0.204),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
            
            previousButton.topAnchor.constraint(equalTo: controlImageView.topAnchor, constant: controlImageView.bounds.height * 0.508),
            previousButton.leadingAnchor.constraint(equalTo: controlImageView.leadingAnchor, constant: controlImageView.bounds.width * 0.2755),
            previousButton.widthAnchor.constraint(equalTo: exitButton.widthAnchor),
            previousButton.heightAnchor.constraint(equalTo: exitButton.heightAnchor),
            
            nextButton.topAnchor.constraint(equalTo: controlImageView.topAnchor, constant: controlImageView.bounds.height * 0.4824),
            nextButton.leadingAnchor.constraint(equalTo: controlImageView.leadingAnchor, constant: controlImageView.bounds.width * 0.53),
            nextButton.widthAnchor.constraint(equalTo: exitButton.widthAnchor),
            nextButton.heightAnchor.constraint(equalTo: exitButton.heightAnchor),
            
            enterButton.topAnchor.constraint(equalTo: controlImageView.topAnchor, constant: controlImageView.bounds.height * 0.2982),
            enterButton.leadingAnchor.constraint(equalTo: controlImageView.leadingAnchor, constant: controlImageView.bounds.width * 0.78),
            enterButton.widthAnchor.constraint(equalTo: exitButton.widthAnchor),
            enterButton.heightAnchor.constraint(equalTo: exitButton.heightAnchor),
        ])
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        super.backButtonPressed()
        parentVC.didReAppear()
    }
    
    @objc private func buttonUp(_ sender: UIButton) {
        BLEManager.default.writeString(command: "cmd_keyclr")
    }
    
    @objc private func buttonDown(_ sender: UIButton) {
        
        switch sender {
        case exitButton:
            BLEManager.default.writeString(command: "cmd_esc")
        case previousButton:
            BLEManager.default.writeString(command: "cmd_up")
        case nextButton:
            BLEManager.default.writeString(command: "cmd_shift")
        default:
            BLEManager.default.writeString(command: "cmd_enter")
        }
    }
    
    // MARK: - Model
    
    private func startGatDataTimer() {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { second in
                BLEManager.default.writeBytes(content: self.getValveRealPositionCmd, mode: .Read)
            }).disposed(by: disposeBag)
    }
    
    private func stopGatDataTimer() {
        disposeBag = DisposeBag()
    }
}

// MARK: - Delegate

extension RemoteViewController: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            stopGatDataTimer()
            
            self.dismiss(animated: true, completion: nil)
            self.parentVC.didReAppear()
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        stopGatDataTimer()
        
        self.dismiss(animated: true, completion: nil)
        self.parentVC.didReAppear()
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        switch length {
        case 172:
            dashboardView.updateMotorTorque(value: ConvertManager.byte2Float(bytes: [UInt8](data[8...11])))
            
            let motorTemp = ConvertManager.byte2Float(bytes: [UInt8](data[12...15]))
            tempPrgressView.setTitle(title: String(format: "%d °C", Int(motorTemp)))
            tempPrgressView.updateProgress(progress: motorTemp)
            
            versionLabel.text = ConvertManager.byte2UTF8(bytes: [UInt8](data[32...39]))
            
            switch String(ConvertManager.byte2UInt16(bytes: [UInt8](data[48...49]))) {
            case "0":
                self.valveStatusLabel.text = getResString("main_stop")
            case "1":
                self.valveStatusLabel.text = getResString("main_open")
            default:
                self.valveStatusLabel.text = getResString("main_close")
            }
            
            self.dashboardView.updateValveCurrent(value: ConvertManager.byte2Float(bytes: [UInt8](data[56...59])))
            self.dashboardView.updateValveTarget(value: ConvertManager.byte2Float(bytes: [UInt8](data[60...63])))
            self.dashboardView.updateCorrectionMotorTorque(value: ConvertManager.byte2Float(bytes: [UInt8](data[64...67])))
            
            let rpm = ConvertManager.byte2UInt16(bytes: [UInt8](data[170...171]))
            rpmLabel.text = String(format: "%d " + getResString("main_rpm"), rpm)
        default:
            break
        }
    }
}
