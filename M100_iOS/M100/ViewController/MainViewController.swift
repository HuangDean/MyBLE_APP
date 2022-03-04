import UIKit
import RxSwift
import SideMenu
import CoreBluetooth

struct VersionResponse: Decodable {
    let resultCount: Int
    let results: [Result]
}

struct Result: Decodable {
    let version: String
}

final class MainViewController: BaseViewController {
    
    // MARK: - Properties
    var sideMenu: SideMenuNavigationController!
    
    private var lightStautsImageView: UIImageView!
    private var disConnectButton: UIButton!
    private var settingButton: UIButton!
    private var monitorButton: UIButton!
    private var remoteButton: UIButton!
    private var stackView: UIStackView!
    
    private var menuInstructionImageView: UIImageView!
    private var unit1: UILabel!
    private var unit2: UILabel!
    
    private var motorImageView: UIImageView!
    private var moduleTemperatureImageView: UIImageView!
    private var moduleTemperatureLabel: UILabel!
    private var motorTemperatureImageView: UIImageView!
    private var motorTemperatureLabel: UILabel!
    private var rpmImageView: UIImageView!
    private var rpmLabel: UILabel!
    private var systemStatusButton: UIButton!
    private var systemErrorButton: UIButton!
    private var maintainRecordButton: UIButton!
    
    private var dashboardView : DashboardView!
    private var valveStatusLabel: UILabel!
    private var versionLabel: UILabel!
    
    private var isExpand = false
    
    private lazy var viewModel: MainViewModel = { MainViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkVersion()
        setUpViews()
        setObserver()
    }
    
    private func checkVersion() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        let versionAPI = String(format: "https://itunes.apple.com/lookup?bundleId=%@", bundleId)
        
