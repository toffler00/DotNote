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
    
    func getDate(dateFormat : String) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "kr_KR")
        let dateToString = dateFormatter.string(from: date)
        print(dateToString)
        return dateToString
    }
    
    func dateToString(in date : Date, dateFormat : String) -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let calendarComponent = dateFormatter.calendar.component(.weekday, from: date) - 1
        dateFormatter.dateFormat = dateFormatter.weekdaySymbols[calendarComponent]
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    func stringToDate(in date : String, dateFormat : String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "kr_KR")
        let stringToDate = dateFormatter.date(from: date)
        return stringToDate!
    }
    
    func getWeekDay(in date : Date, dateFormat : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        let weekDay = dateFormatter.string(from: date).capitalized
        return weekDay
    }
    
}
