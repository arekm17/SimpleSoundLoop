//
//  SampleFile.swift
//  SimpleSoundLoop
//
//  Created by Arek on 24.08.2016.
//  Copyright © 2016 Arek. All rights reserved.
//

import Foundation

struct SampleFile {

    private static let sampleDefaultFileName = "sample.caf"
    
    
    private static func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,.UserDomainMask, true) as [String]
        
        return paths[0]
    }
    
    static func getFileURL() -> NSURL {
        
        let path = NSURL(fileURLWithPath: getCacheDirectory()).URLByAppendingPathComponent(sampleDefaultFileName)
        
        return path
    }
    
//    static func fileExists() -> Bool {
//        let fileManager = NSFileManager.defaultManager()
//        if fileManager.fileExistsAtPath(filePath) {
//            print("FILE AVAILABLE")
//        } else {
//            print("FILE NOT AVAILABLE")
//        }
//    }
}