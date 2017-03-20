//
//  SampleFile.swift
//  SimpleSoundLoop
//
//  Created by Arek on 24.08.2016.
//  Copyright © 2016 Arek. All rights reserved.
//

import Foundation

struct SampleFile {

    static let sampleDefaultFileName = "sample.caf"
    
    
    fileprivate static func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true) as [String]
        
        return paths[0]
    }
    
    static func getFileURL() -> URL {
        
        let path = getFilesDirectory().appendingPathComponent(sampleDefaultFileName)
        
        return path
    }
    
    static func getFilesDirectory() -> URL {
        
        let path = URL(fileURLWithPath: getCacheDirectory())
        
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
