//
//  ExpoWechatUtils.swift
//  ExpoNativeWechat
//
//  Created by Hector Chong on 4/2/24.
//

import Foundation
import UIKit;

struct ExpoWechatUtils {
    static func downloadFile(url: URL, onSuccess: @escaping (Data?) -> Void, onError: @escaping (Error?) -> Void) {
        let request = URLRequest(url: url)
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                onError(error)
            } else {
                onSuccess(data)
            }
        }
        
        task.resume()
    }
    
    static func compressImage(data: Data, limit: Int) -> Data? {
        let image = UIImage(data: data)
        var compression = 1.0;
        
        var compressedData = image?.jpegData(compressionQuality: compression);
        
        guard compressedData != nil else
            {
                return data;
            }
        
        while (compressedData!.count > limit && compression > 0){
            compression -= 0.1
            compressedData = image?.jpegData(compressionQuality: compression);
        }
        
        return compressedData
    }
    
    static func convertToSwiftDictionary(data: NSDictionary) -> [String: Any?] {
        var dict: [String: Any?] = [:]

        for key in data.allKeys {
            if let keyString = key as? String {
                let value = data[key]
                dict[keyString] = value
            }
        }

        return dict
    }
}
