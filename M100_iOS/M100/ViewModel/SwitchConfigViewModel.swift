import CoreBluetooth
import RxSwift

final class SwitchConfigViewModel: BaseViewModel {
    
    private let getValveOffOutputRpmCmd = [UInt8]([0x10, 0x57, 0x00, 0x4C]) // 4183~4258
//    private let getValveOffOutputRpmCmd = [UInt8]([0x10, 0x90, 0x00, 0x13]) // 4240~4258
//    private let getLimitOffPositionCmd = [UInt8]([0x10, 0x57, 0x00, 0x04]) // 4183 num:2 (limit position 表未更新
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setOutputRpmOffCmd = [UInt8]([0x10, 0x90, 0x00, 0x01, 0x02])
    private var setOutputRpmOnCmd = [UInt8]([0x10, 0x91, 0x00, 0x01, 0x02])
    private var setUngentRpmOffCmd = [UInt8]([0x10, 0x92, 0x00, 0x01, 0x02])
    private var setUngentRpmOnCmd = [UInt8]([0x10, 0x93, 0x00, 0x01, 0x02])
    private var setRangeOfEndTorqueOffCmd = [UInt8]([0x10, 0x94, 0x00, 0x01, 0x02])
    private var setRangeOfEndTorqueOnCmd = [UInt8]([0x10, 0x95, 0x00, 0x01, 0x02])
    private var setStrokeTorqueOffCmd = [UInt8]([0x10, 0x96, 0x00, 0x01, 0x02])
    private var setStrokeTorqueOnCmd = [UInt8]([0x10, 0x97, 0x00, 0x01, 0x02])
    private var setRangeOfEndOffCmd = [UInt8]([0x10, 0x98, 0x00, 0x01, 0x02])
    private var setRangeOfEndOnCmd = [UInt8]([0x10, 0x99, 0x00, 0x01, 0x02])
    private var setTorqueRetryOffCmd = [UInt8]([0x10, 0x9B, 0x00, 0x01, 0x02])
    private var setTorqueRetryOnCmd = [UInt8]([0x10, 0x9C, 0x00, 0x01, 0x02])
    private var setCloseDefinitionCmd = [UInt8]([0x10, 0x9F, 0x00, 0x01, 0x02])
    private var setRangeOfEndModeOffCmd = [UInt8]([0x10, 0xA0, 0x00, 0x01, 0x02])
    private var setRangeOfEndModeOnCmd = [UInt8]([0x10, 0xA1, 0x00, 0x01, 0x02])
    private var setCloseTightlyEnableCmd = [UInt8]([0x10, 0xA2, 0x00, 0x01, 0x02])
    private var setLimitOffPositionOffCmd = [UInt8]([0x10, 0x57, 0x00, 0x02, 0x04])
    private var setLimitOffPositionOnCmd = [UInt8]([0x10, 0x59, 0x00, 0x02, 0x04])
    
