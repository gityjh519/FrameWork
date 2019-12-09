//
//  DataFileManger.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/9/18.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import UIKit

class DataFileManger {
    
    //    创建的路径：libraryPath documentPath 两种
    private var path : String!
    
    var rootPath: String {
        return path;
    }
    
    private init() {
        
    }
    
    convenience init(libraryPath fileName: DataFilePathType) {
        self.init();
        path = fileName.rawValue.libraryPath;
        configPath();
    }
    convenience init(documentPath fileName: DataFilePathType) {
        self.init();
        path = fileName.rawValue.documentPath;
        configPath();
    }
    convenience init(tmpPath fileName: DataFilePathType) {
        self.init();
        path = NSTemporaryDirectory() + fileName.rawValue + "/";
        configPath();
    }
    
    private func configPath(){
        let file = FileManager.default;
        if !file.fileExists(atPath: path) {
            try? file.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil);
        }
    }
    // fileName: 文件的名字
    func saveData(data: Data?,fileName: String,extenName: FileExtensionType = FileExtensionType.defualt) -> Void {
        guard let data = data else {
            return;
        }
        let name = fileName.MD5;
        let rootPath = path + name;
        
        if let image = UIImage(data: data)?.decodedImage() {
            
            DataBaseManager.set(key: rootPath, value: image);
        }else{
            DataBaseManager.set(key: rootPath, value: data);
        }
        let dispatch = DispatchQueue(label: "saveData", attributes: []);
        dispatch.async {
            try? data.write(to: URL(fileURLWithPath: rootPath + extenName.rawValue), options: .atomic);
        }
    }
    
    
    func readToCachesImage(fileName: String) -> UIImage? {
        let name = fileName.MD5;
        let rootPath = path + name
        var image = DataBaseManager.value(rootPath) as? UIImage;
        if image == nil {
            image = UIImage(contentsOfFile: rootPath)?.decodedImage();
            if let cacheImage = image {
                DataBaseManager.set(key: rootPath, value: cacheImage);
            }
        }
        return image;
    }
    
    
    func readToCaches(fileName: String,extenName: FileExtensionType = FileExtensionType.defualt,fromData: CacheDataProtocal = .disk) -> Data?{
        if fromData.isIgnoreCaches {
            return nil;
        }
        let name = fileName.MD5;
        let rootPath = path + name
        var data = DataBaseManager.value(rootPath) as? Data;
        if fromData == .disk && data == nil {
            data = try? Data(contentsOf: URL(fileURLWithPath: rootPath + extenName.rawValue));
            if let cacheData = data {
                DataBaseManager.set(key: rootPath, value: cacheData);
            }
        }
        return data;
    }
    
    func clearFile(fileName: String,extenName: FileExtensionType = FileExtensionType.defualt) -> Void {
        let name = fileName.MD5;
        let rootPath = path + name;
        DataBaseManager.removeKey(key: rootPath);
        let dispatch = DispatchQueue.init(label: "delete");
        let file = FileManager.default;
        dispatch.async {
            try? file.removeItem(atPath: rootPath + extenName.rawValue);
        }
    }
    
    func clearDiskAllFile() -> Void {
        guard let tempPath = path else { return };
        DispatchQueue(label: "clear_all_file").async {
            let file = FileManager.default;
            try? file.removeItem(atPath: tempPath);
        }
    }
    
}

extension DataFileManger {
    class func readImage(fileName: String?) -> UIImage? {
        guard let fileName = fileName  else {
            return nil;
        }
        let image = DataFileManger.init(libraryPath: DataFilePathType.data).readToCachesImage(fileName: fileName);
        return image;
    }
}

extension DataFileManger {
    
    // fileName: 文件的名字 可以是地址 可以是名字
    
    
    class func writeData(data: Data?,fileName: String) -> Void {
        DataFileManger.init(libraryPath: DataFilePathType.data).saveData(data: data, fileName: fileName);
    }
    
    class func readData(fileName: String) -> Data? {
        return DataFileManger.init(libraryPath: DataFilePathType.data).readToCaches(fileName: fileName);
    }
}

// 保存 MP3 音频
extension DataFileManger {
    
    private class func MP3Manger() -> DataFileManger {
        return DataFileManger(documentPath: .mp3);
    }
    