        if let url = URL(string: versionAPI) {
            // GET
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                // 假如錯誤存在，則印出錯誤訊息（ 例如：網路斷線等等... ）
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let response = response as? HTTPURLResponse,let data = data {
                    // 將 response 轉乘 HTTPURLResponse 可以查看 statusCode 檢查錯誤（ ex: 404 可能是網址錯誤等等... ）
                    print("Status code: \(response.statusCode)")
                    let decoder = JSONDecoder()
                    if let response = try? decoder.decode(VersionResponse.self, from: data) {
                        if response.resultCount > 0 && !response.results.isEmpty {
                            guard let version = Float(response.results.first!.version) else { return }
                            guard let bundleVersion = Float((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!) else { return }
                            if version > bundleVersion {
                                DispatchQueue.main.async {
                                    self.showAlert(title: self.getResString("version_check_title"),
                                                   msg: String(format: self.getResString("version_check_message"), version),
                                                   isCancelAction: true,
                                                   textAlignment: .center) {
                                        let appleID = "1502348013"
                                        
                                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appleID)"), UIApplication.shared.canOpenURL(url) {
                                            if #available(iOS 10.0, *) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            } else {
                                                UIApplication.shared.openURL(url)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.resume()
        } else {
            print("Invalid URL.")
        }
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        
        self.navBar.isHidden = true
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        sideMenu = SideMenuNavigationController(rootViewController: SideMenuViewController(delegate: self))
        sideMenu.statusBarEndAlpha = 0
        
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .left)
        
        let sunyehImageView = UIImageView(frame: .zero)
        sunyehImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sunyehImageView)
        sunyehImageView.contentMode = .scaleAspectFit
        sunyehImageView.image = UIImage(named: "sunyeh")
        
        lightStautsImageView = UIImageView(frame: .zero)
        lightStautsImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lightStautsImageView)
        lightStautsImageView.contentMode = .scaleAspectFit
        lightStautsImageView.image = UIImage(named: "light_red")
        
        motorImageView = UIImageView(frame: .zero)
        motorImageView.translatesAutoresizingMaskIntoConstraints = false
        motorImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.view.addSubview(motorImageView)
        motorImageView.contentMode = .scaleAspectFit
        motorImageView.image = UIImage(named: "motor")
        
        disConnectButton = UIButton(frame: .zero)
        disConnectButton.translatesAutoresizingMaskIntoConstraints = false
        disConnectButton.imageView?.contentMode = .scaleAspectFit
        disConnectButton.setImage(UIImage(named: "disconnect"), for: .normal)
        disConnectButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        settingButton = UIButton(frame: .zero)
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        settingButton.imageView?.contentMode = .scaleAspectFit
        settingButton.setImage(UIImage(named: "setting"), for: .normal)
        settingButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        monitorButton = UIButton(frame: .zero)
        monitorButton.translatesAutoresizingMaskIntoConstraints = false
        monitorButton.imageView?.contentMode = .scaleAspectFit
        monitorButton.setImage(UIImage(named: "monitor"), for: .normal)
        monitorButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        remoteButton = UIButton(frame: .zero)
        remoteButton.translatesAutoresizingMaskIntoConstraints = false
        remoteButton.imageView?.contentMode = .scaleAspectFit
        remoteButton.setImage(UIImage(named: "control"), for: .normal)
        remoteButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [disConnectButton, settingButton, monitorButton, remoteButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10 * rate
        stackView.isHidden = true
        
        menuInstructionImageView = UIImageView(frame: .zero)
        menuInstructionImageView.translatesAutoresizingMaskIntoConstraints = false
        menuInstructionImageView.contentMode = .scaleAspectFit
        menuInstructionImageView.image = getResImage("menu_instruction")
        self.view.addSubview(menuInstructionImageView)
        
        moduleTemperatureImageView = UIImageView(frame: .zero)
        moduleTemperatureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(moduleTemperatureImageView)
        moduleTemperatureImageView.contentMode = .scaleAspectFit
        moduleTemperatureImageView.image = UIImage(named: "thermometer0")
        
        moduleTemperatureLabel = UILabel(frame: .zero)
        moduleTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(moduleTemperatureLabel)
        moduleTemperatureLabel.font = UIFont.systemFont(ofSize: 11)
        moduleTemperatureLabel.textColor = .white
        moduleTemperatureLabel.text = "00"
        
        motorTemperatureImageView = UIImageView(frame: .zero)
        motorTemperatureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(motorTemperatureImageView)
        motorTemperatureImageView.contentMode = .scaleAspectFit
        motorTemperatureImageView.image = UIImage(named: "thermometer0")
        
        motorTemperatureLabel = UILabel(frame: .zero)
        motorTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(motorTemperatureLabel)
        motorTemperatureLabel.font = UIFont.systemFont(ofSize: 11)
        motorTemperatureLabel.textColor = .white
        motorTemperatureLabel.text = "00"
        
        unit1 = UILabel(frame: .zero)
        unit1.translatesAutoresizingMaskIntoConstraints = false
        unit1.text = "℃"
        unit1.textColor = .black
        self.view.addSubview(unit1)
        
        unit2 = UILabel(frame: .zero)
        unit2.translatesAutoresizingMaskIntoConstraints = false
        unit2.text = "℃"
        self.view.addSubview(unit2)
        
        rpmImageView = UIImageView(frame: .zero)
        rpmImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rpmImageView)
        rpmImageView.contentMode = .scaleAspectFit
        rpmImageView.image = UIImage(named: "rpm")
        
        rpmLabel = UILabel(frame: .zero)
        rpmLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rpmLabel)
        rpmLabel.text = "0 " + getResString("main_rpm")
        
        systemStatusButton = UIButton(frame: .zero)
        systemStatusButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(systemStatusButton)
        systemStatusButton.imageView?.contentMode = .scaleAspectFit
        systemStatusButton.setImage(UIImage(named: "system_status"), for: .normal)
        systemStatusButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        systemErrorButton = UIButton(frame: .zero)
        systemErrorButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(systemErrorButton)
        systemErrorButton.imageView?.contentMode = .scaleAspectFit
        systemErrorButton.setImage(UIImage(named: "warning"), for: .normal)
        systemErrorButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        systemErrorButton.isHidden = true
        
        maintainRecordButton = UIButton(frame: .zero)
        maintainRecordButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(maintainRecordButton)
        maintainRecordButton.imageView?.contentMode = .scaleAspectFit
        maintainRecordButton.setImage(UIImage(named: "maintain"), for: .normal)
        maintainRecordButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        dashboardView = DashboardView(frame: .zero)
        dashboardView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dashboardView)
        
        valveStatusLabel = UILabel(frame: .zero)
        valveStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valveStatusLabel)
        valveStatusLabel.layer.cornerRadius = 10
        valveStatusLabel.layer.masksToBounds = true
        valveStatusLabel.layer.borderColor = UIColor.systemYellow.cgColor
        valveStatusLabel.layer.borderWidth = 1
        valveStatusLabel.backgroundColor = .white
        valveStatusLabel.font = UIFont.systemFont(ofSize: 18)
        valveStatusLabel.textColor = .systemYellow
        valveStatusLabel.textAlignment = .center
        valveStatusLabel.text = getResString("main_open")
        
