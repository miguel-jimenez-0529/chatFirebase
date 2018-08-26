//
//  Helpers.swift
//  ChatApplication
//
//  Created by Miguel Jimenez on 8/15/17.
//  Copyright © 2017 Miguel Jimenez. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithUrlString(imageURL : String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: imageURL as AnyObject ) as? UIImage {
            self.image = cachedImage
            return
        }
        let url = URL(string: imageURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: imageURL as AnyObject)
                    self.image = downloadedImage
                    self.contentMode = .scaleAspectFill
                }
            }
        }).resume()
    }
}
