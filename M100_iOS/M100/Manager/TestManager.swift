class TestManager {
    #if DEBUG
    static func printCmd() {
        
        let getValveRealPositionCmd = [UInt8]([0x10, 0xB8, 0x00, 0x02]);
        BLEManager.default.printBytesCmd(content: getValveRealPositionCmd, mode: .Read)
    }
    #endif
}
