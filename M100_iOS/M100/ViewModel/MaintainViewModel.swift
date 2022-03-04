import CoreBluetooth
import RxSwift

final class MaintainViewModel: BaseViewModel {
    
    private let getMotorRemainingCmd = [UInt8]([0x10, 0x2C, 0x00, 0x16])
    
    let maintainStatus = PublishSubject<MainStatus>()
    let torqueRemainingTimes = PublishSubject<Int>()
    let valveRemainingTimes = PublishSubject<Int>()
    let motorRemainingTimes = PublishSubject<Int>()
    let totalValveOffCount = PublishSubject<Int>()
    let totalValveOnCount = PublishSubject<Int>()
    let totalTorqueAllOff = PublishSubject<Int>()
    let totalTorqueAllOn = PublishSubject<Int>()
    let systemWorkinghours = PublishSubject<Int>()
    let motorWorkinghours = PublishSubject<Int>()
    let totalTorqueOffCount = PublishSubject<Int>()
    
    override init() {
        super.init()
        BLEManager.default.delegate = self
        
        if BLEManager.default.isConnecting() {
            startGatDataTimer()            
        }
    }
    
    private func startGatDataTimer() {
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { second in
                BLEManager.default.writeBytes(content: self.getMotorRemainingCmd, mode: .Read)
            })
            .disposed(by: disposeBag)
    }
    
    private func stopGatDataTimer() {
        disposeBag = DisposeBag()
    }
}

// MARK: - Delegate

extension MaintainViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            stopGatDataTimer()
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
        stopGatDataTimer()
        maintainStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        
        if length == 44 {
            torqueRemainingTimes.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[0...3]))))
            valveRemainingTimes.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[4...7]))))
            motorRemainingTimes.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[8...11]))))
            totalValveOffCount.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[12...15]))))
            totalValveOnCount.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[16...19]))))
            // totalValveOnOffCount.onNext(Int(ConvertManager.byte2UInt(bytes: [UInt8](data[20...23]))))
            totalTorqueAllOff.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[24...27]))))
            totalTorqueAllOn.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[28...31]))))
            systemWorkinghours.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[32...35]))))
            motorWorkinghours.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[36...39]))))
            totalTorqueOffCount.onNext(Int(ConvertManager.byte2UInt32(bytes: [UInt8](data[40...43]))))
        }
    }
}

