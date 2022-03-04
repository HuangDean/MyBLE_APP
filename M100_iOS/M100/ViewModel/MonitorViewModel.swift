import CoreBluetooth
import RxSwift

class MonitorViewModel: BaseViewModel {
    
    enum DataSource {
        case Rpm
        case ValveCurrent
        case MotorTorques
        case MotorTemperatures
        case ModuleTemperatures
    }
    
    private let getValveRealPositionCmd = [UInt8]([0x10, 0x22, 0x00, 0x0A])
    private let getMotorRPMCmd = [UInt8]([0x10, 0x5B, 0x00, 0x01])
    
    let monitorStatus = PublishSubject<BaseStatus>()
    let rpm = PublishSubject<(Double, Int, Double)>()
    let valveCurrent = PublishSubject<(Double, Float, Double)>()
    let motorTorque = PublishSubject<(Double, Float, Double)>()
    let motorTemperature = PublishSubject<(Double, Float, Double)>()
    let moduleTemperature = PublishSubject<(Double, Float, Double)>()
    let csvFile = PublishSubject<URL>()
    
    private var rpms = [Int]()
    private var valveCurrents = [Float]()
    private var motorTorques = [Float]()
    private var motorTemperatures = [Float]()
    private var moduleTemperatures = [Float]()
    
    private var observerDataSource: DataSource = .ValveCurrent
    private var timeLines: [Double] = []
    
    private var timeSecond: Double! // 最新一比時間軸
    
    private var isRecord: Bool = false
    private var csvDatas: [(String, Float, Float, Float, Float, Int)] = []
    
    private var timerDelay: Int = 1 // 每秒更新間隔

    override init() {
        super.init()
        
        BLEManager.default.delegate = self
    }
    
    func startGatDataTimer() {
        if !BLEManager.default.isConnecting() {
            return
        }
        
        stopGatDataTimer()
        
        Observable<Int>
            .interval(.seconds(timerDelay), scheduler: MainScheduler.instance)
            .subscribe(onNext: { second in
                 BLEManager.default.writeBytes(content: self.getValveRealPositionCmd, mode: .Read)
            }).disposed(by: disposeBag)
    }
    
    private func stopGatDataTimer() {
        disposeBag = DisposeBag()
    }
    
    private func updateDataArray(dataSource: DataSource, value: Int) {
        if dataSource == .Rpm {
            rpms.append(value)
            
            if rpms.count > 11 {
                rpms.remove(at: 0)
            }
        }
    }
    
    private func updateDataArray(dataSource: DataSource, value: Float) {
        switch dataSource {
        case .ValveCurrent:
            valveCurrents.append(value)
            if valveCurrents.count > 11 {
                valveCurrents.remove(at: 0)
            }
        case .MotorTorques:
            motorTorques.append(value)
            if motorTorques.count > 11 {
                motorTorques.remove(at: 0)
            }
        case .MotorTemperatures:
            motorTemperatures.append(value)
            if motorTemperatures.count > 11 {
                motorTemperatures.remove(at: 0)
            }
        case .ModuleTemperatures:
            moduleTemperatures.append(value)
            if moduleTemperatures.count > 11 {
                moduleTemperatures.remove(at: 0)
            }
        default:
            break
        }
    }
    
    func didSaveCSV() {
        if !BLEManager.default.isConnecting() { return }
        
        isRecord = !isRecord
        
        if !isRecord {
            stopGatDataTimer()
            
            var csvString = "時間,位置(%),扭力(Nm),模組溫度(℃),馬達溫度(℃),馬達轉速(rpm)\n"
            
            for dct in csvDatas {
                csvString = csvString.appending("\(dct.0),\(dct.1),\(dct.2),\(dct.3),\(dct.4),\(dct.5)\n")
            }
            
            let fileManager = FileManager.default
            do {
                let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
                let fileURL = path.appendingPathComponent("M100.csv")
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                csvDatas.removeAll()
                csvFile.onNext(fileURL)
            } catch {
                print("error creating file")
            }
        } else {
            startGatDataTimer()
        }
    }
    
