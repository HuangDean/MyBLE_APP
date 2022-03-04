import UIKit

final class SettingViewController: BaseViewController {
    
    private var tableView: UITableView!
    
    private var items: Array<String> = Array(arrayLiteral: NSLocalizedString("setting_product_config", comment: ""),
                                             NSLocalizedString("setting_maintain_config", comment: ""),
                                             NSLocalizedString("setting_system_config", comment: ""),
                                             NSLocalizedString("setting_ungent_config", comment: ""),
                                             NSLocalizedString("setting_switch_config", comment: ""),
                                             NSLocalizedString("setting_control_mode_config", comment: ""),
                                             NSLocalizedString("setting_output_config", comment: ""))
    
    init(parentVC: MainViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    // MARK: - setUpViews
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("setting_title"))
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - Events
    
    override func backButtonPressed() {
        super.backButtonPressed()
        parentVC.didReAppear()
    }
}


// MARK: - Delegate

extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var viewController: BaseViewController!
        
        switch indexPath.row {
        case 0:
            viewController = ProductConfigViewController()
        case 1:
            viewController = MaintainConfigViewController()
        case 2:
            viewController = SystemConfigViewController()
        case 3:
            viewController = UngentConfigViewController()
        case 4:
            viewController = SwitchConfigViewController()
        case 5:
            viewController = ControlModeConfigViewController()
        case 6:
            viewController = OutputConfigViewController()
        default:
            break
        }
        
        viewController.parentVC = self.parentVC
        pushViewController(viewController: viewController)
    }
}
