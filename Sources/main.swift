// File shredder
// Follows DoD 5220.22-M Standard

import Foundation

guard CommandLine.arguments.count > 1 else {
    print("Usage: shredder <FILE>")
    exit(1)
}

func eraseFile(fileHandle: FileHandle, fileSize: UInt64) throws {
    // Zeros pass
    for offset in 0...fileSize {
        fileHandle.seek(toFileOffset: offset)
        try fileHandle.write(contentsOf: Data([0x00]))
    }

    // Ones pass
    for offset in 0...fileSize {
        fileHandle.seek(toFileOffset: offset)
        try fileHandle.write(contentsOf: Data([0xFF]))
    }

    // Random pass
    for offset in 0...fileSize {
        fileHandle.seek(toFileOffset: offset)
        let randomByte = UInt8.random(in: 0...255)
        try fileHandle.write(contentsOf: Data([randomByte]))
    }
}
    
let filePath = CommandLine.arguments[1]
let fileURL = URL(fileURLWithPath: filePath)

do {
    let fileHandle = try FileHandle(forUpdating: fileURL)
    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
    let fileSize = fileAttributes[.size] as? UInt64;

    try eraseFile(fileHandle: fileHandle, fileSize: fileSize!)

    try fileHandle.close()
    try FileManager.default.removeItem(at: fileURL)
} catch {
    print("\(error)")
}
