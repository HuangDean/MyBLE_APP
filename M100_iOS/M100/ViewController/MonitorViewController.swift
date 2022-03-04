import UIKit
import Charts
import RxSwift

final class MonitorViewController: BaseViewController {
    
    private var recordButton: UIButton!
    
    private var lineChartView: LineChartView!
    private var timeLineSlider: CustomSlider!
    private var timerSlider: CustomSlider!
    private var labelStackView: UIStackView!
    private var sliderStackView: UIStackView!
    private var mainStackView: UIStackView!
    
    private var valvePositionButton: UIButton!
    private var rpmButton: UIButton!
    private var torqueButton: UIButton!
    private var mortorTempeatureButton: UIButton!
    private var moduleTempeatureButton: UIButton!
    
    private lazy var viewModel: MonitorViewModel = { MonitorViewModel() }()
    
    private var isRecord: Bool = false
    
    private var lastSelectButton: UIButton!
    private var dataCount: Int = 1
    
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
        initLineChart()
        lastSelectButton = valvePositionButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
    }
    
    private func setUpViews() {
        setBackButton(imgNamed: "back", title: getResString("monitor_title"))
        setRightButton(imgNamed: "record", title: "")
        self.view.backgroundColor = UIColor.init(named: "theme")
        
        let backButtonImage = UIImage(named: "record")?.withRenderingMode(.alwaysOriginal)
        backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        lineChartView = LineChartView(frame: .zero)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lineChartView)
        lineChartView.isUserInteractionEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.setLabelCount(6, force: true)
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 210
        
        let timeLineTitleLabel = UILabel(frame: .zero)
        timeLineTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        self.view.addSubview(timeLineTitleLabel)
        timeLineTitleLabel.font = UIFont.systemFont(ofSize: 20)
        timeLineTitleLabel.text = getResString("monitor_time_line")
        
        let timerTitleLabel = UILabel(frame: .zero)
        timerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        self.view.addSubview(timerTitleLabel)
        timerTitleLabel.font = UIFont.systemFont(ofSize: 20)
        timerTitleLabel.text = getResString("monitor_timer")
        
        labelStackView = UIStackView(arrangedSubviews: [timeLineTitleLabel, timerTitleLabel])
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.distribution = .equalSpacing
        labelStackView.spacing = 15
        
        timeLineSlider = CustomSlider(frame: .zero, isInt: true)
        timeLineSlider.translatesAutoresizingMaskIntoConstraints = false
        //        self.view.addSubview(timeLineSlider)
        timeLineSlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        timeLineSlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        timeLineSlider.minimumValue = 1
        timeLineSlider.maximumValue = 7
        timeLineSlider.value = 6
        timeLineSlider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        
        timerSlider = CustomSlider(frame: .zero, isInt: true)
        timerSlider.translatesAutoresizingMaskIntoConstraints = false
        //        self.view.addSubview(timerSlider)
        timerSlider.isContinuous = false
        timerSlider.minimumTrackTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        timerSlider.thumbTintColor = UIColor.init(red: 160 / 255, green: 205 / 255, blue: 99 / 255, alpha: 1)
        timerSlider.minimumValue = 1
        timerSlider.maximumValue = 10
        timerSlider.value = 1
        timerSlider.addTarget(self, action: #selector(sliderChange(_:)), for: .valueChanged)
        
        sliderStackView = UIStackView(arrangedSubviews: [timeLineSlider, timerSlider])
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        sliderStackView.axis = .vertical
        sliderStackView.distribution = .fillEqually
        sliderStackView.spacing = 15
        
        mainStackView = UIStackView(arrangedSubviews: [labelStackView, sliderStackView])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .horizontal
        mainStackView.spacing = 15
        self.view.addSubview(mainStackView)
        
        valvePositionButton = UIButton(frame: .zero)
        valvePositionButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(valvePositionButton)
        valvePositionButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        valvePositionButton.layer.cornerRadius = 5
        valvePositionButton.layer.borderColor = UIColor.gray.cgColor
        valvePositionButton.layer.borderWidth = 2
        valvePositionButton.backgroundColor = UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1)
        valvePositionButton.setBackgroundColor(color: UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1), forState: .highlighted)
        valvePositionButton.setTitleColor(.darkGray, for: .normal)
        valvePositionButton.setTitle(getResString("monitor_position"), for: .normal)
        valvePositionButton.titleLabel?.lineBreakMode = .byWordWrapping
        valvePositionButton.titleLabel?.textAlignment = .center
        
        rpmButton = UIButton(frame: .zero)
        rpmButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(rpmButton)
        rpmButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        rpmButton.layer.cornerRadius = 5
        rpmButton.layer.borderColor = UIColor.gray.cgColor
        rpmButton.layer.borderWidth = 2
        rpmButton.backgroundColor = UIColor.init(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        rpmButton.setBackgroundColor(color: UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1), forState: .highlighted)
        rpmButton.setTitleColor(.darkGray, for: .normal)
        rpmButton.setTitle(getResString("monitor_rpm"), for: .normal)
        
        torqueButton = UIButton(frame: .zero)
        torqueButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(torqueButton)
        torqueButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        torqueButton.layer.cornerRadius = 5
        torqueButton.layer.borderColor = UIColor.gray.cgColor
        torqueButton.layer.borderWidth = 2
        torqueButton.backgroundColor = UIColor.init(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        torqueButton.setBackgroundColor(color: UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1), forState: .highlighted)
        torqueButton.setTitleColor(.darkGray, for: .normal)
        torqueButton.setTitle(getResString("monitor_torque"), for: .normal)
        
        mortorTempeatureButton = UIButton(frame: .zero)
        mortorTempeatureButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mortorTempeatureButton)
        mortorTempeatureButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        mortorTempeatureButton.layer.cornerRadius = 5
        mortorTempeatureButton.layer.borderColor = UIColor.gray.cgColor
        mortorTempeatureButton.layer.borderWidth = 2
        mortorTempeatureButton.backgroundColor = UIColor.init(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        mortorTempeatureButton.setBackgroundColor(color: UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1), forState: .highlighted)
        mortorTempeatureButton.setTitleColor(.darkGray, for: .normal)
        mortorTempeatureButton.setTitle(getResString("monitor_mortor_tempeature"), for: .normal)
        mortorTempeatureButton.titleLabel?.lineBreakMode = .byWordWrapping
        mortorTempeatureButton.titleLabel?.textAlignment = .center
        
        moduleTempeatureButton = UIButton(frame: .zero)
        moduleTempeatureButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(moduleTempeatureButton)
        moduleTempeatureButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        moduleTempeatureButton.layer.cornerRadius = 5
        moduleTempeatureButton.layer.borderColor = UIColor.gray.cgColor
        moduleTempeatureButton.layer.borderWidth = 2
        moduleTempeatureButton.backgroundColor = UIColor.init(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        moduleTempeatureButton.setBackgroundColor(color: UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1), forState: .highlighted)
        moduleTempeatureButton.setTitleColor(.darkGray, for: .normal)
        moduleTempeatureButton.setTitle(getResString("monitor_module_tempeature"), for: .normal)
        moduleTempeatureButton.titleLabel?.lineBreakMode = .byWordWrapping
        moduleTempeatureButton.titleLabel?.textAlignment = .center
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            lineChartView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            lineChartView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            lineChartView.heightAnchor.constraint(equalToConstant: 200),
            
            mainStackView.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: 30),
            mainStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            valvePositionButton.topAnchor.constraint(equalTo: timerSlider.bottomAnchor, constant: 20),
            valvePositionButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            valvePositionButton.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
            valvePositionButton.heightAnchor.constraint(equalTo: valvePositionButton.widthAnchor),
            
            rpmButton.centerYAnchor.constraint(equalTo: valvePositionButton.centerYAnchor),
            rpmButton.leadingAnchor.constraint(equalTo: valvePositionButton.trailingAnchor, constant: 10),
            rpmButton.widthAnchor.constraint(equalTo: valvePositionButton.widthAnchor),
            rpmButton.heightAnchor.constraint(equalTo: valvePositionButton.heightAnchor),
            
            torqueButton.centerYAnchor.constraint(equalTo: rpmButton.centerYAnchor),
            torqueButton.leadingAnchor.constraint(equalTo: rpmButton.trailingAnchor, constant: 10),
            torqueButton.widthAnchor.constraint(equalTo: valvePositionButton.widthAnchor),
            torqueButton.heightAnchor.constraint(equalTo: valvePositionButton.heightAnchor),
            
            mortorTempeatureButton.topAnchor.constraint(equalTo: valvePositionButton.bottomAnchor, constant: 20),
            mortorTempeatureButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            mortorTempeatureButton.widthAnchor.constraint(equalTo: valvePositionButton.widthAnchor),
            mortorTempeatureButton.heightAnchor.constraint(equalTo: valvePositionButton.heightAnchor),
            
            moduleTempeatureButton.centerYAnchor.constraint(equalTo: mortorTempeatureButton.centerYAnchor),
            moduleTempeatureButton.leadingAnchor.constraint(equalTo: mortorTempeatureButton.trailingAnchor, constant: 10),
            moduleTempeatureButton.widthAnchor.constraint(equalTo: valvePositionButton.widthAnchor),
            moduleTempeatureButton.heightAnchor.constraint(equalTo: valvePositionButton.heightAnchor),
        ])
    }
    
    private func setRightButton(imgNamed: String, title: String){
        let backButtonImage = UIImage(named: imgNamed)
        recordButton = UIButton(type: .custom)
        recordButton.imageView?.contentMode = .scaleAspectFit
        recordButton.setImage(backButtonImage, for: .normal)
        recordButton.setImage(backButtonImage, for: .highlighted)
        recordButton.setTitle(title, for: .normal)
        recordButton.setTitleColor(.black, for: .normal)
        recordButton.addTarget(self, action: #selector(self.buttonSaveCVS), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: recordButton)
    }
    
    private func initLineChart() {
        // new data
        let lineChartEntry = [ChartDataEntry]()
        
        // new line connect
        let lineCharDataSet = LineChartDataSet(entries: lineChartEntry, label: "")
        lineCharDataSet.colors = [.black]
        lineCharDataSet.circleColors = [.black]
        lineCharDataSet.circleRadius = 4
        lineCharDataSet.circleHoleRadius = 0
        
        // include a lot of line
        let lineChartData = LineChartData()
        lineChartData.addDataSet(lineCharDataSet)
        
        // xAxis timeline
        self.lineChartView.xAxis.valueFormatter = DateValueFormatter()
        self.lineChartView.xAxis.granularity = 1.0
        
        // 餵給chart
        lineChartView.data = lineChartData
    }
    
    /// firstValue：當資料超過10筆時，刪除陣列頭資料
    private func updateLineChart(firstMilisec: Double, value: Int, milisec: Double) {
        if dataCount > 10 {
            lineChartView.data?.removeEntry(xValue: firstMilisec, dataSetIndex: 0)
        }
        
        lineChartView.data?.addEntry(ChartDataEntry(x: milisec, y: Double(value)), dataSetIndex: 0)
        lineChartView.notifyDataSetChanged()
        dataCount += 1
    }
    
    /// firstValue：當資料超過10筆時，刪除陣列頭資料
    private func updateLineChart(firstMilisec: Double, value: Float, milisec: Double) {
        if dataCount > 10 {
            lineChartView.data?.removeEntry(xValue: firstMilisec, dataSetIndex: 0)
        }
        
        lineChartView.data?.addEntry(ChartDataEntry(x: milisec, y: Double(value)), dataSetIndex: 0)
        lineChartView.notifyDataSetChanged()
        dataCount += 1
    }
    
    private func updateXAxisMaximum(count: Int) {
        lineChartView.xAxis.setLabelCount(count, force: true)
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateYAxisMaximum(count: Int) {
        lineChartView.leftAxis.axisMaximum = Double(count)
        lineChartView.notifyDataSetChanged()
    }
    
    private func shareCSV(csvFile: URL) {
        let vc = UIActivityViewController(activityItems: [csvFile], applicationActivities: [])
        present(vc, animated: true)
    }
    
    // MARK: - Observer
    
    private func setObserver() {
        viewModel.monitorStatus.subscribe(onNext: { status in
            if status == .DisConnect {
                self.dismiss(animated: true, completion: nil)
                self.parentVC.didReAppear()
            }
        }).disposed(by: disposeBag)
        
        viewModel.rpm.subscribe(onNext: { (firstMilisec, value, milisec) in
            self.updateLineChart(firstMilisec: firstMilisec, value: value, milisec: milisec)
        }).disposed(by: disposeBag)
        
        viewModel.valveCurrent.subscribe(onNext: { (firstMilisec, value, milisec) in
            self.updateLineChart(firstMilisec: firstMilisec, value: value, milisec: milisec)
        }).disposed(by: disposeBag)
        
        viewModel.motorTorque.subscribe(onNext: { (firstMilisec, value, milisec) in
            self.updateLineChart(firstMilisec: firstMilisec, value: value, milisec: milisec)
        }).disposed(by: disposeBag)
        
        viewModel.motorTemperature.subscribe(onNext: { (firstMilisec, value, milisec) in
            self.updateLineChart(firstMilisec: firstMilisec, value: value, milisec: milisec)
        }).disposed(by: disposeBag)
        
        viewModel.moduleTemperature.subscribe(onNext: { (firstMilisec, value, milisec) in
            self.updateLineChart(firstMilisec: firstMilisec, value: value, milisec: milisec)
        }).disposed(by: disposeBag)
        
        viewModel.csvFile.subscribe(onNext: { csvFile in
            self.shareCSV(csvFile: csvFile)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Events
    
    @objc private func sliderChange(_ sender: UISlider) {
        
        sender.setValue(sender.value.rounded(.down), animated: false)
        
        if sender == timeLineSlider {
            updateXAxisMaximum(count: Int(sender.value))
        } else {
            viewModel.updateTimerSeconds(seconds: Int(sender.value))
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        if sender == lastSelectButton { return }
        
        lastSelectButton.backgroundColor = UIColor.init(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        lastSelectButton = sender
        sender.backgroundColor = UIColor.init(red: 128 / 255, green: 184 / 255, blue: 192 / 255, alpha: 1)
        
        dataCount = 1
        lineChartView.clearValues()
        initLineChart()
        lineChartView.notifyDataSetChanged()
        
        switch sender {
        case valvePositionButton:
            viewModel.updateObserverDataSource(index: 0)
            updateYAxisMaximum(count: 210)
            
            for (index, value) in viewModel.getValveCurrents().enumerated() {
                if viewModel.getValveCurrents().count > 10 && index == 0 { continue }
                
                updateLineChart(firstMilisec: viewModel.getFirstTimeLine(), value: value, milisec: viewModel.getTimeLineIndex(index: index))
            }
        case rpmButton:
            viewModel.updateObserverDataSource(index: 1)
            updateYAxisMaximum(count: 2100)
            
            for (index, value) in viewModel.getRpms().enumerated() {
                if viewModel.getRpms().count > 10 && index == 0 { continue }
                
                updateLineChart(firstMilisec: viewModel.getFirstTimeLine(), value: value, milisec: viewModel.getTimeLineIndex(index: index))
            }
        case torqueButton:
            viewModel.updateObserverDataSource(index: 2)
            updateYAxisMaximum(count: 210)
            
            for (index, value) in viewModel.getMotorTorques().enumerated() {
                if viewModel.getMotorTorques().count > 10 && index == 0 { continue }
                
                updateLineChart(firstMilisec: viewModel.getFirstTimeLine(), value: value, milisec: viewModel.getTimeLineIndex(index: index))
            }
        case mortorTempeatureButton:
            viewModel.updateObserverDataSource(index: 3)
            updateYAxisMaximum(count: 210)
            
            for (index, value) in viewModel.getMotorTemperatures().enumerated() {
                if viewModel.getMotorTemperatures().count > 10 && index == 0 { continue }
                
                updateLineChart(firstMilisec: viewModel.getFirstTimeLine(), value: value, milisec: viewModel.getTimeLineIndex(index: index))
            }
        default:
            viewModel.updateObserverDataSource(index: 4)
            updateYAxisMaximum(count: 210)
            
            for (index, value) in viewModel.getMouleTemperatures().enumerated() {
                if viewModel.getMouleTemperatures().count > 10 && index == 0 { continue }
                
                updateLineChart(firstMilisec: viewModel.getFirstTimeLine(), value: value, milisec: viewModel.getTimeLineIndex(index: index))
            }
        }
        
        lineChartView.notifyDataSetChanged()
    }
    
    @objc private func buttonSaveCVS() {
        if !BLEManager.default.isConnecting() { return }
        
        isRecord = !isRecord
        viewModel.didSaveCSV()
        
        if isRecord {
            recordButton.setImage(UIImage(named: "save"), for: .normal)
        } else {
            recordButton.setImage(UIImage(named: "record"), for: .normal)
        }
    }
    
    override func backButtonPressed() {
        super.backButtonPressed()
        parentVC.didReAppear()
    }
}

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "HH:mm:ss"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(value)))
    }
}
