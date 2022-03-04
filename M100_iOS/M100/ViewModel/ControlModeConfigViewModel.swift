import CoreBluetooth
import RxSwift

final class ControlModeConfigViewModel: BaseViewModel {
    
    private let getInput1ModeCmd = [UInt8]([0x10, 0xA3, 0x00, 0x15]) // 4259~4278
//    private let getInput1ModeCmd = [UInt8]([0x10, 0xA3, 0x00, 0x0A]) // 4259~4268
//    private let getRemoteModeCmd = [UInt8]([0x10, 0xB6, 0x00, 0x02]) // 4278
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setRemoteControlEnableCmd = [UInt8]([0x10, 0xB6, 0x00, 0x01, 0x02])
    private var setRemoteControlModeCmd = [UInt8]([0x10, 0xB7, 0x00, 0x01, 0x02])
    private var setInputSensitivityCmd = [UInt8]([0x10, 0xA7, 0x00, 0x01, 0x02])
    private var setDigitalInputEnableCmd = [UInt8]([0x10, 0xA9, 0x00, 0x01, 0x02])
    private var setDigitalInputCmd = [UInt8]([0x10, 0xAC, 0x00, 0x01, 0x02])
    private var setProportionalInputCmd = [UInt8]([0x10, 0xAA, 0x00, 0x01, 0x02])
    private var setProportionalOutputCmd = [UInt8]([0x10, 0xAB, 0x00, 0x01, 0x02])
    private var setInputModeConfig1Cmd = [UInt8]([0x10, 0xA3, 0x00, 0x01, 0x02])
    private var setInputModeConfig2Cmd = [UInt8]([0x10, 0xA4, 0x00, 0x01, 0x02])
    private var setOutputModeConfig1Cmd = [UInt8]([0x10, 0xA5, 0x00, 0x01, 0x02])
    private var setOutputModeConfig2Cmd = [UInt8]([0x10, 0xA6, 0x00, 0x01, 0x02])
    
    let controlModeConfigStatus = PublishSubject<BaseStatus>()
    let inputModeConfig = PublishSubject<Int>()
    let outputConfig = PublishSubject<Int>()
    let inputSensitivity = PublishSubject<Float>()
    let digitalInputEnable = PublishSubject<Int>()
    let proportionalInput = PublishSubject<String>()
    let proportionalOutput = PublishSubject<String>()
    let digitalInput = PublishSubject<String>()
    let remoteControlModeSwitch = PublishSubject<Bool>()
    let remoteControlMode = PublishSubject<Int>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
    private var isInputSignalChannel1: Bool = true
    private var digitalInputMode: Int = 0
    private var proportionalInputMode: Int = 0
    private var proportionalOutputMode: Int = 0
    
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
        if retryCount < 1 {
            retryCount += 1
            didGetData()
        } else {
            BLEManager.default.disconnect()
        }
    }
    
    private func formatIntData(cmd: [UInt8], data: String) {
        var cmd = cmd
        if let dataBytes = ConvertManager.uint2byte(from: UInt16(data)) {
            for i in stride(from: 0, to: dataBytes.count, by: 2) {
                cmd.append(dataBytes[i + 1])
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
            self.controlModeConfigStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func getDigitalInputMode() -> Int { digitalInputMode }
    
    func setDigitalInputMode(value: Int) { digitalInputMode = value }
    
    func getProportionalInputMode() -> Int { proportionalInputMode }
    
    func setProportionalInputMode(value: Int) { proportionalInputMode = value }
    
    func getProportionalOutputMode() -> Int { proportionalOutputMode }
    
    func setProportionalOutputMode(value: Int) { proportionalOutputMode = value }
    
    func didChangeChannel() {
        isInputSignalChannel1 = !isInputSignalChannel1
        didGetData()
    }
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            controlModeConfigStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getInput1ModeCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            controlModeConfigStatus.onNext(.DisConnect)
        }
    }
    
    func didSave(index: Int, value: String = "") {
        if !BLEManager.default.isConnecting() { return }
        
        self.controlModeConfigStatus.onNext(.Loading)
        
        switch index {
        case 0:
            formatIntData(cmd: setRemoteControlEnableCmd, data: value)
        case 1:
            formatIntData(cmd: setRemoteControlModeCmd, data: value)
        case 2:
            formatIntData(cmd: setInputSensitivityCmd, data: value)
        case 3:
            formatIntData(cmd: setDigitalInputEnableCmd, data: value)
        case 4:
            if digitalInputMode == 0 {
                digitalInputMode = 1
                formatIntData(cmd: setDigitalInputCmd, data: String(digitalInputMode))
            } else if digitalInputMode == 1 {
                digitalInputMode = 2
                formatIntData(cmd: setDigitalInputCmd, data: String(digitalInputMode))
            } else {
                digitalInputMode = 0
                formatIntData(cmd: setDigitalInputCmd, data: String(digitalInputMode))
            }
        case 5:
            if proportionalInputMode == 0 {
                proportionalInputMode = 1
                formatIntData(cmd: setProportionalInputCmd, data: String(proportionalInputMode))
            } else if proportionalInputMode == 1 {
                proportionalInputMode = 2
                formatIntData(cmd: setProportionalInputCmd, data: String(proportionalInputMode))
            } else {
                proportionalInputMode = 0
                formatIntData(cmd: setProportionalInputCmd, data: String(proportionalInputMode))
            }
        case 6:
            if proportionalOutputMode == 0 {
                proportionalOutputMode = 1
                formatIntData(cmd: setProportionalOutputCmd, data: String(proportionalOutputMode))
            } else if proportionalOutputMode == 1 {
                proportionalOutputMode = 2
                formatIntData(cmd: setProportionalOutputCmd, data: String(proportionalOutputMode))
            } else {
                proportionalOutputMode = 0
                formatIntData(cmd: setProportionalOutputCmd, data: String(proportionalOutputMode))
            }
        case 7:
            if isInputSignalChannel1 {
                formatIntData(cmd: setInputModeConfig1Cmd, data: value)
            } else {
                formatIntData(cmd: setInputModeConfig2Cmd, data: value)
            }
        case 8:
            if isInputSignalChannel1 {
                formatIntData(cmd: setOutputModeConfig1Cmd, data: value)
            } else {
                formatIntData(cmd: setOutputModeConfig2Cmd, data: value)
            }
        default: return
        }
    }
}

