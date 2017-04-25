//
//  ContactModel.swift
//  swift_learn
//
//  Created by zhengxl on 2017/4/22.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import Foundation
import UIKit

class ContactModel: NSObject {
    var headImage: UIImage? //头像
    var contactName: String?
    //var nikeName: String?
    var organization: String?
    var jobTitle: String?
    var department: String?
    var note: String?
    var phoneAr: [String]? = Array()
    var emailAr: [String]? = Array()
    var addressAr: [String]? = Array()
    
}
