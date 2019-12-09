//
//  DataBaseManager.swift
//  CathAssist
//
//  Created by yaojinhai on 2018/7/3.
//  Copyright © 2018年 CathAssist. All rights reserved.
//

import UIKit

//enum DataBaseManagerStringKey: String {
//    case searchBibile
//}
protocol DataBaseManagerStringKey {
    var valueString: String { get }
}
extension String: DataBaseManagerStringKey {
    var valueString: String {
        return self;
    }
}
enum DataBaseKey: String, DataBaseManagerStringKey {
    case loadMusicArray
    
    var valueString: String {
        return rawValue;
    }
}


class DataBaseManager {
    
    private static let instance = DataBaseManager();
    private var paramter = [String: Any]();
    private let lock = NSLock();
    private init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { (notificaion) in
            self.paramter.removeAll();
        };
    }
    static subscript(key: DataBaseManagerStringKey) -> Any? {
        set {
            instance[key.valueString] = newValue;
        }
        get {
            return instance[key.valueString]
        }
    }
    
    private subscript(key: DataBaseManagerStringKey) -> Any? {
        set{
            lock.lock();
            paramter[key.valueString] = newValue;
            lock.unlock();
        }
        get {
            lock.lock();
            let item = paramter[key.valueString];
            lock.unlock();
            return item;
        }
        
    }
    
    private func removeKey(key: DataBaseManagerStringKey) -> Void {
        lock.lock();
        paramter.removeValue(forKey: key.valueString);
        lock.unlock();
    }

}

extension DataBaseManager {
    class func set(key: DataBaseManagerStringKey,value: Any?) {
        Self[key] = value;
    }
    class func value(_ key: DataBaseManagerStringKey) -> Any? {
        return Self[key];
    }
    class func removeKey(key: DataBaseManagerStringKey) -> Void {
        instance.removeKey(key: key);
    }
}
