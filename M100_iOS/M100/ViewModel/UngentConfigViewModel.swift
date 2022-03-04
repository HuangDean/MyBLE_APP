import CoreBluetooth
import RxSwift

final class UngentConfigViewModel: BaseViewModel {
    
    private let getMotorTempeatureAlarmCmd = [UInt8]([0x10, 0x8E, 0x00, 0x1B]) // 4238~4264
//    private let getMotorTempeatureAlarmCmd = [UInt8]([0x10, 0x8E, 0x00, 0x02]) // 4238~4239
//    private let getOpenSignalActionCmd = [UInt8]([0x10, 0x9A, 0x00, 0x01]) // 4250
//    private let getUngentActionModeCmd = [UInt8]([0x10, 0x9D, 0x00, 0x03]) // 4253~4254 num實際2
//    private let getUngentInputMode = [UInt8]([0x10, 0xA8, 0x00, 0x04]) // 4264 num實際1
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var saveOpenSignalActionCmd = [UInt8]([0x10, 0x9D, 0x00, 0x01, 0x02])
    private var setUngentActionCmd = [UInt8]([0x10, 0x9E, 0x00, 0x01, 0x02])
    private var setSignalUngentCmd = [UInt8]([0x10, 0x9A, 0x00, 0x01, 0x02])
    private var setsetmotorWarningSwitchCmd = [UInt8]([0x10, 0x8F, 0x00, 0x01, 0x02])
    private var setmotorWarningTempCmd = [UInt8]([0x10, 0x8E, 0x00, 0x01, 0x02])
    private var setUngentIntputSwitchCmd = [UInt8]([0x10, 0xA8, 0x00, 0x01, 0x02])
    
    let ungentConfigStatus = PublishSubject<BaseStatus>()
    let openSignalAction = PublishSubject<String>()
    let ungentAction = PublishSubject<String>()
    let signalUngentPosition = PublishSubject<String>()
    let motorWarningTempeature = PublishSubject<String>()
    let motorWarningSwitch = PublishSubject<Bool>()
    let ungentIntputSwitch = PublishSubject<Int>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
    private var isWrite: Bool = false

    override init() {
        super.init()
        BLEManager.default.delegate = self
    }
    
    private func starTimtout(timeout: Double) {
        timer = Timer.scheduledTimer(timeInterval: timeout,
                             target: self,
                             selector: #selector(self.timeout),
                             userInfo: nil,
                             repeats: false)
    }

    @objc private func timeout() {
        isWrite = true
        
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
            self.ungentConfigStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            ungentConfigStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getMotorTempeatureAlarmCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            ungentConfigStatus.onNext(.DisConnect)
        }
    }
    
    func didSave(index: Int, value: String) {
        if !BLEManager.default.isConnecting() { return }
        
        self.ungentConfigStatus.onNext(.Loading)

        switch index {
        case 0: formatIntData(cmd: saveOpenSignalActionCmd, data: value)
        case 1: formatIntData(cmd: setUngentActionCmd, data: value)
        case 2: formatIntData(cmd: setSignalUngentCmd, data: value)
        case 3: formatIntData(cmd: setsetmotorWarningSwitchCmd, data: value)
        case 4: formatIntData(cmd: setmotorWarningTempCmd, data: value)
        case 5: formatIntData(cmd: setUngentIntputSwitchCmd, data: value)
        default: return
        }
    }
    
}

// MARK: - Delegate

extension UngentConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            ungentConfigStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        ungentConfigStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        
        switch length {
        case 54:
            retryCount = 0
        
            //
            motorWarningTempeature.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1]))))
            
            if ConvertManager.byte2UInt16(bytes: [UInt8](data[2...3])) == 0 {
                motorWarningSwitch.onNext(false)
            } else {
                motorWarningSwitch.onNext(true)
            }
            
            //
            signalUngentPosition.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[24...25]))))
            
            //
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[30...31])) {
            case 0:
                openSignalAction.onNext(getResString("ungent_config_open_signal_action1"))
            case 1:
                openSignalAction.onNext(getResString("ungent_config_open_signal_action2"))
            case 2:
                openSignalAction.onNext(getResString("ungent_config_open_signal_action3"))
            default:
                break
            }
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[32...33])) {
            case 0:
                ungentAction.onNext(getResString("ungent_config_ungent_action1"))
            case 1:
                ungentAction.onNext(getResString("ungent_config_ungent_action2"))
            case 2:
                ungentAction.onNext(getResString("ungent_config_ungent_action3"))
            case 3:
                ungentAction.onNext(getResString("ungent_config_ungent_action4"))
            default:
                break
            }
            
            //
            ungentIntputSwitch.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[52...53]))))
            
            if !isWrite {
                if let timer = self.timer {
                    timer.invalidate()
                }
            }
            
            ungentConfigStatus.onNext(.Complete)
            
            isWrite = true
        default:
            break
        }
        
        if isWrite {
            if let timer = self.timer {
                timer.invalidate()
            }
        }
    }
}

