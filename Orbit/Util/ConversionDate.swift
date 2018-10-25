//
//  ConversionDate.swift
//  Orbit
//
//  Created by ilhan won on 22/10/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func dateToString(in date : Date, dateFormat : String) -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let calendarComponent = dateFormatter.calendar.component(.weekday, from: date) - 1
        dateFormatter.dateFormat = dateFormatter.weekdaySymbols[calendarComponent]
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    func stringToDate(in date : String) -> Date {
        let date = Date()
        return date
    }
    
    func getWeekDay(in date : Date, dateFormat : String) -> String{
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let weekDay = dateFormatter.string(from: today).capitalized
        return weekDay
    }
    
}
