
//
//  ThreadManger.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/11/5.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import Foundation
import CoreFoundation

extension DispatchQueue {
    class func queue(afterTime: Double = 0, async: (@escaping () -> Void)) -> Void {
        DispatchQueue(label: "com.queue.async").asyncAfter(deadline: .now() + afterTime) {
            
            async();
            

        }
    }
    class func mainQueue(afterTime: Double = 0, async: (@escaping () -> Void)) -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + afterTime) {
            async();
        }
    }
}
