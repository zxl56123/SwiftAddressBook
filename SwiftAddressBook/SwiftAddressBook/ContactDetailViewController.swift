//
//  ContactDetailViewController.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var headImageV: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    
    @IBOutlet weak var ContactView: UIView!
    
    var model: ContactModel?

    let cellHeight: CGFloat = 44.00
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "详情页"
        
        
    }

    
    //MARK: - tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (model?.phoneAr?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //赋值
        cell.textLabel?.text = model?.phoneAr?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "手机"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        
        //回调
        
        
    }
    
    //MARK: - lazy
    lazy var tableView: UITableView = {
        let tempTable = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-64))
        tempTable.delegate = self
        tempTable.dataSource = self
        tempTable.tableFooterView = UIView(frame:CGRect.zero)
        
        return tempTable
    }()
    
    //MARK: - viewController 生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.ContactView.subviews.contains(tableView) {
            self.ContactView.addSubview(self.tableView)
        }
        
        headImageV.layer.masksToBounds = true
        headImageV.layer.cornerRadius = 64/2.0
        headImageV.backgroundColor = UIColor.lightGray

        headImageV.image = model?.headImage
        titleName.text = model?.contactName
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
