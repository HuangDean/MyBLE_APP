import CoreBluetooth
import RxSwift

enum MainStatus {
    case Connecting
    case ConnectFailed
    case LoginFailed
    case Unlogined
    case General
    case Dealer
    case Developer
    case DisConnect
}

final class MainViewModel: BaseViewModel {
    
    private let getGeneralPasswordCmd = [UInt8]([0x10, 0x5C, 0x00, 0x01])
    private let getDealerPasswordCmd = [UInt8]([0x10, 0x5D, 0x00, 0x01])
    
    private let getValveRealPositionCmd = [UInt8]([0x10, 0x06, 0x00, 0x56]) // 12: 4102~4187
//    private let getValveRealPositionCmd = [UInt8]([0x10, 0x06, 0x00, 0x0C]) // 12: 4102~4112
//    private let getSoftwareVersionCmd = [UInt8]([0x10, 0x16, 0x00, 0x16]) // 22: 4118~4138
//    private let getMotorRPMCmd = [UInt8]([0x10, 0x5B, 0x00, 0x02]) // 2: 4187~4188
    
    let mainStatus = PublishSubject<MainStatus>()
    let rpm = PublishSubject<Int>()
    let valveCurrent = PublishSubject<Float>()
    let valveTarget = PublishSubject<Float>()
    let correctionMotorTorque = PublishSubject<Float>()
    let motorTorque = PublishSubject<Float>()
    let motorTemperature = PublishSubject<Float>()
    let systemErrorStatus = PublishSubject<Int>()
    let moduleTemperature = PublishSubject<Float>()
    let version = PublishSubject<String>()
    let valveStatus = PublishSubject<String>()
    
    private var peripheral: CBPeripheral!
    private var permission: Permission!
    private var password: String!
    
    private var isLogin: Bool = false
    private var isTimeout: Bool = false
    
    // system status, error
    private var systemStatues: [Int]!
    private var systemErrors: [Int]!
    
    override init() {
        super.init()
        BLEManager.default.delegate = self
    }
    
    private func startGatDataTimer() {
        if !isLogin { return }
        
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { second in
                BLEManager.default.writeBytes(content: self.getValveRealPositionCmd, mode: .Read)
            }).disposed(by: disposeBag)
    }
    
    private func stopGatDataTimer() {
        disposeBag = DisposeBag()
    }
    
    func getSystemStatuses() -> [Int] { systemStatues ?? [Int]() }
    
    private func updateSystemStatuses(value: Int) {
        let binaryStr = String(ConvertManager.int2Binary(value: value).reversed())
        systemStatues = binaryStr.indices(of: "1")
    }
    
    func getSystemErrors() -> [Int] { systemErrors ?? [Int]() }
    
    private func updateSystemErrors(value: Int) {
        let binaryStr = String(ConvertManager.int2Binary(value: value).reversed())
        systemErrors = binaryStr.indices(of: "1")
    }
    
    // MARK: - View Events
    
    func didSelectPeripheral(peripheral: CBPeripheral, permission: Permission, password: String) {
        self.peripheral = peripheral
        self.permission = permission
        self.password = password
        self.isTimeout = true
        
        // set login timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            if self.isTimeout {
                self.mainStatus.onNext(.ConnectFailed)
                BLEManager.default.disconnect()
            }
        }
        
        mainStatus.onNext(.Connecting)
        BLEManager.default.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            BLEManager.default.connect(peripheral: peripheral)
        }
    }
    
    func didPresentVC() {
        stopGatDataTimer()
    }
    
    func didAppear() {
        BLEManager.default.delegate = self
        
        if isLogin && !BLEManager.default.isConnecting() {
            mainStatus.onNext(.DisConnect)
            return
        }
        
        startGatDataTimer()
    }
}

// MARK: - Delegate

extension MainViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        switch centralState {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            if isLogin {
                mainStatus.onNext(.Unlogined)
            } else {
                mainStatus.onNext(.DisConnect)
            }
            
            isLogin = false
            stopGatDataTimer()
        case .poweredOn:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
        mainStatus.onNext(.ConnectFailed)
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        isLogin = false
        stopGatDataTimer()
        mainStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
        switch permission {
        case .General:
            BLEManager.default.writeBytes(content: self.getGeneralPasswordCmd, mode: .Read)
        default:
            BLEManager.default.writeBytes(content: self.getDealerPasswordCmd, mode: .Read)
        }
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        self.isTimeout = false
        
        switch length {
        case 2:
            // login password verification
            if permission != .Developer && self.password != String(ConvertManager.byte2UInt16(bytes: data)) {
                BLEManager.default.disconnect(peripheral: peripheral)
                mainStatus.onNext(.LoginFailed)
                return
            }
            
            if permission == .Developer && self.password != "2293" {
                BLEManager.default.disconnect(peripheral: peripheral)
                mainStatus.onNext(.LoginFailed)
                return
            }
            
            // login success
            UserDefaults.standard.set(peripheral.name, forKey: "deviceName")
            UserDefaults.standard.set(password, forKey: "password")
            
            switch permission {
            case .General:
                mainStatus.onNext(.General)
                UserDefaults.standard.set(0, forKey: "permission")
            case .Dealer:
                mainStatus.onNext(.Dealer)
                UserDefaults.standard.set(1, forKey: "permission")
            default:
                mainStatus.onNext(.Developer)
                UserDefaults.standard.set(2, forKey: "permission")
            }
            
            isLogin = true
            startGatDataTimer()
        case 172:
            motorTorque.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[8...11])))
            //motorTemperature.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[12...15])))
            systemErrorStatus.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[16...19]))))
            updateSystemErrors(value: Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[16...19]))))
            updateSystemStatuses(value: Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[20...23]))))
            
            version.onNext(ConvertManager.byte2UTF8(bytes: [UInt8](data[32...39])))
            // print("40 irSoftwareVersion: \(ConvertManager.byte2UTF8(bytes: [UInt8](data[8...15])))")
            valveStatus.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[48...49]))))
            valveCurrent.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[56...59])))
            valveTarget.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[60...63])))
            correctionMotorTorque.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[64...67])))
            moduleTemperature.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[68...71])))
            motorTemperature.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[72...75])))
            
            rpm.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[170...171]))))
        default:
            break
        }
    }
}