    class func saveMP3File(data: Data?,fileName: String) -> Void {
        MP3Manger().saveData(data: data, fileName: fileName, extenName: .mp3)
    }
    
    class func readMP3File(fileName: String) -> Data? {
        return MP3Manger().readToCaches(fileName: fileName, extenName: .mp3)
    }
    // 返回文件的绝对路径
    class func readMP3FilePath(fileName: String) -> String {
        let name = fileName.MD5;
        let rootPath = MP3Manger().path + name + FileExtensionType.mp3.rawValue;
        return rootPath;
    }
    
    class func deleteMP3File(fileName: String) -> Void {
        MP3Manger().clearFile(fileName: fileName,extenName: .mp3);
    }
}


extension DataFileManger {
    
    class func clearCahesData(finishedBlock:((_ strl: String) -> Void)? = nil) -> (() -> ()) {
        
        
        let libraryPath = DataFileManger.init(libraryPath: .clearCaches).path ?? "";
        let imagePath = DataFileManger.init(libraryPath: .imageCaches).path ?? "";
        var listPath = [libraryPath,imagePath];
        if let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.org.cathassist.app.TodayKit")?.path {
            listPath.append(path);
        }
        
        
        var removePaths = [URL]();
        var maxSize: Double = 0;

        for item in listPath {
            let paths = getPathsBy(rootPath: item, size: &maxSize);
            removePaths.append(contentsOf: paths);
        }
        
        finishedBlock?(caculateSize(cachesSize: maxSize));
        
        func removeFile() {
            let file = FileManager.default;
            for item in removePaths {
                try? file.removeItem(at: item);
            }
        }
        return removeFile;
        
    }
    
    
    private class func getPathsBy(rootPath: String,size: inout Double) -> [URL] {
        
        let file = FileManager.default;
        let paths = file.enumerator(at: URL(fileURLWithPath: rootPath), includingPropertiesForKeys: [.fileSizeKey,.isDirectoryKey], options: .skipsHiddenFiles);
        
        let allPath = (paths?.allObjects as? [URL]) ?? [URL]();
        
        var key = Set<URLResourceKey>();
        key.insert(.fileSizeKey);
        key.insert(.isDirectoryKey);
        
        let removePaths = allPath.compactMap { (item) -> URL? in
            if let result = try? item.resourceValues(forKeys: key) {
                if result.isDirectory ?? true {
                    return nil;
                }
                size += Double(result.fileSize ?? 0);
            }
            return item;
        }
        return removePaths;
    }
    
    
    private class func isHaveValidFile(rootPath: String) -> Double? {
        let file = FileManager.default;
        var isDirectory: ObjCBool = false;
        file.fileExists(atPath: rootPath, isDirectory: &isDirectory);
        if isDirectory.boolValue {
            return nil;
        }
        guard let fileDict = try? file.attributesOfItem(atPath: rootPath) else {
                return nil;
        }
   
        return fileDict[.size] as? Double;
    }
    
    private class func caculateSize(cachesSize: Double) -> String {
        let KB: Double = 1024;
        let MB = KB * KB;
        
        var valueMB = cachesSize / MB;
        var valueStrl = "MB"
        
        if valueMB > KB {
            valueStrl = "G"
            valueMB = valueMB / KB;
        }
        
        let formater = NumberFormatter.localizedString(from: NSNumber.init(value: valueMB), number: NumberFormatter.Style.decimal);
        
        return "\(formater)" + valueStrl;
    }
}


extension DataFileManger {
    
    
 
    
}


enum DataFilePathType: String {
    case mp3 = "audio"
    
    // 这三个是可以清理的
    case data = "Caches/caches_data"
    case imageCaches = "caches_data"
    case clearCaches = "Caches"

    case seachHisroty = "search_key_history"
    case bibleCache = "bible_cache_by_version"
    
    case userInfo = "user_info_model"
    
    case playListInfo = "play_list_info"
    
    
}

enum FileExtensionType: String {
    case defualt = ""
    case mp3 = ".mp3"
    case plist = ".plist"
}

enum CacheDataProtocal {
    case ignoreCahes
    case memory
    case disk
    
    var isIgnoreCaches: Bool {
        return self == .ignoreCahes;
    }
}
