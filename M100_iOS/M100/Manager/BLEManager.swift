import RxSwift
import CoreBluetooth

public protocol BLEManagerDelegate {
    func bleDidUpdateState(centralState: CBManagerState)
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int)
    func bleDidConnect(peripheral: CBPeripheral)
    func bleDidConnectFaild(peripheral: CBPeripheral)
    func bleDidDisconenct(peripheral: CBPeripheral)
    func bleDidEnableNotify()
    func bleDidDisableNotify()
    func bleDidReceiveData(data: [UInt8], length: Int)
}

public class BLEManager: NSObject {
    
    enum Mode {
        case Read
        case Write
    }
    
    public static let `default` = BLEManager()
    
    private let TARGET_SERVICE_UUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    private let TARGET_CHAR_WRITE_UUID: String = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    private let TARGET_CHAR_NOTIFY_UUID: String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    public var delegate: BLEManagerDelegate?
    
    private(set) var centralManager: CBCentralManager!
    private(set) var peripheral: CBPeripheral?
    private(set) var peripherals = [CBPeripheral]()
    private(set) var characteristics = [String : CBCharacteristic]()
    private(set) var RSSICompletionHandler: ((NSNumber?, NSError?) -> ())?
    
    private var filterName: String?
    
    private var disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func write(data: Data) {
        guard let char = self.characteristics[TARGET_CHAR_WRITE_UUID] else { return }
        
        self.peripheral?.writeValue(data, for: char, type: .withoutResponse)
    }
    
    // MARK: - Public methods
    
    public func isOpenBluethooth() -> Bool { self.centralManager.state == .poweredOn }
    
    public func isConnecting() -> Bool { self.peripheral != nil }
    
    public func setFilterName(name: String) {
        self.filterName = name
    }
    
    public func startScanning(timeout: Int) {
        
        if self.centralManager.state != .poweredOn && centralManager.isScanning {
            print("[BLEManager ERROR] Couldn´t scan to peripheral")
            return
        }
        
        print("[BLEManager] Scanning started")
        
        Observable
            .of(1)
            .delay(.milliseconds(timeout), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                if self.centralManager.isScanning {
                    self.centralManager.stopScan()
                    self.peripherals.removeAll()
                    print("[BLEManager] Scanning stopped")
                }
            })
            .disposed(by: disposeBag)
        
        // let services:[CBUUID] = [CBUUID(string: RBL_SERVICE_UUID)]
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopScan() {
        
        if self.centralManager.state != .poweredOn && !centralManager.isScanning {
            print("[BLEManager ERROR] Couldn´t scan to peripheral")
            return
        }
        
        print("[BLEManager] Scanning stop")
        self.centralManager.stopScan()
        self.peripherals.removeAll()
        self.disposeBag = DisposeBag()
    }
    
