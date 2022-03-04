import CoreBluetooth
import RxSwift

final class ProductConfigViewModel: BaseViewModel {
    
    // read
    private let getSystemDetectBoardCmd = [UInt8]([0x10, 0x56, 0x00, 0x01])
    private let getOemSerialCmd = [UInt8]([0x10, 0x60, 0x00, 0x20])
    private let getModbusIdCmd = [UInt8]([0x10, 0x83, 0x00, 0x03])
    private let getProfibusAddressCmd = [UInt8]([0x10, 0xB8, 0x00, 0x02]) // num:2 board區分
    
    // write
    private let saveCmd = [UInt8]([0x10, 0xCB, 0x00, 0x01, 0x02, 0x03, 0x09])
    private var setModbusIdCmd = [UInt8]([0x10, 0x83, 0x00, 0x01, 0x02])
    private var setBaundRateCmd = [UInt8]([0x10, 0x84, 0x00, 0x02, 0x04])
    private var setProfibusAddressCmd = [UInt8]([0x10, 0xB8, 0x00, 0x01, 0x02])
    private var setGearCmd = [UInt8]([0x10, 0x7F, 0x00, 0x01, 0x02])
    private var setOemTypeCmd = [UInt8]([0x10, 0x68, 0x00, 0x05, 0x0A])
    private var setOemSerialCmd = [UInt8]([0x10, 0x60, 0x00, 0x08, 0x10])
    private var setDealerTypeCmd = [UInt8]([0x10, 0x7A, 0x00, 0x05, 0x0A]) // 0A: 文件長度10, 目前只讀6byte
    private var setDealerSerialCmd = [UInt8]([0x10, 0x72, 0x00, 0x08, 0x10])
    
    let productStatus = PublishSubject<BaseStatus>()
    let modbusId = PublishSubject<String>()
    let baundRate = PublishSubject<String>()
    let profibusAddress = PublishSubject<String>()
    let gear = PublishSubject<String>()
    let oemType = PublishSubject<String>()
    let oemSerial = PublishSubject<String>()
    let dealerType = PublishSubject<String>()
    let dealerSerial = PublishSubject<String>()
    
    let ai1Board = PublishSubject<Bool>()
    let ai2Board = PublishSubject<Bool>()
    let di1Board = PublishSubject<Bool>()
    let di2Board = PublishSubject<Bool>()
    let modbusBoard = PublishSubject<Bool>()
    let hartBoard = PublishSubject<Bool>()
    let ao1Board = PublishSubject<Bool>()
    let ao2Board = PublishSubject<Bool>()
    let do1Board = PublishSubject<Bool>()
    let do2Board = PublishSubject<Bool>()
    let profibusBoard = PublishSubject<Bool>()
    
    private var timer: Timer!
    private var retryCount: Int = 0 // device無回應時，最多再要一次
    
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
    
    private func formatIntData(cmd: [UInt8], data: String, isLittleEnian: Bool = false) {
        var cmd = cmd
        
        if isLittleEnian {
            if let dataBytes = ConvertManager.uint2byte(from: UInt32(data), isLittleEnian: isLittleEnian) {
                for i in stride(from: 0, to: dataBytes.count, by: 2) {
                    cmd.append(dataBytes[i+1])
                    cmd.append(dataBytes[i])
                }
                
                setData(cmd: cmd)
            }
        } else {
            if let dataBytes = ConvertManager.uint2byte(from: UInt16(data), isLittleEnian: isLittleEnian) {
                for byte in dataBytes {
                    cmd.append(byte)
                }
                
                setData(cmd: cmd)
            }
        }
    }
    
    private func formatUTF8Data(cmd: [UInt8], maxlength: Int, data: String) {
        var cmd = cmd
        if var dataBytes = ConvertManager.utf2byte(from: data) {
            // 因資料格式化需為偶數長度，故資料長度補到偶數
            if dataBytes.count % 2 == 1 { dataBytes.append(0x00) }
            
            var dataLength = dataBytes.count
            
            // 限制資料長度
            if dataLength > maxlength { dataLength = maxlength }
            
            for i in stride(from: 0, to: dataLength - 1, by: 2) {
                cmd.append(dataBytes[i + 1])
                cmd.append(dataBytes[i])
            }
            
            // 資料不夠長塞0x00
            if dataLength < maxlength {
                for _ in 1...maxlength - dataLength {
                    cmd.append(0x00)
                }
            }
            
            setData(cmd: cmd)
        }
    }
    
    private func setData(cmd: [UInt8]) {
        DispatchQueue.background(delay: 0.5, background: {
            BLEManager.default.writeBytes(content: cmd, mode: .Write)
        }, completion: {
            BLEManager.default.writeBytes(content: self.saveCmd, mode: .Write)
            self.productStatus.onNext(.Save)
        })
    }
    
    // MARK: - Events
    
    func didGetData() {
        if BLEManager.default.isConnecting() {
            productStatus.onNext(.Loading)
            BLEManager.default.writeBytes(content: getModbusIdCmd, mode: .Read)
            starTimtout(timeout: 5)
        } else {
            productStatus.onNext(.DisConnect)
        }
    }
    
