import CoreBluetooth
import RxSwift

final class SideMenuViewModel {
  
    private(set) var peripheralsSubject = PublishSubject<Array<CBPeripheral>>()  // scan ble 的集合
    private(set) var peripheralSubject = PublishSubject<CBPeripheral>()          // 已連上線的peripheral
    private(set) var peripheralCookieSubject = PublishSubject<CBPeripheral>()    // 最上次連過的deivce
    
    private var peripherals = Array<CBPeripheral>()
    private var rssis = Array<Int>()
    private(set) var password: String!
    
    private var peripheralNameCookie: String!
    private var peripheralCookie: CBPeripheral!
    private var peripheralCookieIndex: Int!
    
    init() {
        peripheralNameCookie = UserDefaults.standard.object(forKey: "deviceName") as? String
        BLEManager.default.delegate = self
    }
    
    // MARK: - View Events
    
    func selectPeripheral(index: Int, password: String) {
        self.password = password
        self.peripheralSubject.onNext(peripherals[index])
    }
    
    func cookieConnectPeripheral() {
        self.password = UserDefaults.standard.object(forKey: "password") as? String
        self.peripheralSubject.onNext(peripherals[peripheralCookieIndex])
    }
    
    func clearPeripherals() {
        peripheralNameCookie = UserDefaults.standard.object(forKey: "deviceName") as? String
        BLEManager.default.delegate = self
        self.peripherals.removeAll()
    }
    
    func getPeripherals() -> Array<CBPeripheral> {
        return self.peripherals
    }
    
    func getRssi(index: Int) -> Int {
        return self.rssis[index]
    }
}

// MARK: Delegate

extension SideMenuViewModel: BLEManagerDelegate {
    
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
            break
        case .poweredOn:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
        peripherals.append(peripheral)
        rssis.append(rssi)
        
        if peripheralNameCookie == peripheral.name {
            peripheralCookieIndex = peripherals.count - 1
            peripheralCookie = peripheral
            peripheralCookieSubject.onNext(peripheral)
        }
        
        peripheralsSubject.onNext(peripherals)
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
    }
}
