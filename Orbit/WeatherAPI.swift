//
//  WeatherAPI.swift
//  Orbit
//
//  Created by David Koo on 09/09/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation

class WeatherAPI {
    func call(regId: String, complete: @escaping (Error?, Model.Weather?) -> Void) {
        
        let endPointURL = "http://newsky2.kma.go.kr/service/VilageFrcstDspthDocInfoService/WidOverlandForecast?"
        let serviceKey = "HxyBqycj%2FNHeeszYLHzbmuGnI3bhtYPFZ9NfMET%2BmGoREddJEvzguh74X4ZS6vL%2BnX8kFHrbbQlzQ4BCVMJcCg%3D%3D"
        
        let stringURL = "\(endPointURL)ServiceKey=\(serviceKey)&regId=\(regId)&_type=json"
        
        let url = URL(string: stringURL)!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        //request.addValue("Authorization", forHTTPHeaderField: serviceKey)
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
//        let param = ["regId": "\(regId)",
//                     "_type": "json"]

//        let params = try! JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.prettyPrinted)
//
//        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { (data, res, error) in
            if let error = error {
                log.error(error)
                complete(error, nil)
            } else {
        
                if let httpStatus = res as? HTTPURLResponse, httpStatus.statusCode != 200, httpStatus.statusCode != 201 {
                    complete(error, nil)
                } else {
                    if let data = data {
                        do {
                            let weather = try JSONDecoder().decode(Model.Weather.self, from: data)
                            
                            complete(nil, weather)
                            
                        } catch {
                            log.error(error)
                            complete(error, nil)
                        }
                    } else {
                        log.error("data is nil")
                        complete(nil, nil)
                    }
                }
            }
        }.resume()
    }
}
