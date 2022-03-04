import Foundation

final class ConvertManager {

    static func utf2byte(from value: String?) -> [UInt8]? {
        if let value = value {
            return [UInt8](value.utf8)
        } else {
            return nil
        }
    }
    
    static func uint2byte<T>(from value: T?, isLittleEnian: Bool = true) -> [UInt8]? where T: FixedWidthInteger {
        if let value = value {
            if isLittleEnian {
                return withUnsafeBytes(of: value.littleEndian) { Array($0) }
            } else {
                return withUnsafeBytes(of: value.bigEndian) { Array($0) }
            }
        } else {
            return nil
        }
    }
    
    static func int2Binary(value: Int) -> String {
        return String(value, radix: 2)
    }
    
    static func byte2Float(bytes: [UInt8]) -> Float {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: Float.self) }
    }
    
    static func byte2UInt(bytes: [UInt8]) -> UInt {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: UInt.self) }
    }
    
    static func byte2UInt8(bytes: [UInt8]) -> UInt8 {
        return bytes.withUnsafeBytes { $0.load(as: UInt8.self) }
    }
    
    static func byte2UInt16(bytes: [UInt8]) -> UInt16 {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: UInt16.self) }
    }
    
    static func byte2Int16(bytes: [UInt8]) -> Int16 {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: Int16.self) }
    }

    static func byte2UInt32(bytes: [UInt8]) -> UInt32 {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
    
    static func byte2Int32(bytes: [UInt8]) -> Int32 {
        let newBytes = Data(orderBytes(bytes: bytes))
        return newBytes.withUnsafeBytes { $0.load(as: Int32.self) }
    }
    
    static func byte2UTF8(bytes: [UInt8]) -> String {
        let newBytes = Data(orderBytes(bytes: bytes))
        return String(decoding: newBytes, as: UTF8.self)
    }

    static func orderBytes(bytes: [UInt8]) -> [UInt8]{
        var newBytes = [UInt8]()
        
        for i in stride(from: 0, to: bytes.count, by: 2) {
            newBytes.append(bytes[i + 1])
            newBytes.append(bytes[i])
        }
        return newBytes
    }
}
