//
//  FilesRepository.swift
//  SimpleSoundLoop
//
//  Created by Arek on 08.02.2017.
//  Copyright © 2017 Arek. All rights reserved.
//

import Foundation
import UIKit


class FilesRepository : NSObject {
    
    static let newFileName : String = "nowe nagranie"
    private static let fileDirectory : URL = SampleFile.getFilesDirectory()

    private var fileManager : FileManager!

    var files : [String] = [String]()

    override init() {
        super.init()
        
        self.fileManager = FileManager.default;
        self.updateFiles()
        
    }
    
    init(fileManager: FileManager) {
        super.init()

        self.fileManager = fileManager;
        self.updateFiles()
    }
    
    func updateFiles() {
    
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: FilesRepository.fileDirectory, includingPropertiesForKeys: nil, options: [])

            files = directoryContents.filter(){$0.pathExtension == "caf"}.map {
                var arr = $0.lastPathComponent.components(separatedBy: ".");
                arr.removeLast();
                return arr.joined();}
        
        } catch let error as NSError {
            print(error.localizedDescription)
            files = [String]()
        }
        
    }
    
    func getNewFileName() -> String {
        
        let fileName = FilesRepository.newFileName;
        
//        if (!files.contains("\(fileName)")) {
//            return fileName
//        }

        var i = -1
        var template = "\(fileName)"
        
        while (files.contains(template)) {
            i += 1
            template = "\(fileName)_\(i)"
        }
        
        return template;
        
    }
    
    
}

extension FilesRepository : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        }
        
        // we know that cell is not empty now so we use ! to force unwrapping but you could also define cell as
        // let cell = (tableView.dequeue... as? UITableViewCell) ?? UITableViewCell(style: ...)
        
        cell!.textLabel?.text = files[indexPath.row]
//        cell!.detailTextLabel?.text = "1/2 cup"
        
        return cell!
    }
    
}