    public func connect(peripheral: CBPeripheral) {
        
        if self.centralManager.state != .poweredOn {
            print("[BLEManager ERROR] Couldn´t connect to peripheral")
            return
        }
        
        if let _ = self.peripheral { return }
        
        print("[BLEManager] Connecting to peripheral: \(peripheral.identifier.uuidString)")
        
        self.centralManager.stopScan()
        self.centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true)])
    }
    
    public func disconnect() {
        if self.centralManager.state != .poweredOn {
            print("[BLEManager ERROR] Couldn´t disconnect from peripheral")
            return
        }
        
        if let peripheral = self.peripheral {
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func disconnect(peripheral: CBPeripheral) {
        if self.centralManager.state != .poweredOn {
            print("[BLEManager ERROR] Couldn´t disconnect from peripheral")
            return
        }
        
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
    
    public func read() {
        
        guard let char = self.characteristics[TARGET_CHAR_NOTIFY_UUID] else { return }
        
        self.peripheral?.readValue(for: char)
    }
    
    public func enableNotifications(enable: Bool) {
        
        guard let char = self.characteristics[TARGET_CHAR_NOTIFY_UUID] else { return }
        
        self.peripheral?.setNotifyValue(enable, for: char)
        
        if enable {
            delegate?.bleDidEnableNotify()
        } else {
            delegate?.bleDidDisableNotify()
        }
    }
    
    public func readRSSI(completion: @escaping (_ RSSI: NSNumber?, _ error: NSError?) -> ()) {
        self.RSSICompletionHandler = completion
        self.peripheral?.readRSSI()
    }
    
    func writeBytes(content: [UInt8], mode: Mode) {
        
        if !isConnecting() { return }
        
        var contents: [UInt8]
        
        switch mode {
        case .Read:
            var header = [UInt8]([0x01, 0x03])
            header.append(contentsOf: content)
            contents = header
        default:
            var header = [UInt8]([0x01, 0x10])
            header.append(contentsOf: content)
            contents = header
        }
        
        guard let command = crcEncoding(contents, type: .MODBUS) else { return }
        
        let data = Data(bytes: command, count: command.count)
        
        self.write(data: data)
        print(String(format: "[BLEManager] writeBytes: [%@]", data.hexEncodedString()))
    }
    
    public func writeString(command: String) {
        if !isConnecting() { return }
        
        print("[BLEManager] writeString: \(command)")
        
        guard let data = command.data(using: String.Encoding.utf8)  else { return }
        
        self.write(data: data)
    }
    
    #if DEBUG
        func printBytesCmd(content: [UInt8], mode: Mode) {
            
            var contents: [UInt8]
            
            switch mode {
            case .Read:
                var header = [UInt8]([0x01, 0x03])
                header.append(contentsOf: content)
                contents = header
            default:
                var header = [UInt8]([0x01, 0x10])
                header.append(contentsOf: content)
                contents = header
            }
            
            guard let command = crcEncoding(contents, type: .MODBUS) else { return }
            
            let data = Data(bytes: command, count: command.count)
            print(String(format: "[BLEManager] writeBytes: [%@]", data.hexEncodedString()))
        }
        
        func printStringCmd(command: String) {
            
            guard let data = command.data(using: String.Encoding.utf8)  else { return }
            
            print(data)
        }
    #endif
    
}

// MARK: - CBCentralManager callback

extension BLEManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("[BLEManager] Central manager state: Unknown")
            break
        case .resetting:
            print("[BLEManager] Central manager state: Resseting")
            break
        case .unsupported:
            print("[BLEManager] Central manager state: Unsopported")
            break
        case .unauthorized:
            print("[BLEManager] Central manager state: Unauthorized")
            break
        case .poweredOff:
            self.peripheral?.delegate = nil
            self.peripheral = nil
            self.characteristics.removeAll(keepingCapacity: false)
            print("[BLEManager] Central manager state: Powered off")
            break
        case .poweredOn:
            print("[BLEManager] Central manager state: Powered on")
            break
        @unknown default:
            fatalError()
        }
        
        self.delegate?.bleDidUpdateState(centralState: central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("[BLEManager] Find peripheral: \(peripheral.identifier.uuidString) RSSI: \(RSSI)")
        
        guard let peripheralName = peripheral.name else { return }
        
        if !peripheralName.contains("MT") && !peripheralName.contains("SUNYEH") && !peripheralName.contains("SunYeh") { return }
        
        let index = peripherals.firstIndex(where: { $0.identifier.uuidString == peripheral.identifier.uuidString })
        
        if let index = index {
            peripherals[index] = peripheral
        } else {
            peripherals.append(peripheral)
            self.delegate?.bleDidUpdatePeripheral(peripheral: peripheral, rssi: Int(truncating: RSSI))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[BLEManager ERROR] Could not connecto to peripheral \(peripheral.identifier.uuidString) error: \(error!.localizedDescription)")
        self.delegate?.bleDidConnectFaild(peripheral: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[BLEManager] Connected to peripheral \(peripheral.identifier.uuidString)")
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices([CBUUID(string: TARGET_SERVICE_UUID)])
        self.delegate?.bleDidConnect(peripheral: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        var text = "[BLEManager] Disconnected from peripheral: \(peripheral.identifier.uuidString)"
        
        if error != nil {
            text += ". Error: \(error!.localizedDescription)"
        }
        
        self.peripheral?.delegate = nil
        self.peripheral = nil
        self.characteristics.removeAll(keepingCapacity: false)
        self.delegate?.bleDidDisconenct(peripheral: peripheral)
    }
}

extension BLEManager: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("[BLEManager ERROR] Error discovering services. \(error!.localizedDescription)")
            return
        }
        
        for service in peripheral.services! {
            
            if service.uuid.uuidString != TARGET_SERVICE_UUID { return }
            
            let theCharacteristics = [CBUUID(string: TARGET_CHAR_WRITE_UUID), CBUUID(string: TARGET_CHAR_NOTIFY_UUID)]
        
            peripheral.discoverCharacteristics(theCharacteristics, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print("[BLEManager ERROR] Error discovering characteristics. \(error!.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics! {
            print("[BLEManager] Discover characteristics. \(characteristic.uuid.uuidString)")
            self.characteristics[characteristic.uuid.uuidString] = characteristic
        }
        
        enableNotifications(enable: true)
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.RSSICompletionHandler?(RSSI, error as NSError?)
        self.RSSICompletionHandler = nil
    }
    
    // MARK: - Recv data
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("[BLEManager ERROR] Error updating value. \(error!.localizedDescription)")
            return
        }
        
        if characteristic.uuid.uuidString == TARGET_CHAR_NOTIFY_UUID {
            // read: 01 03 06[data length] ... [2byte: CRC]
            print("[BLEManager] Recv length: \(characteristic.value!)")
            print(String(format: "[BLEManager] Recv hex: [%@]", characteristic.value!.hexEncodedString()))
            
            let mode = UInt(characteristic.value![1])
            
            if (mode == 3) {
                // header 01 03: read
                let dataLength = Int(characteristic.value![2])
                let data = [UInt8]((characteristic.value?[3...dataLength + 2])!)
                self.delegate?.bleDidReceiveData(data: data, length: dataLength)
            } else {
                // header 01 10: write
            }
            
        }
    }
}