    func updateTimerSeconds(seconds: Int) {
        self.timerDelay = seconds
        
        if isRecord {
            startGatDataTimer()
        }
    }
    
    func updateObserverDataSource(index: Int) {
        switch index {
        case 0:
            observerDataSource = .ValveCurrent
        case 1:
            observerDataSource = .Rpm
        case 2:
            observerDataSource = .MotorTorques
        case 3:
            observerDataSource = .MotorTemperatures
        default:
            observerDataSource = .ModuleTemperatures
        }
    }
    
    func getRpmsFirst() -> Int { rpms[0] }
    
    func getValveCurrentsFirst() -> Float { valveCurrents[0] }
    
    func getMotorTorquesFirst() -> Float { motorTorques[0] }
    
    func getMotorTemperaturesFirst() -> Float { motorTemperatures[0] }
    
    func getMouleTemperaturesFirst() -> Float { moduleTemperatures[0] }
    
    func getRpms() -> [Int] { rpms }
    
    func getValveCurrents() -> [Float] { valveCurrents }
    
    func getMotorTorques() -> [Float] { motorTorques }
    
    func getMotorTemperatures() -> [Float] { motorTemperatures }
    
    func getMouleTemperatures() -> [Float] { moduleTemperatures }
    
    func updateTimeLines(milisec: Double) {
        timeLines.append(milisec)
        
        if timeLines.count > 11 {
            timeLines.remove(at: 0)
        }
    }
    
    func getTimeLineCount() -> Int { timeLines.count }
    
    func getFirstTimeLine() -> Double { timeLines[0] }
    
    func getTimeLineIndex(index: Int) -> Double { timeLines[index] }
}

extension MonitorViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            stopGatDataTimer()
            monitorStatus.onNext(.DisConnect)
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
        monitorStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        
        if length == 20 {
            
            timeSecond = Date().timeIntervalSince1970
            updateTimeLines(milisec: timeSecond)
            
            let valveCurrent: Float = ConvertManager.byte2Float(bytes: [UInt8](data[0...3]))
            updateDataArray(dataSource: .ValveCurrent, value: valveCurrent)
            
            let motorTorque: Float = ConvertManager.byte2Float(bytes: [UInt8](data[8...11]))
            updateDataArray(dataSource: .MotorTorques, value: motorTorque)
            
            let moduleTemperature: Float = ConvertManager.byte2Float(bytes: [UInt8](data[12...15]))
            updateDataArray(dataSource: .ModuleTemperatures, value: moduleTemperature)
            
            let motorTemperature: Float = ConvertManager.byte2Float(bytes: [UInt8](data[16...19]))
            updateDataArray(dataSource: .MotorTemperatures, value: motorTemperature)
            
            if isRecord {
                csvDatas.append((DateFormatUtil.dateFormat(milSecond: timeSecond),
                                 valveCurrent,
                                 motorTorque,
                                 moduleTemperature,
                                 motorTemperature,
                                 0))
            }
            
            
            switch observerDataSource {
            case .ValveCurrent:
                self.valveCurrent.onNext((getFirstTimeLine(), valveCurrent, timeSecond))
            case .MotorTorques:
                self.motorTorque.onNext((getFirstTimeLine(), motorTorque, timeSecond))
            case .MotorTemperatures:
                self.motorTemperature.onNext((getFirstTimeLine(), motorTemperature, timeSecond))
            case .ModuleTemperatures:
                self.moduleTemperature.onNext((getFirstTimeLine(), moduleTemperature, timeSecond))
            default:
                break
            }
            
            BLEManager.default.writeBytes(content: self.getMotorRPMCmd, mode: .Read)
        } else if length == 2 {
            
            let rpm: Int = Int(ConvertManager.byte2UInt16(bytes: data))
            updateDataArray(dataSource: .Rpm, value: rpm)
            
            if isRecord {
                csvDatas[csvDatas.count - 1].5 = rpm
            }
            
            if observerDataSource == .Rpm {
                self.rpm.onNext((getFirstTimeLine(), rpm, timeSecond))
            }
        }
    }
    
}
