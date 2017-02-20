//
//  APIHelper.swift
//  Wallmax
//
//  Created by Ajay Mann on 19/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import Foundation
import Alamofire
import Kanna


public class WallhavenHelper {
    
    class func loadNewData(ofType dataType: String , withPageNum pageNum: Int, completion: @escaping wallhavenCompletionBlock) {
        Alamofire.request("https://alpha.wallhaven.cc/\(dataType)/?page=\(pageNum)").responseString { (response) in
            if let html = response.result.value {
                parseHTML(html: html, completion: { (success, wallhavenImages, error) in
                    if let error = error {
                        completion(false, nil, error)
                    }
                    
                    if let wallhavenImages = wallhavenImages {
                        completion(true, wallhavenImages, nil)
                    }
                })
            }
        }
    }
    
    class func parseHTML(html: String, completion: @escaping wallhavenCompletionBlock) {
        if let doc = Kanna.HTML(html, encoding: String.Encoding.utf8) {
            var wallhavenImages = [WallhavenImage]()
            for node in doc.xpath(imagePath) {
                if let thumbImageURL = node.xpath("img[@class='lazyload']/@data-src").makeIterator().next(),
                    let largeImageURL = node.xpath("a[@class='preview']/@href").makeIterator().next(),
                    let resolution = node.css("span").makeIterator().next() {
                    let wallhavenImage = WallhavenImage()
                    wallhavenImage.thumbURL = thumbImageURL.text
                    wallhavenImage.fullSizeURL = largeImageURL.text
                    wallhavenImage.resolution = resolution.text
                    wallhavenImages.append(wallhavenImage)
                } else {
                    completion(false, nil, NSError(domain: "Could not find pictures", code: 0, userInfo: nil))
                }
            }
            completion(true, wallhavenImages, nil)
        } else {
            completion(false, nil, NSError(domain: "Could not parse HTML", code: 0, userInfo: nil))
        }
    }
}
