//
//  Utils.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import Foundation
import CryptoSwift


class Utils {
    
    
    func getDecryptedPass(pass: NSData, id: String) -> String {
        print(MemoryLayout.size(ofValue: UInt8()))
        let count = pass.length / MemoryLayout.size(ofValue: UInt8())
        var binaryPass = [UInt8](repeating: 0, count: count)
        pass.getBytes(&binaryPass, length: count * MemoryLayout.size(ofValue: UInt8()))
        
        return getDecryptedPass(pass: binaryPass, id: id)
    }
    
    func getDecryptedPass(pass: [UInt8], id: String) -> String {
        
        var decryptedStr = ""
        let idBytes = Array(id.utf8)
        let idBytesHash = idBytes.sha256()
        
        do {
            let iv: [UInt8] = [0xaf, 0x73, 0xfe, 0x01, 0x72, 0x18, 0x1a, 0x92, 0xb9, 0x21, 0xc7, 0xca, 0x9a, 0x12, 0x22, 0xfa]
            
            let decrypted = try AES(key: idBytesHash, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(pass)
            if let string = String(bytes: decrypted, encoding: .utf8) {
                decryptedStr = string
            } else {
                print("not a valid UTF-8 sequence")
            }
        } catch {
            print(error)
        }
        return decryptedStr
    }
    
}