        versionLabel = UILabel(frame: .zero)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(versionLabel)
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = .lightGray
        versionLabel.text = getResString("main_version")
        
        NSLayoutConstraint.activate([
            sunyehImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sunyehImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            sunyehImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.242),
            
            lightStautsImageView.centerYAnchor.constraint(equalTo: sunyehImageView.centerYAnchor),
            lightStautsImageView.leadingAnchor.constraint(equalTo: sunyehImageView.trailingAnchor, constant: 10),
            lightStautsImageView.widthAnchor.constraint(equalToConstant: 20),
            lightStautsImageView.heightAnchor.constraint(equalTo: lightStautsImageView.widthAnchor),
            
            motorImageView.topAnchor.constraint(equalTo: sunyehImageView.topAnchor),
            motorImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            motorImageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            motorImageView.heightAnchor.constraint(equalTo: motorImageView.widthAnchor, multiplier: 0.75),
            
            stackView.topAnchor.constraint(equalTo: motorImageView.bottomAnchor, constant: 10),
            stackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            unit1.topAnchor.constraint(equalTo: moduleTemperatureImageView.topAnchor, constant: -8 * rate),
            unit1.trailingAnchor.constraint(equalTo: moduleTemperatureImageView.trailingAnchor),
            
            unit2.topAnchor.constraint(equalTo: motorTemperatureImageView.topAnchor, constant: -8 * rate),
            unit2.trailingAnchor.constraint(equalTo: motorTemperatureImageView.trailingAnchor),
            
            menuInstructionImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            menuInstructionImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            menuInstructionImageView.widthAnchor.constraint(equalToConstant: 47.75 * rate),
            menuInstructionImageView.heightAnchor.constraint(equalToConstant: 93.75 * rate),
            
            disConnectButton.widthAnchor.constraint(equalTo: settingButton.heightAnchor),
            disConnectButton.heightAnchor.constraint(equalTo: settingButton.widthAnchor),
            
            settingButton.widthAnchor.constraint(equalToConstant: 50),
            settingButton.heightAnchor.constraint(equalTo: settingButton.widthAnchor),
            
            monitorButton.widthAnchor.constraint(equalTo: settingButton.widthAnchor),
            monitorButton.heightAnchor.constraint(equalTo: settingButton.heightAnchor),
            
            remoteButton.widthAnchor.constraint(equalTo: monitorButton.heightAnchor),
            remoteButton.heightAnchor.constraint(equalTo: monitorButton.widthAnchor),
            
            moduleTemperatureImageView.heightAnchor.constraint(equalTo: motorImageView.heightAnchor, multiplier: 0.4146),
            moduleTemperatureImageView.widthAnchor.constraint(equalTo: moduleTemperatureImageView.heightAnchor, multiplier: 0.5),
            
            motorTemperatureImageView.heightAnchor.constraint(equalTo: moduleTemperatureImageView.heightAnchor),
            motorTemperatureImageView.widthAnchor.constraint(equalTo: moduleTemperatureImageView.widthAnchor),
            
            rpmImageView.widthAnchor.constraint(equalTo: motorImageView.widthAnchor, multiplier: 0.431),
            rpmImageView.heightAnchor.constraint(equalTo: rpmImageView.widthAnchor, multiplier: 0.422),
            
            systemStatusButton.widthAnchor.constraint(equalTo: maintainRecordButton.widthAnchor, multiplier: 0.7),
            systemStatusButton.heightAnchor.constraint(equalTo: systemStatusButton.widthAnchor),
            
            systemErrorButton.widthAnchor.constraint(equalTo: systemStatusButton.widthAnchor),
            systemErrorButton.heightAnchor.constraint(equalTo: systemStatusButton.widthAnchor),
            
            maintainRecordButton.widthAnchor.constraint(equalTo: motorImageView.widthAnchor, multiplier: 0.1818),
            maintainRecordButton.heightAnchor.constraint(equalTo: maintainRecordButton.widthAnchor),
            
            dashboardView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9466),
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.didAppear()
        
