//
//  ContactTableViewCell.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var headImageV: UIImageView!
    
    @IBOutlet weak var titleName: UILabel!
    
    var model: ContactModel? {
        didSet {
            headImageV.image = model?.headImage
            headImageV.layer.cornerRadius = headImageV.frame.width/2.0

            if (model?.contactName?.characters.count)! > 0 {
                titleName.text = model?.contactName
            }else {
                titleName.text = model?.nikeName
            }
        }
    }
    
    class func cellWithTableView(tableView: UITableView) ->  ContactTableViewCell {
        //Swift-优雅的 NSStringFromClass 替代方案
        let ID: String =  String(describing: self) //"ConsumeTableViewCell"
        var cell: ContactTableViewCell? = tableView.dequeueReusableCell(withIdentifier: ID) as? ContactTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed(ID, owner: nil, options: nil)?.last as? ContactTableViewCell
        }
        return cell!
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleName.font = UIFont.systemFont(ofSize: 15.0)
        headImageV.layer.cornerRadius = headImageV.frame.width/2.0
        headImageV.layer.masksToBounds = true
        headImageV.backgroundColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
