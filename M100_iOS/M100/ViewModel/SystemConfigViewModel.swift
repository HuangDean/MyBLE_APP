import CoreBluetooth
import RxSwift

final class SystemConfigViewModel: BaseViewModel {
    
    private let getLanguageCmd = [UInt8]([0x10, 0x8C, 0x00, 0x30]) // 4236~4283
//    private let getLanguageCmd = [UInt8]([0x10, 0x8C, 0x00, 0x02]) // 4236~4237
//    private let getAcVoltagePhaseCmd = [UInt8]([0x10, 0xB9, 0x00, 0x03]) // 4281~4283
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setLanguageCmd = [UInt8]([0x10, 0x8C, 0x00, 0x01, 0x02])
    private var setmaxOutputTorqueCmd = [UInt8]([0x10, 0x8D, 0x00, 0x01, 0x02])
    private var setacVoltagePhaseCmd = [UInt8]([0x10, 0xB9, 0x00, 0x01, 0x02])
    private var setacVoltageConfigCmd = [UInt8]([0x10, 0xBA, 0x00, 0x01, 0x02])
    private var setLightDefinitionCmd = [UInt8]([0x10, 0xBB, 0x00, 0x01, 0x02])
    
    let systemConfigStatus = PublishSubject<BaseStatus>()
    let language = PublishSubject<String>()
    let lightDefinition = PublishSubject<String>()
    let maxOutputTorque = PublishSubject<String>()
    let acVoltagePhase = PublishSubject<String>()
    let acVoltageConfig = PublishSubject<String>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
    override init() {
        super.init()
        BLEManager.default.delegate = self
    }
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            systemConfigStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getLanguageCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            systemConfigStatus.onNext(.DisConnect)
        }
    }
    
    private func starTimtout(timeout: Double) {
        timer = Timer.scheduledTimer(timeInterval: timeout,
                                     target: self,
                                     selector: #selector(self.timeout),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc private func timeout() {
        if retryCount < 1 {
            retryCount += 1
            didGetData()
        } else {
            BLEManager.default.disconnect()
        }
    }
    
    private func formatIntData(cmd: [UInt8], data: String) {
        var cmd = cmd
        if let dataBytes = ConvertManager.uint2byte(from: UInt32(data)) {
            for i in stride(from: 0, to: dataBytes.count, by: 2) {
                cmd.append(dataBytes[i+1])
                cmd.append(dataBytes[i])
            }
            
            setData(cmd: cmd)
        }
    }
    
    private func setData(cmd: [UInt8]) {
        DispatchQueue.background(delay: 0.5, background: {
            BLEManager.default.writeBytes(content: cmd, mode: .Write)
        }, completion: {
            BLEManager.default.writeBytes(content: self.saveCmd, mode: .Write)
            self.systemConfigStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didSave(index: Int, value: String) {
        if !BLEManager.default.isConnecting() { return }
        
        self.systemConfigStatus.onNext(.Loading)

        switch index {
        case 0: formatIntData(cmd: setLanguageCmd, data: value)
        case 1: formatIntData(cmd: setLightDefinitionCmd, data: value)
        case 2: formatIntData(cmd: setmaxOutputTorqueCmd, data: value)
        case 3: formatIntData(cmd: setacVoltagePhaseCmd, data: value)
        case 4: formatIntData(cmd: setacVoltageConfigCmd, data: value)
        default: return
        }
    }
}

// MARK: - Delegate

extension SystemConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            systemConfigStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        systemConfigStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        switch length {
        case 96:
            retryCount = 0
        
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1])) {
            case 0:
                self.language.onNext(getResString("system_config_english"))
            case 1:
                self.language.onNext(getResString("system_config_chinese_traditional"))
            case 2:
                self.language.onNext(getResString("system_config_chinese_simplified"))
            default:
                break
            }
            
            maxOutputTorque.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[2...3]))))
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[90...91])) {
            case 0:
                acVoltagePhase.onNext(getResString("system_config_three_phase"))
            case 1:
                acVoltagePhase.onNext(getResString("system_config_signle_phase"))
            default: break
            }
            
            acVoltageConfig.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[92...93]))))
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[94...95])) {
            case 0:
                lightDefinition.onNext(getResString("system_config_red_light"))
            case 1:
                lightDefinition.onNext(getResString("system_config_red_green"))
            default: break
            }
            
            systemConfigStatus.onNext(.Complete)
        default:
            break
        }
    }
}

