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
    
    static let fileExt : String = "caf"
    static let newFileName : String = "nowe_nagranie"
    private static let sampleFileDirectory : URL = SampleFile.getFilesDirectory()
    private static let fileDirectory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private var fileManager : FileManager!

    var files : [String] = [String]()
    var tableView : UITableView?;
    

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
    
    func setTableView(tableView: UITableView) {
        self.tableView = tableView;
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    func updateFiles() {
    
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: FilesRepository.fileDirectory, includingPropertiesForKeys: nil, options: [])

            files = directoryContents.filter(){$0.pathExtension == FilesRepository.fileExt}.map {
                var arr = $0.lastPathComponent.components(separatedBy: ".");
                arr.removeLast();
                return arr.joined();}
            
            
//            
//             files = files.map { url -> (String, TimeInterval) in
//                    var lastModified : AnyObject?
//                    _ = try? url.getResourceValue(&lastModified, forKey: URLContentModificationDateKey)
//                    return (url.lastPathComponent, lastModified?.timeIntervalSinceReferenceDate ?? 0)
//                    }
//                    .sorted(by:{ $0.1 > $1.1 }) // sort descending modification dates
//                    .map { $0.0 } // extract file names
                
        
        } catch let error as NSError {
            print(error.localizedDescription)
            files = [String]()
        }
        
    }
    
    func saveCurrentSample(withFileName: String)  {
        
        do {
            let oldPath = URL(string:"\(FilesRepository.sampleFileDirectory)\(SampleFile.sampleDefaultFileName)")
            let newPath = URL(string:"\(FilesRepository.fileDirectory)\(withFileName).\(FilesRepository.fileExt)")
            print("old file: \(oldPath)")
//            print("old file exists: \(fileManager.file(oldPath))")
            
            try fileManager.copyItem(at: oldPath!, to: newPath!)
            
            updateFiles()
            
            self.tableView?.reloadData()
        } catch let error as NSError {
            print(error)
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
