//
//  ProxityUtil.swift
//  Proxi
//
//  Created by Siyuan Gao on 5/7/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation

func getInitial(name: String) -> String {
    var nameArr = split(name) { $0 == " "}
    if(nameArr.count < 2) {
        return String(nameArr[0][nameArr[0].startIndex])
    } else {
        let str1 = String(nameArr[0][nameArr[0].startIndex])
        let str2 = String(nameArr[1][nameArr[1].startIndex])
        return str1 + str2
    }
}

func randomColor() -> UIColor{
    
    var randomRed:CGFloat = CGFloat(drand48())
    var randomGreen:CGFloat = CGFloat(drand48())
    var randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    
}