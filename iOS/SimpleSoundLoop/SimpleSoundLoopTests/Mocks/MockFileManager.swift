//
//  FileManagerMock.swift
//  SimpleSoundLoop
//
//  Created by Arek on 10.02.2017.
//  Copyright © 2017 Arek. All rights reserved.
//

import Foundation


class MockFileManager : FileManager {
    
    var files: [URL] = []
    
    override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        return files
    }
    
}
