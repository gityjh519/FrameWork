//
//  TaskRequest.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/9/18.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import UIKit

class ImageURLRequest: BaseRequestTask {
    
    
   private var dispatch: DispatchQueue!
    
   class func loadImage(url: URLSchemeProtocol?,completed: (@escaping(_ image: UIImage?) -> Void)) -> Void {
        let request = ImageURLRequest(imageURL: url);
        request?.loadImageFinished(finished: { (image) in
            completed(image);
        })
    }
  
    convenience init?(imageURL: URLSchemeProtocol?) {
        if let url = imageURL?.url {
            self.init(url: url);
            respType = .typeImage;
        }else{
            return nil;
        }
    }
    
    func loadImageFinished(finished: (@escaping (_ image: UIImage?) -> Void)) -> Void {
        
        func readImageFormURL() {
            loadJsonStringFinished { (result, success) in
                if let resImg = result as? UIImage {
                    finished(resImg.decodedImage());
                }else{
                    finished(nil);
                }
            }
        }
        
        
        dispatch = DispatchQueue(label: "read_image");
        dispatch.async {
            let img = DataFileManger.readImage(fileName: self.httpURL?.url?.absoluteString);
            DispatchQueue.mainQueue {
                if let tempImage = img  {
                    finished(tempImage);
                }else {
                    readImageFormURL();
                }
            }
        }
      
        
    }
    
    
}