        NSLayoutConstraint.activate([
            moduleTemperatureImageView.leadingAnchor.constraint(equalTo: motorImageView.leadingAnchor, constant: -moduleTemperatureImageView.bounds.width / 2),
            moduleTemperatureImageView.bottomAnchor.constraint(equalTo: motorImageView.bottomAnchor, constant: -motorImageView.bounds.height * 0.1463),
            
            moduleTemperatureLabel.centerXAnchor.constraint(equalTo: moduleTemperatureImageView.centerXAnchor),
            moduleTemperatureLabel.bottomAnchor.constraint(equalTo: moduleTemperatureImageView.bottomAnchor, constant: -moduleTemperatureImageView.bounds.height * 0.07),
            
            motorTemperatureImageView.centerXAnchor.constraint(equalTo: motorImageView.centerXAnchor, constant: -motorImageView.bounds.width * 0.0775),
            motorTemperatureImageView.topAnchor.constraint(equalTo: motorImageView.topAnchor, constant: motorImageView.bounds.height * 0.06),
            
            motorTemperatureLabel.centerXAnchor.constraint(equalTo: motorTemperatureImageView.centerXAnchor),
            motorTemperatureLabel.bottomAnchor.constraint(equalTo: motorTemperatureImageView.bottomAnchor, constant: -motorTemperatureImageView.bounds.height * 0.07),
            
            rpmImageView.trailingAnchor.constraint(equalTo: motorImageView.trailingAnchor, constant: -motorImageView.bounds.width * 0.0258),
            rpmImageView.topAnchor.constraint(equalTo: motorImageView.topAnchor, constant: motorImageView.bounds.height * 0.03),
            
            rpmLabel.centerXAnchor.constraint(equalTo: rpmImageView.centerXAnchor),
            rpmLabel.centerYAnchor.constraint(equalTo: rpmImageView.centerYAnchor, constant: -rpmImageView.bounds.height * 0.1126),
            
            systemStatusButton.leadingAnchor.constraint(equalTo: motorImageView.leadingAnchor, constant: motorImageView.bounds.width * 0.1637),
            systemStatusButton.topAnchor.constraint(equalTo: motorImageView.topAnchor, constant: motorImageView.bounds.height * 0.285),
            
            systemErrorButton.leadingAnchor.constraint(equalTo: motorImageView.leadingAnchor, constant: motorImageView.bounds.width * 0.633),
            systemErrorButton.centerYAnchor.constraint(equalTo: maintainRecordButton.centerYAnchor),
            
            maintainRecordButton.leadingAnchor.constraint(equalTo: motorImageView.leadingAnchor, constant: motorImageView.bounds.width * 0.15),
            maintainRecordButton.centerYAnchor.constraint(equalTo: motorImageView.centerYAnchor, constant: motorImageView.bounds.height * 0.17),
            
            dashboardView.topAnchor.constraint(equalTo: self.motorImageView.bottomAnchor, constant: (screenHeight - motorImageView.frame.maxY - dashboardView.bounds.height) / 1.2),
        ])
    }
    
    // MARK: - Observer
    private func setObserver() {
        viewModel.mainStatus.subscribe(onNext: { status in
            
            if status != .Connecting {
                self.hideIndicator()
            }
            
            switch status {
            case .Connecting:
                self.showIndicator()
            case .ConnectFailed:
                self.showAlert(msg: "連線失敗，請重試")
            case .LoginFailed:
                self.showAlert(msg: self.getResString("login_password_error"))
            case .Unlogined:
                self.stackView.isHidden = true
                self.lightStautsImageView.image = UIImage(named: "light_red")
            case .General:
                self.settingButton.isHidden = true
                self.stackView.isHidden = false
                self.lightStautsImageView.image = UIImage(named: "light_green")
                self.showToast(msg: self.getResString("ble_status_connect"))
            case .Dealer:
                self.settingButton.isHidden = false
                self.stackView.isHidden = false
                self.lightStautsImageView.image = UIImage(named: "light_green")
                self.showToast(msg: self.getResString("ble_status_connect"))
            case .Developer:
                self.settingButton.isHidden = false
                self.stackView.isHidden = false
                self.lightStautsImageView.image = UIImage(named: "light_green")
                self.showToast(msg: self.getResString("ble_status_connect"))
            case .DisConnect:
                self.rpmLabel.text = "0 " + self.getResString("main_rpm")
                self.motorTemperatureImageView.image = UIImage(named: "thermometer0")
                self.motorTemperatureLabel.text = "00"
                self.moduleTemperatureImageView.image = UIImage(named: "thermometer0")
                self.moduleTemperatureLabel.text = "00"
                self.dashboardView.updateValveCurrent(value: 0.0)
                self.dashboardView.updateMotorTorque(value: 0.0)
                self.dashboardView.updateValveTarget(value: 0.0)
                
                self.stackView.isHidden = true
                self.lightStautsImageView.image = UIImage(named: "light_red")
                self.showAlert(msg: self.getResString("ble_status_disconnect"))
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.rpm.subscribe(onNext: { rpm in
            self.rpmLabel.text = "\(rpm) " + self.getResString("main_rpm")
        }).disposed(by: disposeBag)
        
        viewModel.valveCurrent.subscribe(onNext: { value in
            self.dashboardView.updateValveCurrent(value: value)
        }).disposed(by: disposeBag)
        
        viewModel.valveTarget.subscribe(onNext: { value in
            self.dashboardView.updateValveTarget(value: value)
        }).disposed(by: disposeBag)
        
        viewModel.correctionMotorTorque.subscribe(onNext: { value in
            self.dashboardView.updateCorrectionMotorTorque(value: value)
        }).disposed(by: disposeBag)
        
        viewModel.motorTorque.subscribe(onNext: { value in
            self.dashboardView.updateMotorTorque(value: value)
        }).disposed(by: disposeBag)
        
        viewModel.motorTemperature.subscribe(onNext: { value in
            self.motorTemperatureLabel.text = String(Int(value))
            
            if value <= 25 {
                self.motorTemperatureImageView.image = UIImage(named: "thermometer25")
            } else if value <= 50 {
                self.motorTemperatureImageView.image = UIImage(named: "thermometer50")
            } else if value <= 80 {
                self.motorTemperatureImageView.image = UIImage(named: "thermometer50")
            } else {
                self.motorTemperatureImageView.image = UIImage(named: "thermometer100")
            }
        }).disposed(by: disposeBag)
        
        viewModel.systemErrorStatus.subscribe(onNext: { value in
            if value == 0 {
                self.systemErrorButton.isHidden = true
            } else{
                self.systemErrorButton.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        viewModel.moduleTemperature.subscribe(onNext: { value in
            self.moduleTemperatureLabel.text = String(Int(value))
            
            if value <= 25 {
                self.moduleTemperatureImageView.image = UIImage(named: "thermometer25")
            } else if value <= 50 {
                self.moduleTemperatureImageView.image = UIImage(named: "thermometer50")
            } else if value <= 80 {
                self.moduleTemperatureImageView.image = UIImage(named: "thermometer50")
            } else {
                self.moduleTemperatureImageView.image = UIImage(named: "thermometer100")
            }
        }).disposed(by: disposeBag)
        
        viewModel.version.subscribe(onNext: { version in
            self.versionLabel.text = version
        }).disposed(by: disposeBag)
        
        viewModel.valveStatus.subscribe(onNext: { valveStatus in
            switch valveStatus {
            case "0":
                self.valveStatusLabel.text = self.getResString("main_stop")
            case "1":
                self.valveStatusLabel.text = self.getResString("main_open")
            default:
                self.valveStatusLabel.text = self.getResString("main_close")
            }
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        #if DEBUG
        TestManager.printCmd()
        #endif
        
        // 停止第一頁get data
        viewModel.viewWillDisappear()
        
        switch sender {
        case disConnectButton:
            lightStautsImageView.image = UIImage(named: "light_red")
            BLEManager.default.disconnect()
        case settingButton:
            presentViewController(viewController: SettingViewController(parentVC: self))
        case monitorButton:
            presentViewController(viewController: MonitorViewController(parentVC: self))
        case remoteButton:
            presentViewController(viewController: RemoteViewController(parentVC: self))
        case systemStatusButton:
            presentViewController(viewController: StatusViewController(parentVC: self,
                                                                       feature: .SystemStatus,
                                                                       statuses: viewModel.getSystemStatuses()))
        case maintainRecordButton:
            presentViewController(viewController: MaintainViewController(parentVC: self))
        case systemErrorButton:
            presentViewController(viewController: StatusViewController(parentVC: self,
                                                                       feature: .ErrorStatus,
                                                                       statuses: viewModel.getSystemErrors()))
        default:
            break
        }
    }
    
    override func didReAppear() {
        super.didReAppear()
        
        viewModel.didAppear()
    }
}

// MARK: - Delegate

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        let sideViewController = (menu.viewControllers[0] as! SideMenuViewController)
        sideViewController.clearTableView()
        // BLEManager.default.setFilterName(name: "SunYeh")
        BLEManager.default.startScanning(timeout: 10 * 1000)
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        BLEManager.default.stopScan()
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
}

extension MainViewController: SideMenuDelegate {
    
    func selectPeripheral(peripheral: CBPeripheral, permission: Permission, password: String) {
        viewModel.didSelectPeripheral(peripheral: peripheral, permission: permission, password: password)
        sideMenu.dismiss(animated: true, completion: nil)
    }
}
