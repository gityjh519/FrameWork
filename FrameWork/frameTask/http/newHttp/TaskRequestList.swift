//
//  TaskRequestList.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/9/18.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import UIKit

class TaskRequestList: NSObject {
    
    private static var memryCacheList = [TaskRequestOperation]();
    private static let lock = NSLock();
    private static let maxOperation = 5
    
    class func addOperation(task: TaskRequestOperation) -> Void {
        lock.lock();
        defer {
            lock.unlock();
        }
        for item in memryCacheList {
            if item == task {
                item.configTask(task: task);
                return;
            }
        }
        memryCacheList.insert(task, at: 0);
        runOperation();
    }
    class func cancelOperaion(task: TaskRequestOperation) -> Void {
        lock.lock();
        defer {
            lock.unlock();
        }
        
        if let firstIndex = memryCacheList.firstIndex(where: { $0 == task }) {
            let mTest = memryCacheList.remove(at: firstIndex);
            mTest.cancelRequest();
            task.cancelRequest();
        }
        
        runOperation();
    }
    
    class func finishedOperaion(task: TaskRequestOperation) -> Void {
        lock.lock();
        defer {
            lock.unlock();
        }
        
        if let firstIndex = memryCacheList.firstIndex(where: { $0 == task }) {
            let mTest = memryCacheList.remove(at: firstIndex);
            mTest.finishedTask();
            task.finishedTask();
        }
        
        runOperation();
        
    }
    
    private class func runOperation() -> Void {
        
        DispatchQueue.mainQueue {
            UIApplication.shared.isNetworkActivityIndicatorVisible = memryCacheList.count != 0;
        }
        
        if memryCacheList.count == 0 {
            return;
        }
        
        let runCount = memryCacheList.reduce(0) { (idx, item) -> Int in
            let addIndex = item.state == .ready ? 0 : 1;
            return idx + addIndex;
        }
        
        var otherCount = maxOperation - runCount;
        
        for item in memryCacheList {
            
            if otherCount <= 0 {
                return;
            }
            if item.state == .ready {
                item.starRun();
                otherCount -= 1;
            }
            
        }
        
    }
    
}
