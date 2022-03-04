import UIKit
import CoreBluetooth
import RxSwift

protocol SideMenuDelegate {
    func selectPeripheral(peripheral: CBPeripheral, permission: Permission, password: String)
}

final class SideMenuViewController: BaseViewController {
    
    private var cookieNameLabel: UILabel!
    private var cookieMacLabel: UILabel!
    private var cookieConnectButton: UIButton!
    private var deviceTableView: UITableView!
    
    private var permission: Permission!
    private var password: String!
    
    private var delegate: SideMenuDelegate!
    
    private var viewModel: SideMenuViewModel = { SideMenuViewModel() }()
    
    init(delegate: SideMenuDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SideMenuViewModel()
        
        setUpViews()
        setObserver()
    }
    
    // MARK: - SetUpViews
    
    private func setUpViews() {
        
        navigationItem.title = getResString("side_title")
        
        let actIndView = UIActivityIndicatorView(style: .gray)
        let barButton = UIBarButtonItem(customView: actIndView)
        navigationItem.setRightBarButton(barButton, animated: true)
        actIndView.startAnimating()
        
        deviceTableView = UITableView(frame: .zero, style: .plain)
        deviceTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(deviceTableView)
        deviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.showsVerticalScrollIndicator = false
        
        let cookieView = UIView(frame: .zero)
        cookieView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cookieView)
        cookieView.layer.shadowOpacity = 0.2
        cookieView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cookieView.backgroundColor = .white
        
        let cookieTitleLabel = UILabel(frame: .zero)
        cookieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cookieView.addSubview(cookieTitleLabel)
        cookieTitleLabel.font = UIFont.systemFont(ofSize: 20)
        cookieTitleLabel.text = getResString("side_last_connect")
        
        cookieNameLabel = UILabel(frame: .zero)
        cookieNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cookieView.addSubview(cookieNameLabel)
        cookieNameLabel.textColor = .gray
        cookieNameLabel.text = " "
        
        cookieMacLabel = UILabel(frame: .zero)
        cookieMacLabel.translatesAutoresizingMaskIntoConstraints = false
        cookieView.addSubview(cookieMacLabel)
        cookieMacLabel.textColor = .gray
        cookieMacLabel.text = " "
        
        cookieConnectButton = UIButton(frame: .zero)
        cookieConnectButton.translatesAutoresizingMaskIntoConstraints = false
        cookieView.addSubview(cookieConnectButton)
        cookieConnectButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        cookieConnectButton.layer.cornerRadius = 5
        cookieConnectButton.setTitleColor(.white, for: .normal)
        cookieConnectButton.setTitleColor(.gray, for: .disabled)
        cookieConnectButton.setTitle(getResString("login_connect"), for: .normal)
        cookieConnectButton.setBackgroundColor(color: .lightGray, forState: .normal)
        cookieConnectButton.setBackgroundColor(color: .gray, forState: .highlighted)
        cookieConnectButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            cookieView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            cookieView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            cookieView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            cookieTitleLabel.topAnchor.constraint(equalTo: cookieView.topAnchor, constant: 10),
            cookieTitleLabel.leadingAnchor.constraint(equalTo: cookieView.leadingAnchor, constant: 10),
            
            cookieNameLabel.topAnchor.constraint(equalTo: cookieTitleLabel.bottomAnchor,constant: 10),
            cookieNameLabel.leadingAnchor.constraint(equalTo: cookieTitleLabel.leadingAnchor),
            
            cookieMacLabel.topAnchor.constraint(equalTo: cookieNameLabel.bottomAnchor, constant: 5),
            cookieMacLabel.leadingAnchor.constraint(equalTo: cookieNameLabel.leadingAnchor),
            cookieMacLabel.trailingAnchor.constraint(equalTo: cookieView.trailingAnchor, constant: -10),
            
            cookieConnectButton.topAnchor.constraint(equalTo: cookieMacLabel.bottomAnchor, constant: 5),
            cookieConnectButton.leadingAnchor.constraint(equalTo: cookieView.leadingAnchor, constant: 1),
            cookieConnectButton.trailingAnchor.constraint(equalTo: cookieView.trailingAnchor, constant: -1),
            cookieConnectButton.bottomAnchor.constraint(equalTo: cookieView.bottomAnchor, constant: -1),
            
            deviceTableView.topAnchor.constraint(equalTo: cookieView.bottomAnchor),
            deviceTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            deviceTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            deviceTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        
        viewModel.peripheralsSubject.subscribe(onNext: { _ in
            self.deviceTableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.peripheralSubject.subscribe(onNext: { peripheral in
            self.delegate.selectPeripheral(peripheral: peripheral, permission: self.permission, password: self.password)
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.peripheralCookieSubject.subscribe(onNext: { peripheralCookie in
            self.cookieNameLabel.text = peripheralCookie.name
            self.cookieMacLabel.text = peripheralCookie.identifier.uuidString
            self.cookieConnectButton.isEnabled = true
        }).disposed(by: disposeBag)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        let permission = UserDefaults.standard.object(forKey: "permission") as? Int
        
        switch permission {
        case 0:
            self.permission = .General
        case 1:
            self.permission = .Dealer
        default:
            self.permission = .Developer
        }
        
        password = UserDefaults.standard.object(forKey: "password") as? String
        
        viewModel.cookieConnectPeripheral()
    }
    
    func clearTableView() {
//        permissionSettingButton.isEnabled = false
        cookieConnectButton.isEnabled = false
        cookieNameLabel.text = " "
        cookieMacLabel.text = " "
        
        setObserver()
        viewModel.clearPeripherals()
        deviceTableView.reloadData()
    }
}

// MARK: - Delegate

extension SideMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        BLEManager.default.stopScan()
        
        let row = indexPath.row
        
        let loginViewController = LoginViewController(deviceName: viewModel.getPeripherals()[row].name ?? " ",
                                                      peripheralIndex: row,
                                                      delegate: self)
        presentViewController(viewController: loginViewController, isOverContext: false)
    }
}

extension SideMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getPeripherals().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.getPeripherals()[row].name
        
        switch viewModel.getRssi(index: row) {
        case -30...0:
            cell.imageView?.image = UIImage(named: "signal_3")
        case -60 ... -31:
            cell.imageView?.image = UIImage(named: "signal_2")
        default:
            cell.imageView?.image = UIImage(named: "signal_1")
        }
        
        return cell
    }
}

extension SideMenuViewController: LoginDelegate {
    
    func loginTapped(peripheralIndex: Int?, permission: Permission , password: String) {
        self.permission = permission
        self.password = password
        viewModel.selectPeripheral(index: peripheralIndex!, password: password)
    }
}
