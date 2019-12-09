//
//  RequestOperation.swift
//  CathAssist
//
//  Created by lzt on 16/7/5.
//  Copyright © 2016年 CathAssist. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
let baseURLAPI = "https://www.xiaozhushou.org/api.php"; // 旧的 ipa

let newBaseURLAPI = "https://www.chinacath.cn/api/"; // 正试 ipa

//let newBaseURLAPI = "http://106.12.31.64/api/"; // 测试 ipa

//let newBaseURLAPI = "http://192.168.199.199:8081/api/"; // 测试 ipa shuaihao





enum ResponseType : Int {
    case typeData = 0
    case typeJson
    case typeImage
    case typeString
    case model
}

enum BindPhoneNumberType {
    case weixin
}


enum HttpParamterType {
    case appStoreVersion

}

enum SearchCategory: String {
//    news,liturgic
    case music = ""
    case news = "news"
    case liturgic = "liturgic"
}

class UserRequest : BaseRequestTask {
    
    override init() {
        super.init();
    }
   
    override func configParater() {

    }
    
    convenience init(count: Int) {
        self.init();
    }
    
    // 打赏接口
  
    
}



extension UserRequest {
    
    // 下载 图片
    class func imagePath(_ imageUrl: String,finished: @escaping (_ success: Bool,_ result: UIImage?)->()) -> Void {

        let request = UserRequest(baseUrl: imageUrl);
        request.respType = ResponseType.typeImage;
        request.loadJsonStringFinished { (imageData, success) in
            guard let newImg = imageData as? UIImage else{
                finished(false,nil);
                return;
            }
            finished(true,newImg);
        }
    }
    
}


enum HTTPContentType: String {
    case form = "application/x-www-form-urlencoded; charset=utf-8"
    case json = "application/json"
    case multipartForm = "multipart/form-data;boundary=wfWiEWrgEFA9A78512weF7106A";
    
}
