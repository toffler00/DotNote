//
//  AppTarget.swift
//  Orbit
//
//  Created by David Koo on 25/08/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation

class AppTarget {
    enum Config {
        case dev, prod
    }
    
    static var config: Config {
        if let buildMode = Bundle.main.object(forInfoDictionaryKey: "Deployment") as? String {
            if buildMode == "dev" {
                return .dev
            } else if buildMode == "prod" {
                return .prod
            } else {
                return .dev
            }
        } else {
            return .dev
        }
    }
}
