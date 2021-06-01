//
//  api.swift
//  weather-app-ios-swift
//
//  Created by Andrew Vo-Nguyen on 14/5/21.
//

import Foundation

class API {
    static func getApiKey(api: String) -> String {
        //api parameter is the "root" defined in api-keys.plist
        guard let filePath = Bundle.main.path(forResource: "api-keys", ofType: "plist") else {
              fatalError("Couldn't find file 'api-keys.plist'.")
            }
        let plist = NSDictionary(contentsOfFile: filePath)
        let value = plist?.object(forKey: api) as? String
        return value!
    }

    
}
