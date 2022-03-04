import UIKit
import RxSwift

final class MaintainViewController: BaseViewController {
    
    private var systemWorkinghoursLabel: UILabel!
    private var motorWorkinghoursLabel: UILabel!
    private var torqueRemainingTimesLabel: UILabel!
    private var valveRemainingTimesLabel: UILabel!
    private var motorRemainingTimesLabel: UILabel!
    private var totalTorqueOffCountLabel: UILabel!
    private var totalValveOnCountLabel: UILabel!
    private var totalValveOffCountLabel: UILabel!
    private var totalTorqueAllOnLabel: UILabel!
    private var totalTorqueAllOffLabel: UILabel!
    
    private lazy var viewModel: MaintainViewModel = { MaintainViewModel() }()
    
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
        setObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
        viewModel.viewWillDisappear()
    }
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("status_title_maintain"))
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        systemWorkinghoursLabel = UILabel(frame: .zero)
        systemWorkinghoursLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(systemWorkinghoursLabel)
        systemWorkinghoursLabel.text = String(format: "%@：xx%@xx%@xx%@xx%@",
                                              arguments:[getResString("maintain_system_working"),
                                                          getResString("maintain_day"),
                                                          getResString("maintain_hours"),
                                                          getResString("maintain_min"),
                                                          getResString("maintain_sec")])
        
        motorWorkinghoursLabel = UILabel(frame: .zero)
        motorWorkinghoursLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(motorWorkinghoursLabel)
        motorWorkinghoursLabel.adjustsFontSizeToFitWidth = true
        motorWorkinghoursLabel.text =   String(format: "%@：xx%@xx%@xx%@xx%@",
                                               arguments: [getResString("maintain_motor_working"),
                                                           getResString("maintain_day"),
                                                           getResString("maintain_hours"),
                                                           getResString("maintain_min"),
                                                           getResString("maintain_sec")])
        
        let torqueRemainingTimesTitleLabel = UILabel(frame: .zero)
        torqueRemainingTimesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(torqueRemainingTimesTitleLabel)
        torqueRemainingTimesTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        torqueRemainingTimesTitleLabel.text = getResString("maintain_torque_remaining_times") + "："
        
        torqueRemainingTimesLabel = UILabel(frame: .zero)
        torqueRemainingTimesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(torqueRemainingTimesLabel)
        torqueRemainingTimesLabel.layer.cornerRadius = 3
        torqueRemainingTimesLabel.layer.masksToBounds = true
        torqueRemainingTimesLabel.backgroundColor = .white
        torqueRemainingTimesLabel.textAlignment = .center
        torqueRemainingTimesLabel.text = " "
        
        let valveRemainingTimesTitleLabel = UILabel(frame: .zero)
        valveRemainingTimesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valveRemainingTimesTitleLabel)
        valveRemainingTimesTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valveRemainingTimesTitleLabel.text = getResString("maintain_valve_remaining_times") + "："
        
        valveRemainingTimesLabel = UILabel(frame: .zero)
        valveRemainingTimesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valveRemainingTimesLabel)
        valveRemainingTimesLabel.layer.cornerRadius = 3
        valveRemainingTimesLabel.layer.masksToBounds = true
        valveRemainingTimesLabel.backgroundColor = .white
        valveRemainingTimesLabel.textAlignment = .center
        valveRemainingTimesLabel.text = " "
        
        let motorRemainingTimesTitleLabel = UILabel(frame: .zero)
        motorRemainingTimesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(motorRemainingTimesTitleLabel)
        motorRemainingTimesTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        motorRemainingTimesTitleLabel.text = getResString("maintain_motor_remaining_times") + "："
        
        motorRemainingTimesLabel = UILabel(frame: .zero)
        motorRemainingTimesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(motorRemainingTimesLabel)
        motorRemainingTimesLabel.layer.cornerRadius = 3
        motorRemainingTimesLabel.layer.masksToBounds = true
        motorRemainingTimesLabel.backgroundColor = .white
        motorRemainingTimesLabel.textAlignment = .center
        motorRemainingTimesLabel.text = " "
        
        let dividerView = UIView(frame: .zero)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dividerView)
        dividerView.backgroundColor = .white
        
        let totalTorqueOffCountTitleLabel = UILabel(frame: .zero)
        totalTorqueOffCountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueOffCountTitleLabel)
        totalTorqueOffCountTitleLabel.text = getResString("maintain_total_torque_off_count") + "："
        
        totalTorqueOffCountLabel = UILabel(frame: .zero)
        totalTorqueOffCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueOffCountLabel)
        totalTorqueOffCountLabel.text = ""
        
        let totalValveOnCountTitleLabel = UILabel(frame: .zero)
        totalValveOnCountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalValveOnCountTitleLabel)
        totalValveOnCountTitleLabel.text = getResString("maintain_total_valve_on_count") + "："
        
        totalValveOnCountLabel = UILabel(frame: .zero)
        totalValveOnCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalValveOnCountLabel)
        totalValveOnCountLabel.text = ""
        
        let totalValveOffTitleLabel = UILabel(frame: .zero)
        totalValveOffTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalValveOffTitleLabel)
        totalValveOffTitleLabel.text = getResString("maintain_total_valve_off") + "："
        
        totalValveOffCountLabel = UILabel(frame: .zero)
        totalValveOffCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalValveOffCountLabel)
        totalValveOffCountLabel.text = ""
        
        let totalTorqueAllOnTitleLabel = UILabel(frame: .zero)
        totalTorqueAllOnTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueAllOnTitleLabel)
        totalTorqueAllOnTitleLabel.text = getResString("maintain_total_torque_all_on") + "："
        
        totalTorqueAllOnLabel = UILabel(frame: .zero)
        totalTorqueAllOnLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueAllOnLabel)
        totalTorqueAllOnLabel.text = ""
        
        let totalTorqueAllOffTitleLabel = UILabel(frame: .zero)
        totalTorqueAllOffTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueAllOffTitleLabel)
        totalTorqueAllOffTitleLabel.text = getResString("maintain_total_torque_all_off") + "："
        
        totalTorqueAllOffLabel = UILabel(frame: .zero)
        totalTorqueAllOffLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(totalTorqueAllOffLabel)
        totalTorqueAllOffLabel.text = ""
        
        NSLayoutConstraint.activate([
            systemWorkinghoursLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            systemWorkinghoursLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            systemWorkinghoursLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            motorWorkinghoursLabel.topAnchor.constraint(equalTo: systemWorkinghoursLabel.bottomAnchor, constant: 10),
            motorWorkinghoursLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            motorWorkinghoursLabel.trailingAnchor.constraint(equalTo: systemWorkinghoursLabel.trailingAnchor),
            
            torqueRemainingTimesTitleLabel.topAnchor.constraint(equalTo: motorWorkinghoursLabel.bottomAnchor, constant: 25),
            torqueRemainingTimesTitleLabel.leadingAnchor.constraint(equalTo: motorWorkinghoursLabel.leadingAnchor),
            
            torqueRemainingTimesLabel.leadingAnchor.constraint(equalTo: torqueRemainingTimesTitleLabel.trailingAnchor, constant: 10),
            torqueRemainingTimesLabel.trailingAnchor.constraint(equalTo: systemWorkinghoursLabel.trailingAnchor),
            torqueRemainingTimesLabel.centerYAnchor.constraint(equalTo: torqueRemainingTimesTitleLabel.centerYAnchor),
            
            valveRemainingTimesTitleLabel.topAnchor.constraint(equalTo: torqueRemainingTimesTitleLabel.bottomAnchor, constant: 20),
            valveRemainingTimesTitleLabel.leadingAnchor.constraint(equalTo: torqueRemainingTimesTitleLabel.leadingAnchor),
            
            valveRemainingTimesLabel.leadingAnchor.constraint(equalTo: valveRemainingTimesTitleLabel.trailingAnchor, constant: 10),
            valveRemainingTimesLabel.trailingAnchor.constraint(equalTo: systemWorkinghoursLabel.trailingAnchor),
            valveRemainingTimesLabel.centerYAnchor.constraint(equalTo: valveRemainingTimesTitleLabel.centerYAnchor),
            
            motorRemainingTimesTitleLabel.topAnchor.constraint(equalTo: valveRemainingTimesTitleLabel.bottomAnchor, constant: 20),
            motorRemainingTimesTitleLabel.leadingAnchor.constraint(equalTo: valveRemainingTimesTitleLabel.leadingAnchor),
            
            motorRemainingTimesLabel.leadingAnchor.constraint(equalTo: motorRemainingTimesTitleLabel.trailingAnchor, constant: 10),
            motorRemainingTimesLabel.trailingAnchor.constraint(equalTo: systemWorkinghoursLabel.trailingAnchor),
            motorRemainingTimesLabel.centerYAnchor.constraint(equalTo: motorRemainingTimesTitleLabel.centerYAnchor),
            
            dividerView.topAnchor.constraint(equalTo: motorRemainingTimesTitleLabel.bottomAnchor, constant: 20),
            dividerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            dividerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            totalTorqueOffCountTitleLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
            totalTorqueOffCountTitleLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            
            totalTorqueOffCountLabel.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            totalTorqueOffCountLabel.centerYAnchor.constraint(equalTo: totalTorqueOffCountTitleLabel.centerYAnchor),
            totalTorqueOffCountLabel.heightAnchor.constraint(equalTo: totalTorqueOffCountTitleLabel.heightAnchor, multiplier: 20),
            
            totalValveOnCountTitleLabel.topAnchor.constraint(equalTo: totalTorqueOffCountTitleLabel.bottomAnchor, constant: 10),
            totalValveOnCountTitleLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            
            totalValveOnCountLabel.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            totalValveOnCountLabel.centerYAnchor.constraint(equalTo: totalValveOnCountTitleLabel.centerYAnchor),
            
            totalValveOffTitleLabel.topAnchor.constraint(equalTo: totalValveOnCountTitleLabel.bottomAnchor, constant: 10),
            totalValveOffTitleLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            
            totalValveOffCountLabel.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            totalValveOffCountLabel.centerYAnchor.constraint(equalTo: totalValveOffTitleLabel.centerYAnchor),
            
            totalTorqueAllOnTitleLabel.topAnchor.constraint(equalTo: totalValveOffTitleLabel.bottomAnchor, constant: 10),
            totalTorqueAllOnTitleLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            
            totalTorqueAllOnLabel.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            totalTorqueAllOnLabel.centerYAnchor.constraint(equalTo: totalTorqueAllOnTitleLabel.centerYAnchor),
            
            totalTorqueAllOffTitleLabel.topAnchor.constraint(equalTo: totalTorqueAllOnTitleLabel.bottomAnchor, constant: 10),
            totalTorqueAllOffTitleLabel.leadingAnchor.constraint(equalTo: systemWorkinghoursLabel.leadingAnchor),
            
            totalTorqueAllOffLabel.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor),
            totalTorqueAllOffLabel.centerYAnchor.constraint(equalTo: totalTorqueAllOffTitleLabel.centerYAnchor)
        ])
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        
        viewModel.maintainStatus.subscribe(onNext: { status in
            if status == .DisConnect {
                self.dismiss(animated: true, completion: nil)
                self.parentVC.didReAppear()
            }
        }).disposed(by: disposeBag)
        
        viewModel.torqueRemainingTimes.subscribe(onNext: { value in
            self.torqueRemainingTimesLabel.text = String(value)
        }).disposed(by: disposeBag)
        
        viewModel.valveRemainingTimes.subscribe(onNext: { value in
            self.valveRemainingTimesLabel.text = String(value)
        }).disposed(by: disposeBag)
        
        viewModel.motorRemainingTimes.subscribe(onNext: { seconds in
            let time = self.seconds2DayHoursMinutesSeconds(seconds: seconds)
            self.motorRemainingTimesLabel.text = String(format: self.getResString("maintain_date_format"),
                                                        arguments: [time.0, time.1, time.2, time.3])
        }).disposed(by: disposeBag)
        
        viewModel.totalValveOffCount.subscribe(onNext: { value in
            self.totalValveOffCountLabel.text = String(value) + " " +  self.getResString("maintain_count")
        }).disposed(by: disposeBag)
        
        viewModel.totalValveOnCount.subscribe(onNext: { value in
            self.totalValveOnCountLabel.text = String(value) + " " +  self.getResString("maintain_count")
        }).disposed(by: disposeBag)
        
        viewModel.totalTorqueAllOff.subscribe(onNext: { value in
            self.totalTorqueAllOffLabel.text = String(value) + " " +  self.getResString("maintain_count")
        }).disposed(by: disposeBag)
        
        viewModel.totalTorqueAllOn.subscribe(onNext: { value in
            self.totalTorqueAllOnLabel.text = String(value) + " " +  self.getResString("maintain_count")
        }).disposed(by: disposeBag)
        
        viewModel.systemWorkinghours.subscribe(onNext: { seconds in
            let time = self.seconds2DayHoursMinutesSeconds(seconds: seconds)
            self.systemWorkinghoursLabel.text = String(format: self.getResString("maintain_system_working_hours"),
                                                       arguments: [time.0, time.1, time.2, time.3])
                        
        }).disposed(by: disposeBag)
        
        viewModel.motorWorkinghours.subscribe(onNext: { seconds in
            let time = self.seconds2DayHoursMinutesSeconds(seconds: seconds)
            self.motorWorkinghoursLabel.text = String(format: self.getResString("maintain_motor_working_hours"),
                                                      arguments: [time.0, time.1, time.2, time.3])
        }).disposed(by: disposeBag)
        
        viewModel.totalTorqueOffCount.subscribe(onNext: { value in
            self.totalTorqueOffCountLabel.text = String(value) + " " + self.getResString("maintain_count")
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
     
    override func backButtonPressed() {
        super.backButtonPressed()
        parentVC.didReAppear()
    }
    
    private func seconds2DayHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
      return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
