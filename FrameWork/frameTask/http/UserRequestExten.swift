//
//  UserRequestExten.swift
//  CathAssist
//
//  Created by yaojinhai on 2018/12/15.
//  Copyright © 2018年 CathAssist. All rights reserved.
//

import Foundation

enum NoParamterType {
    case login
}
enum JoinParamterToEndType {
    case shareId
}
extension UserRequest {
    convenience init(value: String,type: JoinParamterToEndType) {
        self.init(baseUrl: newBaseURLAPI);
        switch type {
        case .shareId:
            filePath = "api/daily/event/share/" + value;
            httpMethod = .POST;
        }
    }
}
