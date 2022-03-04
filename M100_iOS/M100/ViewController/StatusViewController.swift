import UIKit
import CoreBluetooth
import RxSwift

final class StatusViewController: BaseViewController {
    
    enum Feature {
        case SystemStatus
        case ErrorStatus
    }
    
    private let getStatusCmd = [UInt8]([0x10, 0x0E, 0x00, 0x04])
    
    private let systemStatuses : [String] = [ NSLocalizedString("status_system_status1", comment: ""),
                                              NSLocalizedString("status_system_status2", comment: ""),
                                              NSLocalizedString("status_system_status3", comment: ""),
                                              NSLocalizedString("status_system_status4", comment: ""),
                                              NSLocalizedString("status_system_status5", comment: ""),
                                              NSLocalizedString("status_system_status6", comment: ""),
                                              NSLocalizedString("status_system_status7", comment: ""),
                                              NSLocalizedString("status_system_status8", comment: ""),
                                              NSLocalizedString("status_system_status9", comment: ""),
                                              NSLocalizedString("status_system_status10", comment: ""),
                                              NSLocalizedString("status_system_status11", comment: ""),
                                              NSLocalizedString("status_system_status12", comment: ""),
                                              NSLocalizedString("status_system_status13", comment: ""),
                                              NSLocalizedString("status_system_status14", comment: ""),
                                              NSLocalizedString("status_system_status15", comment: ""),
                                              NSLocalizedString("status_system_status16", comment: ""),
                                              NSLocalizedString("status_system_status17", comment: ""),
                                              NSLocalizedString("status_system_status18", comment: ""),
                                              NSLocalizedString("status_system_status19", comment: ""),
                                              NSLocalizedString("status_system_status20", comment: ""),
                                              NSLocalizedString("status_system_status21", comment: "")]
    
    
    private let errorStatuses : [String] = [NSLocalizedString("status_error_status1", comment: ""),
                                            NSLocalizedString("status_error_status2", comment: ""),
                                            NSLocalizedString("status_error_status3", comment: ""),
                                            NSLocalizedString("status_error_status4", comment: ""),
                                            NSLocalizedString("status_error_status5", comment: ""),
                                            NSLocalizedString("status_error_status6", comment: ""),
                                            NSLocalizedString("status_error_status7", comment: ""),
                                            NSLocalizedString("status_error_status8", comment: ""),
                                            NSLocalizedString("status_error_status9", comment: ""),
                                            NSLocalizedString("status_error_status10", comment: ""),
                                            NSLocalizedString("status_error_status11", comment: ""),
                                            NSLocalizedString("status_error_status12", comment: ""),
                                            NSLocalizedString("status_error_status13", comment: ""),
                                            NSLocalizedString("status_error_status14", comment: ""),
                                            NSLocalizedString("status_error_status15", comment: ""),
                                            NSLocalizedString("status_error_status16", comment: ""),
                                            NSLocalizedString("status_error_status17", comment: ""),
                                            NSLocalizedString("status_error_status18", comment: ""),
                                            NSLocalizedString("status_error_status19", comment: ""),
                                            NSLocalizedString("status_error_status20", comment: ""),
                                            NSLocalizedString("status_error_status21", comment: ""),
                                            NSLocalizedString("status_error_status22", comment: ""),
                                            NSLocalizedString("status_error_status23", comment: ""),
                                            NSLocalizedString("status_error_status24", comment: ""),
                                            NSLocalizedString("status_error_status25", comment: ""),
                                            NSLocalizedString("status_error_status26", comment: ""),
                                            NSLocalizedString("status_error_status27", comment: ""),
                                            NSLocalizedString("status_error_status28", comment: ""),
                                            NSLocalizedString("status_error_status29", comment: ""),
                                            NSLocalizedString("status_error_status30", comment: "")]
    
    private var tableView: UITableView!
    
    private var feature: Feature!
    private var statuses: [Int]?
    
    init(parentVC: MainViewController, feature: Feature, statuses: [Int]) {
        super.init(nibName: nil, bundle: nil)
        
        BLEManager.default.delegate = self
        self.parentVC = parentVC
        self.feature = feature
//        self.statuses = statuses
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        showIndicator()
        startGatDataTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        if feature == .SystemStatus {
            setBackButton(imgNamed: "back", title: getResString("status_title_system"))
        } else {
            setBackButton(imgNamed: "back", title: getResString("status_title_error"))
        }
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor.init(named: "theme")
        tableView.register(StatusTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func updateSystemErrors(value: Int) {
        let binaryStr = String(ConvertManager.int2Binary(value: value).reversed())
        let data = String(binaryStr.prefix(30))
        statuses = data.indices(of: "1")
    }
    
    private func updateSystemStatuses(value: Int) {
        let binaryStr = String(ConvertManager.int2Binary(value: value).reversed())
        let data = String(binaryStr.prefix(21))
        statuses = data.indices(of: "1")
    }
    
    private func startGatDataTimer() {
        if BLEManager.default.isConnecting() {
           
            Observable<Int>
                .interval(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { second in
                    BLEManager.default.writeBytes(content: self.getStatusCmd, mode: .Read)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func stopGatDataTimer() {
        disposeBag = DisposeBag()
    }
    
    // MARK: - Event
    
    override func backButtonPressed() {
        super.backButtonPressed()
        parentVC.didReAppear()
    }
}

// MARK: - Delegate

extension StatusViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feature == .SystemStatus {
            if statuses?.count ?? 0 > 21 {
                return systemStatuses.count + 1
            }
        } else {
            if statuses?.count ?? 0 > 30 {
                return errorStatuses.count + 1
            }
        }
        
        return (statuses?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StatusTableViewCell
        
        if row == 0 {
            cell.titleLabel.text = getResString("status_code")
            cell.statusLabel.text = getResString("status_code_content")
            return cell
        }
        
        cell.titleLabel.text = String(statuses![row - 1] + 1)
        
        if feature == .SystemStatus {
            cell.statusLabel.text = systemStatuses[statuses![row - 1]]
        } else {
            cell.statusLabel.text = errorStatuses[statuses![row - 1]]
        }
        return cell
    }
    
    
}

extension StatusViewController: BLEManagerDelegate {
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
        if length == 8 {
            if feature == .SystemStatus {
                updateSystemStatuses(value: Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[4...7]))))
            } else {
                updateSystemErrors(value: Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[0...3]))))
            }
            self.tableView.reloadData()
            self.hideIndicator()
        }
    }
}
