//
//  DateExtension.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/23.
//

import Foundation

@available(iOS 13.0, *)
extension Date {
    var relativeTime_abbreviated: String {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if Date(timeIntervalSinceNow: -6000) > self{
            return "오래전"
        } else {
        return formatter.localizedString(for: self, relativeTo: Date())
        }
    }
    
    var koreanAge: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
extension String {
    var stringToDate: Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date: Date = dateFormatter.date(from: self) ?? Date()
        return date
    }
    
    var stringTodateAge: Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy.MM.dd."
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date: Date = dateFormatter.date(from: self) ?? Date()
        
        return date
    }
}