    func didSave(index: Int, value: String) {
        if !BLEManager.default.isConnecting() { return }
        
        self.productStatus.onNext(.Loading)
        
        switch index {
        case 0: formatIntData(cmd: setModbusIdCmd, data: value)
        case 1: formatIntData(cmd: setBaundRateCmd, data: value, isLittleEnian: true)
        case 2: formatIntData(cmd: setProfibusAddressCmd, data: value)
        case 3: formatIntData(cmd: setGearCmd, data: value)
        case 4: formatUTF8Data(cmd: setOemTypeCmd, maxlength: 10, data: value)
        case 5: formatUTF8Data(cmd: setOemSerialCmd, maxlength: 16, data: value)
        case 6: formatUTF8Data(cmd: setDealerTypeCmd, maxlength: 10, data: value)
        default: formatUTF8Data(cmd: setDealerSerialCmd, maxlength: 16, data: value)
        }
    }
}

// MARK: - Delegate

extension ProductConfigViewModel: BLEManagerDelegate {
    
    func bleDidUpdateState(centralState: CBManagerState) {
        if centralState == .poweredOff {
            productStatus.onNext(.DisConnect)
        }
    }
    
    func bleDidUpdatePeripheral(peripheral: CBPeripheral, rssi: Int) {
    }
    
    func bleDidConnect(peripheral: CBPeripheral) {
    }
    
    func bleDidConnectFaild(peripheral: CBPeripheral) {
    }
    
    func bleDidDisconenct(peripheral: CBPeripheral) {
        productStatus.onNext(.DisConnect)
    }
    
    func bleDidEnableNotify() {
    }
    
    func bleDidDisableNotify() {
    }
    
    func bleDidReceiveData(data: [UInt8], length: Int) {
        
        switch length {
        case 6:
            modbusId.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1]))))
            baundRate.onNext(String(ConvertManager.byte2UInt32(bytes: [UInt8](data[2...5]))))
            
            BLEManager.default.writeBytes(content: getOemSerialCmd, mode: .Read)
        case 64:
            // \0 空字元：空字元後的文字不顯示，以@分割字串
            
            let oemSerialStr: String = ConvertManager.byte2UTF8(bytes: [UInt8](data[0...15]))
                .replacingOccurrences(of: "\0", with: "@", options: NSString.CompareOptions.literal, range:nil)
            
            let oemTypeStr: String = ConvertManager.byte2UTF8(bytes: [UInt8](data[16...25]))
                .replacingOccurrences(of: "\0", with: "@", options: NSString.CompareOptions.literal, range:nil)
            
            let dealerSerialStr: String = ConvertManager.byte2UTF8(bytes: [UInt8](data[36...51]))
                .replacingOccurrences(of: "\0", with: "@", options: NSString.CompareOptions.literal, range:nil)
            
            let dealerTypeStr: String = ConvertManager.byte2UTF8(bytes: [UInt8](data[52...61]))
                .replacingOccurrences(of: "\0", with: "@", options: NSString.CompareOptions.literal, range:nil)
            
            oemSerial.onNext(String(oemSerialStr.split(separator: "@").first ?? ""))
            oemType.onNext(String(oemTypeStr.split(separator: "@").first ?? ""))
            dealerSerial.onNext(String(dealerSerialStr.split(separator: "@").first ?? ""))
            dealerType.onNext(String(dealerTypeStr.split(separator: "@").first ?? ""))
            gear.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[62...63]))))
            
            BLEManager.default.writeBytes(content: getSystemDetectBoardCmd, mode: .Read)
        case 2:
            let SystemDetectBoardValue = ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1]))
            var binaryValue: String = ConvertManager.int2Binary(value: Int(SystemDetectBoardValue))
            
            if binaryValue.count <= 11 {
                
                for _ in 0 ..< 11 - binaryValue.count {
                    binaryValue = "0" + binaryValue
                }
            }
            
            for (index, element) in binaryValue.enumerated() {
                
                switch index {
                case 0:
                    if element == "0" {
                        hartBoard.onNext(false)
                    } else {
                        hartBoard.onNext(true)
                    }
                case 1:
                    if element == "0" {
                        profibusBoard.onNext(false)
                    } else {
                        profibusBoard.onNext(true)
                    }
                case 2:
                    if element == "0" {
                        modbusBoard.onNext(false)
                    } else {
                        modbusBoard.onNext(true)
                    }
                case 3:
                    if element == "0" {
                        do2Board.onNext(false)
                    } else {
                        do2Board.onNext(true)
                    }
                case 4:
                    if element == "0" {
                        do1Board.onNext(false)
                    } else {
                        do1Board.onNext(true)
                    }
                case 5:
                    if element == "0" {
                        di2Board.onNext(false)
                    } else {
                        di2Board.onNext(true)
                    }
                case 6:
                    if element == "0" {
                        di1Board.onNext(false)
                    } else {
                        di1Board.onNext(true)
                    }
                case 7:
                    if element == "0" {
                        ao2Board.onNext(false)
                    } else {
                        ao2Board.onNext(true)
                    }
                case 8:
                    if element == "0" {
                        ao1Board.onNext(false)
                    } else {
                        ao1Board.onNext(true)
                    }
                case 9:
                    if element == "0" {
                        ai2Board.onNext(false)
                    } else {
                        ai2Board.onNext(true)
                    }
                case 10:
                    if element == "0" {
                        ai1Board.onNext(false)
                    } else {
                        ai1Board.onNext(true)
                    }
                default:
                    break
                }
            }
            
            BLEManager.default.writeBytes(content: getProfibusAddressCmd, mode: .Read)
        case 4:
            if let timer = self.timer {
                timer.invalidate()
            }
            retryCount = 0
            
            profibusAddress.onNext(String(ConvertManager.byte2UInt16(bytes: [UInt8](data[0...1]))))
            productStatus.onNext(.Complete)
        default:
            break
        }
    }
}

