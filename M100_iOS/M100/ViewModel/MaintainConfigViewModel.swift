import CoreBluetooth
import RxSwift

final class MaintainConfigViewModel: BaseViewModel {
    
    private let getSwitchTimesCmd = [UInt8]([0x10, 0x86, 0x00, 0x06])
    
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setSwitchTimesCmd = [UInt8]([0x10, 0x86, 0x00, 0x02, 0x04])
    private var setTorqueTimesCmd = [UInt8]([0x10, 0x88, 0x00, 0x02, 0x04])
    private var setMotorWorkTimeCmd = [UInt8]([0x10, 0x8A, 0x00, 0x02, 0x04])
    
    let maintainStatus = PublishSubject<BaseStatus>()
    let switchTimes = PublishSubject<String>()
    let torqueTimes = PublishSubject<String>()
    let motorWorkTime = PublishSubject<String>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次

    override init() {
        super.init()
        BLEManager.default.delegate = self
    }

    func didGetData() {
        if BLEManager.default.isConnecting() {
            maintainStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getSwitchTimesCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            maintainStatus.onNext(.DisConnect)
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
            self.maintainStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didSave(index: Int, value: String) {
        if !BLEManager.default.isConnecting() { return }
        
        self.maintainStatus.onNext(.Loading)

        switch index {
        case 0: formatIntData(cmd: setSwitchTimesCmd, data: value)
        case 1: formatIntData(cmd: setTorqueTimesCmd, data: value)
        case 2: formatIntData(cmd: setMotorWorkTimeCmd, data: value)
        default: return
        }
    }

}

// MARK: - Delegate

extension MaintainConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            maintainStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        maintainStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        if length == 12 {
            retryCount = 0
            
            switchTimes.onNext(String(ConvertManager.byte2UInt32(bytes: [UInt8](data[0...3]))))
            torqueTimes.onNext(String(ConvertManager.byte2UInt32(bytes: [UInt8](data[4...7]))))
            motorWorkTime.onNext(String(ConvertManager.byte2UInt32(bytes: [UInt8](data[8...11]))))
            maintainStatus.onNext(.Complete)
        }
    }
}

