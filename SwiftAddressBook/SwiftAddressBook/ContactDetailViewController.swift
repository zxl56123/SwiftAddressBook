//
//  ContactDetailViewController.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var topView: UIView?
    
    var model: ContactModel?

    var selectedBlock: ((_ selectedModel: ContactModel, _ phoneNum: String) -> Void)? = nil

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
        let phoneNum = model?.phoneAr?[indexPath.row]
        //回调block
        self.selectedBlock!(model!,phoneNum!)
        
        var navArr: [UIViewController] = Array()
        
        //删除联系人列表页面
        for vc: UIViewController in (self.navigationController?.viewControllers)! {
            
            if !vc.isKind(of: ContactListViewController.self) {
                navArr.append(vc)
            }
        }
        
        self.navigationController?.setViewControllers(navArr, animated: false)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - lazy
    lazy var tableView: UITableView = {
        let tempTable = UITableView(frame: CGRect(x: 0, y: 100 , width: self.view.frame.width, height: self.view.frame.height - 100 - 64))
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
        
        self.initTopView()
        self.view.addSubview(self.tableView)
    }
    
    func initTopView() {
        topView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        self.view.addSubview(topView!)
        
        let headImageV = UIImageView(frame: CGRect(x: 12, y: 12, width: 64, height: 64))
        topView?.addSubview(headImageV)
        headImageV.layer.masksToBounds = true
        headImageV.layer.cornerRadius = 64/2.0
        headImageV.backgroundColor = UIColor.lightGray
        
        headImageV.image = model?.headImage
        
        let titleLab = UILabel(frame: CGRect(x: headImageV.frame.maxX + 12, y: headImageV.frame.maxY - headImageV.frame.height/2.0, width: self.view.frame.width - (headImageV.frame.maxY - headImageV.frame.height/2.0) - 12 , height: 21))
        topView?.addSubview(titleLab)
        
        titleLab.text = model?.contactName
        
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
