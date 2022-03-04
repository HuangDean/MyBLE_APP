import CoreBluetooth
import RxSwift

final class OutputConfigViewModel: BaseViewModel {
    
    private let getDigitOutputChannelCmd = [UInt8]([0x10, 0xAD, 0x00, 0x09]) // 4269~4277
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setOutputChannelCmd = [UInt8]([0x10, 0xAD, 0x00, 0x01, 0x02])
    private var setChannel1Output1Cmd = [UInt8]([0x10, 0xAE, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel1Output2Cmd = [UInt8]([0x10, 0xAF, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel1Output3Cmd = [UInt8]([0x10, 0xB0, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel1Output4Cmd = [UInt8]([0x10, 0xB1, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel2Output1Cmd = [UInt8]([0x10, 0xB2, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel2Output2Cmd = [UInt8]([0x10, 0xB3, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel2Output3Cmd = [UInt8]([0x10, 0xB4, 0x00, 0x01, 0x02, 0x00, 0x00])
    private var setChannel2Output4Cmd = [UInt8]([0x10, 0xB5, 0x00, 0x01, 0x02, 0x00, 0x00])
    
    let outputConfigStatus = PublishSubject<BaseStatus>()
    let output1 = PublishSubject<Int>()
    let output2 = PublishSubject<Int>()
    let output3 = PublishSubject<Int>()
    let output4 = PublishSubject<Int>()
    let output1Status = PublishSubject<Bool>()
    let output2Status = PublishSubject<Bool>()
    let output3Status = PublishSubject<Bool>()
    let output4Status = PublishSubject<Bool>()
//    let digitalOutputChannel = PublishSubject<String>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
    private var isChannel1: Bool = true
    private var isOutput1On: Bool = false
    private var isOutput2On: Bool = false
    private var isOutput3On: Bool = false
    private var isOutput4On: Bool = false
    private var outputChannelMode: Int = 0
    
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
    
    func didChangeChannel() {
        isChannel1 = !isChannel1
        didGetData()
    }
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            outputConfigStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getDigitOutputChannelCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            outputConfigStatus.onNext(.DisConnect)
        }
    }
    
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
    
    private func setData(cmd: [UInt8]) {
        DispatchQueue.background(delay: 0.5, background: {
            BLEManager.default.writeBytes(content: cmd, mode: .Write)
        }, completion: {
            BLEManager.default.writeBytes(content: self.saveCmd, mode: .Write)
            self.outputConfigStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didSave(index: Int, value: String = "") {
        if !BLEManager.default.isConnecting() { return }
        
        self.outputConfigStatus.onNext(.Loading)
        
        if isChannel1 {
            switch index {
            case 1:
                isOutput1On = !isOutput1On
                setChannel1Output1Cmd[5] = isOutput1On ? 0x00 : 0x80
                setData(cmd: setChannel1Output1Cmd)
                output1Status.onNext(isOutput1On)
            case 2:
                setChannel1Output1Cmd[6] = UInt8(value)!
                setData(cmd: setChannel1Output1Cmd)
            case 3:
                isOutput2On = !isOutput2On
                setChannel1Output2Cmd[5] = isOutput2On ? 0x00 : 0x80
                setData(cmd: setChannel1Output2Cmd)
                output2Status.onNext(isOutput2On)
            case 4:
                setChannel1Output2Cmd[6] = UInt8(value)!
                setData(cmd: setChannel1Output2Cmd)
            case 5:
                isOutput3On = !isOutput3On
                setChannel1Output3Cmd[5] = isOutput3On ? 0x00 : 0x80
                setData(cmd: setChannel1Output3Cmd)
                output3Status.onNext(isOutput3On)
            case 6:
                setChannel1Output3Cmd[6] = UInt8(value)!
                setData(cmd: setChannel1Output3Cmd)
            case 7:
                isOutput4On = !isOutput4On
                setChannel1Output4Cmd[5] = isOutput4On ? 0x00 : 0x80
                setData(cmd: setChannel1Output4Cmd)
                output4Status.onNext(isOutput4On)
            case 8:
                setChannel1Output4Cmd[6] = UInt8(value)!
                setData(cmd: setChannel1Output4Cmd)
            default:
                break
            }
        } else {
            switch index {
            case 1:
                isOutput1On = !isOutput1On
                setChannel2Output1Cmd[5] = isOutput1On ? 0x00 : 0x80
                setData(cmd: setChannel2Output1Cmd)
                output1Status.onNext(isOutput1On)
            case 2:
                setChannel2Output1Cmd[6] = UInt8(value)!
                setData(cmd: setChannel2Output1Cmd)
            case 3:
                isOutput2On = !isOutput2On
                setChannel2Output2Cmd[5] = isOutput2On ? 0x00 : 0x80
                setData(cmd: setChannel2Output2Cmd)
                output2Status.onNext(isOutput2On)
            case 4:
                setChannel2Output2Cmd[6] = UInt8(value)!
                setData(cmd: setChannel2Output2Cmd)
            case 5:
                isOutput3On = !isOutput3On
                setChannel2Output3Cmd[5] = isOutput3On ? 0x00 : 0x80
                setData(cmd: setChannel2Output3Cmd)
                output3Status.onNext(isOutput3On)
            case 6:
                setChannel2Output3Cmd[6] = UInt8(value)!
                setData(cmd: setChannel2Output3Cmd)
            case 7:
                isOutput4On = !isOutput4On
                setChannel2Output4Cmd[5] = isOutput4On ? 0x00 : 0x80
                setData(cmd: setChannel2Output4Cmd)
                output4Status.onNext(isOutput4On)
            case 8:
                setChannel2Output4Cmd[6] = UInt8(value)!
                setData(cmd: setChannel2Output4Cmd)
            default: break
            }
        }
    }
    
    func getOutputChannelMode() -> Int {
        return outputChannelMode
    }
    
}

// MARK: - Delegate

extension OutputConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            outputConfigStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        outputConfigStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        if length == 18 {
            retryCount = 0
            
            if isChannel1 {
                isOutput1On = data[2] != 0 ? false : true
                isOutput2On = data[4] != 0 ? false : true
                isOutput3On = data[6] != 0 ? false : true
                isOutput4On = data[8] != 0 ? false : true
                
                setChannel1Output1Cmd[5] = data[2]
                setChannel1Output2Cmd[5] = data[4]
                setChannel1Output3Cmd[5] = data[6]
                setChannel1Output4Cmd[5] = data[8]
                setChannel1Output1Cmd[6] = data[3]
                setChannel1Output2Cmd[6] = data[5]
                setChannel1Output3Cmd[6] = data[7]
                setChannel1Output4Cmd[6] = data[9]
                
                output1Status.onNext(isOutput1On)
                output2Status.onNext(isOutput2On)
                output3Status.onNext(isOutput3On)
                output4Status.onNext(isOutput4On)
                
                output1.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[3]])))
                output2.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[5]])))
                output3.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[7]])))
                output4.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[9]])))
            } else {
                isOutput1On = data[10] != 0 ? false : true
                isOutput2On = data[12] != 0 ? false : true
                isOutput3On = data[14] != 0 ? false : true
                isOutput4On = data[16] != 0 ? false : true
                
                setChannel2Output1Cmd[5] = data[10]
                setChannel2Output2Cmd[5] = data[12]
                setChannel2Output3Cmd[5] = data[14]
                setChannel2Output4Cmd[5] = data[16]
                setChannel2Output1Cmd[6] = data[11]
                setChannel2Output2Cmd[6] = data[13]
                setChannel2Output3Cmd[6] = data[15]
                setChannel2Output4Cmd[6] = data[17]
                
                output1Status.onNext(isOutput1On)
                output2Status.onNext(isOutput2On)
                output3Status.onNext(isOutput3On)
                output4Status.onNext(isOutput4On)
                
                output1.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[11]])))
                output2.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[13]])))
                output3.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[15]])))
                output4.onNext(Int(ConvertManager.byte2UInt8(bytes: [data[17]])))
            }
            
            outputConfigStatus.onNext(.Complete)
        }
    }
}

