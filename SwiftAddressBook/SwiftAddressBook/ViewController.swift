//
//  ViewController.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "首页"
        self.view.backgroundColor = UIColor.white
        
        let btn = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 30))
        self.view.addSubview(btn)
        
        btn.setTitle("选择联系人", for: .normal)
        btn.setTitleColor(UIColor.green, for: .normal)
        btn.addTarget(self, action: #selector(tapBtn(_:)), for: .touchUpInside)
        
    }
    
    func tapBtn(_ sender: UIButton){
        let contactListVC = ContactListViewController()
        contactListVC.selectedContact = { (_ selectedModel: ContactModel, _ phoneNum: String) -> Void in
            
            if (selectedModel.contactName?.characters.count)! > 0 {
                print(selectedModel.contactName! + phoneNum)
            }else {
                print(selectedModel.nikeName! + phoneNum)
            }
            
        
        }
        
        self.navigationController?.pushViewController(contactListVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

