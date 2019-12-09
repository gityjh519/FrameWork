//
//  HttpParamterModel.swift
//  StudyApp
//
//  Created by yaojinhai on 2018/4/12.
//  Copyright © 2018年 yaojinhai. All rights reserved.
//

import UIKit

enum HttpViaType {
    case other
    case image
}


class HttpParamterModel: NSObject {

    var isBodyPrammter = false;
    var key = "";
    var value = "";
    var dataValue: Data!
    var isData = false;
    var fileType = HttpViaType.image;
    var typeStrl: String {
        return "Content-Type:image/jpg";
    }
    
    static let bodyBoundary = "wfWiEWrgEFA9A78512weF7106A";
    
    convenience init(key: String,value: String,isBody: Bool = false) {
        self.init();
        self.key = key;
        self.value = value.encode;
        self.isBodyPrammter = isBody;
    }
    convenience init(key: String,valueData: Data) {
        self.init();
        self.key = key;
        self.dataValue = valueData;
        self.isData = true;
        self.isBodyPrammter = true;
    }
    
    
    class func getHttpBodyJsonData(paramterList: [HttpParamterModel]) -> Data? {
        if paramterList.count == 0 {
            return nil;
        }
        var bodyParamter = [String:String]();
        for item in paramterList {
            if !item.isData {
                bodyParamter[item.key] = item.value;
            }
        }
        if bodyParamter.count == 0 {
            return nil;
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyParamter, options: .prettyPrinted) else{
            return nil;
        }
        return jsonData;
    }
    
    
    class func getHttpBodyData(paramterList: [HttpParamterModel]) -> Data? {
        
        
        let listModel = getBodyParamter(list: paramterList, isBody: true);
        
        if listModel.count == 0 {
            return nil;
        }
        var bodyData = Data();
        let debugDataString = NSMutableString();
        
        
        let boundLine = "--" + bodyBoundary + "\r\n";
        bodyData.append(boundLine.data);
        debugDataString.append(boundLine);
        
        for item in listModel {
            
            
            if item.isData {
                
                
                let inputKey = """
                Content-Disposition: form-data;name="\(item.key)";filename="\(item.key).jpg"\r\n\(item.typeStrl)\r\n
                """;
                
                bodyData.append(inputKey.data);
                debugDataString.append(inputKey);
                
                
                let endFlag = "\r\n";
                bodyData.append(endFlag.data);
                debugDataString.append(endFlag);
                
                
                bodyData.append(item.dataValue);
                
                if let image = UIImage(data: item.dataValue) {
                    debugDataString.append("imageSize =\(image.size)");
                }else{
                    debugDataString.append("没有图片");
                }
                
                bodyData.append(endFlag.data);
                debugDataString.append(endFlag);
                
            }else {
                
                let inputKey = "Content-Disposition: form-data; name=\"\(item.key)\"" + "\r\n\r\n";
                bodyData.append(inputKey.data);
                debugDataString.append(inputKey);
                
                bodyData.append(item.value.data);
                debugDataString.append(item.value);
                
                let endFlag = "\r\n";
                bodyData.append(endFlag.data);
                debugDataString.append(endFlag);
                
            }
            
        }
        
        
        
        let endBound = "--" + bodyBoundary + "--\r\n";
        bodyData.append(endBound.data);
        
        debugDataString.append(endBound);
        
        
        printObject("数据参数：\n\(debugDataString)");
        
        
        return bodyData;
    }
    
    
    class func getBodyParamter(list: [HttpParamterModel],isBody: Bool) -> [HttpParamterModel] {
        
        var tempList = [HttpParamterModel]();
        for item in list {
            if item.isBodyPrammter && isBody {
                tempList.append(item);
            }else if !isBody && !item.isBodyPrammter{
                tempList.append(item);
            }
        }
        return tempList;
    }
//    class func getPairKeyAndValue(list: [HttpParamterModel]) -> String {
//        var tempStrl = "?";
//        for item in list {
//            if item.isBodyPrammter{
//                continue;
//            }
//            let valueString = item.key + "=" + item.value + "&";
//            tempStrl.append(valueString);
//        }
//        if tempStrl.count > 0 {
//            tempStrl = String(tempStrl.dropLast());
//        }
//        return tempStrl;
//    }
    
    
    
    private override init() {
        super.init();
    }
}

//extension String {
//    var data: Data {
//        return self.data(using: String.Encoding.utf8)!;
//    }
//    var unicodeData: Data{
//        return data(using: String.Encoding.unicode)!;
//    }
//    var encode: String {
//        return self;
//    }
//    var decode: String {
//        return removingPercentEncoding ?? "";
//    }
//    
//    
//}

protocol URLSchemeProtocol {
    var url: URL? {get}
    var urlString: String {get}
}

extension String: URLSchemeProtocol {
    
    var urlString: String {self}
    var url: URL? {URL(string: self)}
    
}
extension URL: URLSchemeProtocol {
    var urlString: String {absoluteString}
    
    var url: URL? {
        if isFileURL {
            return self;
        }
        if host == nil {
            return nil;
        }
        return self;
    }
}