// MARK: - Models

extension BLEManager {
    
    enum CRCType {
        case MODBUS
        case ARC
    }
     
    func crcEncoding(_ data: [UInt8], type: CRCType) -> [UInt8]? {
        var data = data
        
        if data.isEmpty {
            return nil
        }
        
        let polynomial: UInt16 = 0xA001 // A001 is the bit reverse of 8005
        var accumulator: UInt16
        // set the accumulator initial value based on CRC type
        if type == .ARC {
            accumulator = 0
        }
        else {
            // default to MODBUS
            accumulator = 0xFFFF
        }
        
        // main computation loop
        for byte in data {
            var tempByte = UInt16(byte)
            
            for _ in 0 ..< 8 {
                
                let temp1 = accumulator & 0x0001
                accumulator = accumulator >> 1
                let temp2 = tempByte & 0x0001
                tempByte = tempByte >> 1
                if (temp1 ^ temp2) == 1 {
                    accumulator = accumulator ^ polynomial
                }
            }
        }
        
        let unit16 = UInt16(accumulator)
        let crcBtyes = unit16.bigEndian.data.bytes // get CRC
        
        data.append(crcBtyes[1])
        data.append(crcBtyes[0])
    
        return data
    }
    
    /*
     // try it out...
     
     let data = [UInt8]([0x01, 0x03, 0x10, 0x00, 0x00, 0x03])
     
     let arcValue = bleManager.crc16(data, type: .ARC)
     
     let modbusValue = bleManager.crc16(data, type: .MODBUS)
     
     if arcValue != nil && modbusValue != nil {
         
         let arcStr = String(format: "0x%4X", arcValue!)
         let modbusStr = String(format: "0x%4X", modbusValue!)
         
         print("CRCs: ARC = " + arcStr + " MODBUS = " + modbusStr)
     }
     */
}

extension Numeric {
    
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    
    // data to [btyes]
    var bytes: [UInt8] { return Array(self) }
    
    //
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { "0x" + String(format: format, $0) + " " }.joined()
    }

    //
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}

// [byte] to data
extension Array where Element == UInt8 {
    
    var data : Data{
        return Data(self)
    }
}
