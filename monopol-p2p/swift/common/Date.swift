//
//  extension.swift
//  swift_skyway
//
//  Created by onda on 2018/06/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//
import Foundation
import UIKit

/*
 let dateString = Date() //現在時刻
 let formatter = DateFormatter()
 formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //フォーマット合わせる
 let posTimeText:String = formatter.date(from: dateString!)!.timeAgoSinceDate(numericDates: true)
 */
extension Date {
    func timeAgoSinceDate(numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let now = NSDate()
        let earliest = now.earlierDate(self as Date)
        let latest = (earliest == now as Date) ? self : now as Date
        let components = calendar.dateComponents([.minute , .hour , .day , .weekOfYear , .month , .year , .second], from: earliest, to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) 年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) ヶ月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 ヶ月前"
            } else {
                return "先月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) 週間前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 週間前"
            } else {
                return "先週"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) 日前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 日前"
            } else {
                return "昨日"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) 時間前"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 時間前"
            } else {
                return "1 時間前"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) 分前"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 分前"
            } else {
                return "1 分前"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) 秒前"
        } else {
            return "数秒前"
        }
        
    }
    
}
