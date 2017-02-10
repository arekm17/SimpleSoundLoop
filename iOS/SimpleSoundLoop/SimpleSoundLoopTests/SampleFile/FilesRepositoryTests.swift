//
//  FilesRepository.swift
//  SimpleSoundLoop
//
//  Created by Arek on 10.02.2017.
//  Copyright © 2017 Arek. All rights reserved.
//

import XCTest
@testable import SimpleSoundLoop

class FilesRepositoryTests: XCTestCase {
    
    let newFileName: String = FilesRepository.newFileName

    var filesRepository : FilesRepository?
    var mockFileManager: MockFileManager = MockFileManager()

    
    
    override func setUp() {
        super.setUp()
        filesRepository = FilesRepository(fileManager: mockFileManager)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGivenNoFilesWhenGetNewFileNameThenReturnDefaultFileName() {

        //Given
        let files = [URL]();
        mockFileManager.files = files
        filesRepository?.updateFiles()
        
        //When
        let newFile = filesRepository!.getNewFileName()
        
        //Then
        XCTAssertEqual("\(newFileName)", newFile)
        
    }
    
    func testGivenDefaultFileNameWhenGetNewFileNameThenReturnDefaultFileNameWithZero() {
        
        //Given
        let files : [URL] = [URL(fileURLWithPath: "file://test/pl/\(newFileName).caf")]
        mockFileManager.files = files
        filesRepository?.updateFiles()
        
        //When
        let newFile = filesRepository!.getNewFileName()
        
        //Then
        XCTAssertEqual("\(newFileName)_\(0)", newFile)
        
    }
    
    
    func testGivenDefaultFileNameWithNumberWhenGetNewFileNameThenReturnDefaultFileNameWithNextNumber() {
        
        //Given
        let files : [URL] = [URL(fileURLWithPath: "file://test/pl/\(newFileName).caf"),
                             URL(fileURLWithPath: "file://test/pl/\(newFileName)_0.caf"),
                             URL(fileURLWithPath: "file://test/pl/\(newFileName)_1.caf")]
        mockFileManager.files = files
        filesRepository?.updateFiles()
        
        //When
        let newFile = filesRepository!.getNewFileName()
        
        //Then
        XCTAssertEqual("\(newFileName)_\(2)", newFile)
        
    }
    

}

