//
//  BaseRequestTask.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/9/18.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import UIKit

class BaseRequestTask: NSObject {
    
    var respType = ResponseType.typeJson;
    
    var state = HttpState.ready;
    
    var filePath = "";
    
    var clsModel: AnyClass!
    
    
    var memeryProgress: Float = 0;
    var downProgress: proBlock!
    
    
    var httpMethod = HttpMethodType.GET;
    var contentType = HTTPContentType.form;
    
    
    private lazy var paramterList = [HttpParamterModel]();
    
    private lazy var headerParamter = [String: String]();
    
    private lazy var queryItems = [URLQueryItem]();
    
    private var requestItem: TaskRequestOperation!
    
    private var stringURL = "";
    
    var httpURL: URL?
    
    var dispatchQueue: DispatchQueue!
    
    override init() {
        super.init();
    }
    
    convenience init(baseUrl: String) {
        self.init();
        stringURL = baseUrl;
    }
    
    convenience init(url: URL) {
        self.init();
        httpURL = url;
    }
    
    func configParater() -> Void {
        
    }
    
    
}


extension BaseRequestTask {
    
    func add(value: String?,key: String) {
        if let value = value {
            
            queryItems.removeAll { (item) -> Bool in
                return item.name == key;
            }
            let item = URLQueryItem(name: key, value: value);
            queryItems.append(item);
        }
        
    }
    func addBody(value:String?,key: String) -> Void {
        if let value = value {
            let model = HttpParamterModel(key: key, value: value,isBody: true);
            paramterList.append(model);
        }
    }
    func addBodyData(value: Data?,key: String) -> Void {
        if let value = value {
            let model = HttpParamterModel(key: key, valueData: value);
            paramterList.append(model);
        }
    }
    func addHeader(key: String,value: String) -> Void {
        headerParamter[key] = value;
    }
}

extension BaseRequestTask {
    
    func loadingMP3File(_ finished: @escaping finishedTask) {
        
        self.respType = .typeData;
        
        guard let requestURL = createRequest() else{
//            JHSActivityView.hiddenActivityView();
            finished(nil,false);
            return;
        }
        
        
        let request = TaskRequestOperation(request: requestURL);
        
        request.finiTask = {
            (data,success) -> Void in
            if success {
                let result = self.getResponsTypeData(data as? Data);
                finished(result, success);
            }else{
                finished(nil,false);
            }
        }
        
        request.progress = {
            (pros) -> Void in
            self.downProgress?(pros);
        }
        
        TaskRequestList.addOperation(task: request);
        
        self.memeryProgress = request.memeryProgress;
        self.state = request.state;
        
        
    }
    
    
    func loadJsonStringFinished(fromDisk: CacheDataProtocal = .memory, finished:@escaping finishedTask){
        
        guard let requestURL = createRequest() else{
            finished(nil,false);
            return;
        }
        
        
        func reloadFormNet(){
            
            let request = TaskRequestOperation(request: requestURL);
            request.finiTask = {
                (data,success) -> Void in
                
                if success {
                    let result = self.getResponsTypeData(data as? Data);
                    finished(result, success);
                }else{
                    finished(nil,false);
                }
            }
            
            TaskRequestList.addOperation(task: request);
        }
        
        func readCachesData(fileName: String) {
            
            
            dispatchQueue = DispatchQueue(label: "read_caches_data");
            dispatchQueue.async {
                let data = DataFileManger.init(libraryPath: .data).readToCaches(fileName: fileName, extenName: .defualt, fromData: fromDisk);
                let tempData = self.getResponsTypeData(data);
                
                DispatchQueue.mainQueue {
                    if let temp = tempData {
//                        JHSActivityView.hiddenActivityView();
                        finished(temp,true);
                    }else {
                        reloadFormNet();
                    }
                }
            }
            
            
        }
        
        if fromDisk.isIgnoreCaches {
            reloadFormNet();
        }else {
            let fileName = requestURL.url?.absoluteString ?? "";
            readCachesData(fileName: fileName);
        }
    }
    
    
    class func cancel(_ urlString: String) {
        