// MARK: - Delegate

extension ControlModeConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            controlModeConfigStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        controlModeConfigStatus.onNext(.DisConnect)
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
        case 42:
            retryCount = 0
            
            // 1
            if isInputSignalChannel1 {
                inputModeConfig.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1]))))
                outputConfig.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[4...5]))))
            } else {
                inputModeConfig.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[2...3]))))
                outputConfig.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[6...7]))))
            }
            
            inputSensitivity.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[8...9]))))
            digitalInputEnable.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[12...13]))))
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[14...15])) {
            case 1:
                proportionalInputMode = 1
                proportionalInput.onNext(NSLocalizedString("ch1", comment: ""))
            case 2:
                proportionalInputMode = 2
                proportionalInput.onNext(NSLocalizedString("ch2", comment: ""))
            default:
                proportionalInputMode = 0
                proportionalInput.onNext(NSLocalizedString("disable", comment: ""))
            }
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[16...17])) {
            case 1:
                proportionalOutputMode = 1
                proportionalOutput.onNext(NSLocalizedString("ch1", comment: ""))
            case 2:proportionalOutputMode = 2
                proportionalOutput.onNext(NSLocalizedString("ch2", comment: ""))
            default:
                proportionalOutputMode = 0
                proportionalOutput.onNext(NSLocalizedString("disable", comment: ""))
            }
            
            switch ConvertManager.byte2UInt16(bytes: [UInt8](data[18...19])) {
            case 1:
                digitalInputMode = 1
                digitalInput.onNext(NSLocalizedString("ch1", comment: ""))
            case 2:
                digitalInputMode = 2
                digitalInput.onNext(NSLocalizedString("ch2", comment: ""))
            default:
                digitalInputMode = 0
                digitalInput.onNext(NSLocalizedString("disable", comment: ""))
            }
            
            // 2
            if ConvertManager.byte2UInt16(bytes: [UInt8](data[38...39])) == 1 {
                remoteControlModeSwitch.onNext(true)
            }
            
            remoteControlMode.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[40...41]))))
            controlModeConfigStatus.onNext(.Complete)
        default:
            break
        }
    }
}

