//
//  CommonSwift.swift
//  swift_learn
//
//  Created by zhengxl on 2017/4/23.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import Foundation

extension String{
    func transformToPinYin()->String{
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyinStr = String(mutableString)
        
        //去除字符串中的空格
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        let resultStr = pinyinStr.trimmingCharacters(in: whitespace)
        
        return resultStr.uppercased()
    }
}
