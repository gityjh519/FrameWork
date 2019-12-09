//
//  RequestImageView.swift
//  CathAssist
//
//  Created by yaojinhai on 2019/10/8.
//  Copyright © 2019 CathAssist. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


struct AssociateKeys {
    static var urlKey: Void?
}


extension UIImageView {
    
    func setImageURL(url: URLSchemeProtocol?,placeholder: UIImage? = nil) -> Void {

        setImageURL(url: url, placeholder: placeholder, completed: nil);
    }
    
    func setImageURL(url: URLSchemeProtocol?,placeholder: UIImage? = nil,completed: ((_ image: UIImage?) -> Void)? = nil) -> Void {
        
        image = placeholder;
        
        objc_setAssociatedObject(self, &AssociateKeys.urlKey, url?.urlString, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        let request = ImageURLRequest(imageURL: url);
        request?.loadImageFinished(finished:{
            [weak self](img) in
            if let did = completed {
                did(img);
            }else{
                self?.updateImage(img: img, imageURL: url?.urlString);
            }
        })
    }
    
    
    
    
    private func updateImage(img: UIImage?,imageURL: String?) -> Void {
        
        let cachesImageURL = objc_getAssociatedObject(self, &AssociateKeys.urlKey) as? String;
        
        if cachesImageURL == imageURL {
            image = img;
        }
        
    }
}


extension UIImage {
    func decodedImage() -> UIImage {
        if let imgs = images, imgs.count > 0 {
            return self;
        }
        guard let imageRef = cgImage else{
            return self;
        }
        let alpha = imageRef.alphaInfo;
        var listInfo = [CGImageAlphaInfo]();
        listInfo.append(.first);
        listInfo.append(.premultipliedFirst);
        listInfo.append(.last);
        listInfo.append(.premultipliedLast);
        
        let isHaveAlpha = listInfo.contains(alpha);

        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        
        var bitmapInfo = CGImageByteOrderInfo.orderDefault.rawValue;
        bitmapInfo = bitmapInfo | (isHaveAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue);
        

        let context = CGContext.init(data: nil, width: imageRef.width, height: imageRef.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo);
        context?.draw(imageRef, in: .init(x: 0, y: 0, width: imageRef.width, height: imageRef.height));
        if let newImageRef = context?.makeImage() {
            let newImage = UIImage(cgImage: newImageRef);
            return newImage;
        }
        return self;
    }
}