        guard let url = URL(string: urlString) else{
            return;
        }
        var request = URLRequest(url: url);
        request.httpMethod = HttpMethodType.GET.rawValue;
        let operation = TaskRequestOperation(request: request);
        TaskRequestList.cancelOperaion(task: operation);
    }
    
    func cancelRequest() -> Void {
        guard let url = getRequestURL() else{
            return;
        }
        let request = URLRequest(url: url);
        let operation = TaskRequestOperation(request: request);
        TaskRequestList.cancelOperaion(task: operation)
    }
}


extension BaseRequestTask {
    
    //    private func getRequestURL() -> URL? {
    //
    //        if let url = httpURL {
    //            return url;
    //        }
    //
    //        let newPath = self.filePath.count > 0 ? "\(self.filePath)" : "";
    //
    //        var paterString = baseURLAPI.appending(newPath);
    //
    //        if self.stringURL.hasPrefix("http") {
    //            paterString = self.stringURL.appending(newPath);
    //        }
    //
    //
    //        let keyValue = HttpParamterModel.getPairKeyAndValue(list: paramterList);
    //        paterString = paterString + keyValue;
    //
    //        guard let tempURL = URL(string:paterString) else {
    //            return nil;
    //        }
    //
    //        return tempURL;
    //    }
    
    func getRequestURL() -> URL? {
        
        if let url = httpURL {
            return url;
        }
        
        var componse: URLComponents!
        
        if stringURL.hasPrefix("http") {
            componse = URLComponents(string: stringURL);
        }else {
            componse = URLComponents(string: baseURLAPI + "?");
        }
        if let path = filePath.realText {
            componse.path += path;
        }
        if queryItems.count > 0 {
            componse.queryItems = queryItems;
        }
        
        
        return componse.url;
        
        
        
    }
    
    
    
    private func createRequest() -> URLRequest? {
        
        guard let tempURL = getRequestURL() else {
            return nil;
        }
        var request = URLRequest(url: tempURL);
        request.httpMethod = httpMethod.rawValue;
        
        if contentType == .json {
            if let bodyData = HttpParamterModel.getHttpBodyJsonData(paramterList: paramterList) {
                request.httpBody = bodyData;
            }
        }else if let bodyData = HttpParamterModel.getHttpBodyData(paramterList: paramterList) {
            request.httpBody = bodyData
        }
        
        
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type");
        
        if let bodayDataLength = request.httpBody?.count {
            request.setValue("\(bodayDataLength)", forHTTPHeaderField: "Content-Length")
            
        }
        request.setValue("UTF-8", forHTTPHeaderField: "Accept-Charset");
//        if let token = UserModel.getToken() {
//            request.setValue(token, forHTTPHeaderField: "X-Auth-Token");
//        }else{
//            request.setValue("token", forHTTPHeaderField: "X-Auth-Token");
//        }
//        for item in headerParamter {
//            request.setValue(item.value, forHTTPHeaderField: item.key);
//        }
        
        return request;
        
    }
    
    
    private func getResponsTypeData(_ data: Data?) -> AnyObject? {
        
        guard let data = data else {
            return nil;
        }
        
        var result : AnyObject?;
        switch self.respType {
            case ResponseType.typeData:
                result = data as AnyObject?;
                break;
            case ResponseType.typeJson:
                guard let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) else{
                    return nil;
                }
            result = dict as AnyObject?;
//                if let cls = clsModel {
//                    let model = BaseModel(model: cls, dict: dict);
//                    result = model;
//                    if model.errorCode == .un_authorization {
//                        ToastManagerView.showToaskView(text: "登录过期，请重新登录", isSuccess: false);
//                    }
//                }else{
//                    result = dict as AnyObject?;
//            }
            
            
            case ResponseType.typeImage:
                result = UIImage(data: data);
            
            case ResponseType.typeString:
                result = NSString(data: data, encoding: String.Encoding.utf8.rawValue);
            
            case .model:
                guard let tempDict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary else{
                    return nil;
                }
                result = BaseModel(dictM: tempDict);
        }
        
        return result;
    }
}