    let switchConfigStatus = PublishSubject<BaseStatus>()
    let outputRpm = PublishSubject<Float>()
    let ungentRpm = PublishSubject<Float>()
    let rangeOfEndOff = PublishSubject<Float>()
    let rangeOfEndOn = PublishSubject<Float>()
    let limit = PublishSubject<Float>()
    let torqueRetry = PublishSubject<String>()
    let rangeOfEndMode = PublishSubject<String>()
    let rangeOfEndTorqueOff = PublishSubject<String>()
    let rangeOfEndTorqueOn = PublishSubject<String>()
    let strokeTorqueOff = PublishSubject<String>()
    let strokeTorqueOn = PublishSubject<String>()
    let closeTightly = PublishSubject<Int>()
    let closeDefinition = PublishSubject<String>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
    private var isOpenStatus: Bool = false // 開關向狀態

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
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            switchConfigStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getValveOffOutputRpmCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            switchConfigStatus.onNext(.DisConnect)
        }
    }
    
    func didCenterSwitch() {
        isOpenStatus = !isOpenStatus
        didGetData()
    }
    
    func isOpen() -> Bool { isOpenStatus }
    
    private func formatIntData(cmd: [UInt8], data: String) {
        var cmd = cmd
        if let dataBytes = ConvertManager.uint2byte(from: UInt16(data)) {
            for i in stride(from: 0, to: dataBytes.count, by: 2) {
                cmd.append(dataBytes[i+1])
                cmd.append(dataBytes[i])
            }
            
            setData(cmd: cmd)
        }
    }
    
    private func formatUInt32Data(cmd: [UInt8], data: String) {
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
            self.switchConfigStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didSave(index: Int, value: String = "") {
        if !BLEManager.default.isConnecting() { return }
        
        self.switchConfigStatus.onNext(.Loading)
        
        if !isOpenStatus {
            switch index {
            case 0: formatIntData(cmd: setOutputRpmOffCmd, data: value)
            case 1: formatIntData(cmd: setUngentRpmOffCmd, data: value)
            case 2: formatIntData(cmd: setRangeOfEndOffCmd, data: value)
            // case 3: read only
            case 4: formatIntData(cmd: setTorqueRetryOffCmd, data: value)
            case 5: formatIntData(cmd: setRangeOfEndModeOffCmd, data: value)
            case 6: formatIntData(cmd: setRangeOfEndTorqueOffCmd, data: value)
            case 7: formatIntData(cmd: setStrokeTorqueOffCmd, data: value)
            case 8: formatIntData(cmd: setCloseTightlyEnableCmd, data: value)
            case 9: formatIntData(cmd: setCloseDefinitionCmd, data: value)
            default:break
            }
            
        } else {
            switch index {
            case 0: formatIntData(cmd: setOutputRpmOnCmd, data: value)
            case 1: formatIntData(cmd: setUngentRpmOnCmd, data: value)
            case 2: formatIntData(cmd: setRangeOfEndOnCmd, data: value)
            // case 3: read only
            case 4: formatIntData(cmd: setTorqueRetryOnCmd, data: value)
            case 5: formatIntData(cmd: setRangeOfEndModeOnCmd, data: value)
            case 6: formatIntData(cmd: setRangeOfEndTorqueOnCmd, data: value)
            case 7: formatIntData(cmd: setStrokeTorqueOnCmd, data: value)
            case 8: formatIntData(cmd: setCloseTightlyEnableCmd, data: value)
            case 9: formatIntData(cmd: setCloseDefinitionCmd, data: value)
            default:break
            }
        }
        
    }
}

// MARK: - Delegate

extension SwitchConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            switchConfigStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        switchConfigStatus.onNext(.DisConnect)
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
        case 152:
            retryCount = 0
        
            // 1
            if !isOpenStatus {
                limit.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[0...3])))
            } else {
                limit.onNext(ConvertManager.byte2Float(bytes: [UInt8](data[4...7])))
            }
            
            // 2
            rangeOfEndTorqueOff.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[122...123]))))
            rangeOfEndTorqueOn.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[124...125]))))

            strokeTorqueOff.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[126...127]))))
            strokeTorqueOn.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[128...129]))))

            rangeOfEndOff.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[130...131]))))
            rangeOfEndOn.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[132...133]))))
            
            if !isOpenStatus {
                outputRpm.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[114...115]))))
                ungentRpm.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[118...119]))))
                torqueRetry.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[136...137]))))
                
                if ConvertManager.byte2UInt16(bytes: [UInt8](data[146...147])) == 0 {
                    rangeOfEndMode.onNext(getResString("switch_config_range_of_end_mode1"))
                } else {
                    rangeOfEndMode.onNext(getResString("switch_config_range_of_end_mode2"))
                }
                
            } else {
                outputRpm.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[116...117]))))
                ungentRpm.onNext(Float(ConvertManager.byte2UInt16(bytes: [UInt8](data[120...121]))))
                torqueRetry.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[138...139]))))
                
                if ConvertManager.byte2UInt16(bytes: [UInt8](data[148...149])) == 0 {
                    rangeOfEndMode.onNext(getResString("switch_config_range_of_end_mode1"))
                } else {
                    rangeOfEndMode.onNext(getResString("switch_config_range_of_end_mode2"))
                }
                
            }
            
            if ConvertManager.byte2UInt16(bytes: [UInt8](data[144...145])) == 0 {
                closeDefinition.onNext("CCW")
            } else {
                closeDefinition.onNext("CW")
            }
            
            closeTightly.onNext(Int(ConvertManager.byte2UInt16(bytes: [UInt8](data[150...151])))) // 0:off 1:on
            
            switchConfigStatus.onNext(.Complete)
        default:
            break
        }
    }
}

