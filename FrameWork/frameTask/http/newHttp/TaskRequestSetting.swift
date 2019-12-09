//
//  TaskRequestSetting.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/9/20.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import Foundation




enum HttpState : Int{
    case ready
    case execing
    case cancel
    case finished
}

enum HttpMethodType : String{
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

typealias proBlock = (_ perceces: Float) -> Void
typealias finishedTask = (_ data: AnyObject?,_ success: Bool) -> Void
typealias startLoaing = () -> Void
