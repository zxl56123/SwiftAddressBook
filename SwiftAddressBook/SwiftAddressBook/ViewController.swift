//
//  ViewController.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit

import AddressBook
import AddressBookUI

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource {
    
    //address Book对象，用来获取电话簿句柄
    var addressBook: ABAddressBook?
    var contactAr: [Any]? = Array()
    var contactTitleAr: [String]? = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "通讯录"
        
        //定义一个错误标记对象，判断是否成功
        var error:Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        //发出授权信息
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        if (sysAddressBookStatus == ABAuthorizationStatus.notDetermined) {
            print("requesting access...")
            var _:Unmanaged<CFError>? = nil
            //addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    //获取并遍历所有联系人记录
                    let allRecords: [ContactModel]? = self.readRecords();
                    //排序
                    (self.contactAr, self.contactTitleAr) = self.allContactsSort(byContacts: allRecords)
                    //刷新tableview
                    self.tableView.reloadData()
                }
                else {
                    print("error")
                }
            })
        }
        else if (sysAddressBookStatus == ABAuthorizationStatus.denied ||
            sysAddressBookStatus == ABAuthorizationStatus.restricted) {
            print("access denied")
        }
        else if (sysAddressBookStatus == ABAuthorizationStatus.authorized) {
            print("access granted")
            
            //获取并遍历所有联系人记录
            let allRecords: [ContactModel]? = self.readRecords()
            //排序
            (self.contactAr, self.contactTitleAr) = self.allContactsSort(byContacts: allRecords)
            
            //刷新tableview
            self.tableView.reloadData()
        }
    }
    
    //获取并遍历所有联系人记录
    func readRecords() -> [ContactModel]? {
        let sysContacts:NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook as ABAddressBook)
            .takeRetainedValue() as NSArray
        
        var tempContactAr :[ContactModel]? = Array()
        
        for contact in sysContacts {
            
            let tempModel: ContactModel! = ContactModel()
            
            //            tempModel.contactName = "swift"
            //
            //            tempContactAr?.append(tempModel)
            //
            //            continue
            
            //获取头像
            var image: UIImage!
            
            if (ABPersonHasImageData(contact as ABRecord)) {
                let imgData = ABPersonCopyImageDataWithFormat(contact as ABRecord, kABPersonImageFormatOriginalSize).takeRetainedValue()
                image = UIImage(data: imgData as Data)
                //数据模型赋值
                tempModel.headImage = image
            }
            
            //获取姓
            let lastName: String = ABRecordCopyValue(contact as ABRecord, kABPersonLastNameProperty)? .takeRetainedValue() as! String? ?? ""
            print("姓：\(lastName)")
            
            //获取名
            let firstName: String = ABRecordCopyValue(contact as ABRecord, kABPersonFirstNameProperty)? .takeRetainedValue() as! String? ?? ""
            print("名：\(firstName)")
            
            //tempModel.contactName = lastName + firstName
            tempModel.contactName = String(lastName) + String(firstName)
            
            //昵称
            let nikeName = ABRecordCopyValue(contact as ABRecord, kABPersonNicknameProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("昵称：\(nikeName)")
            tempModel.nikeName = nikeName
            
            //公司（组织）
            let organization = ABRecordCopyValue(contact as ABRecord, kABPersonOrganizationProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("公司（组织）：\(organization)")
            tempModel.organization = organization
            
            //职位
            let jobTitle = ABRecordCopyValue(contact as ABRecord, kABPersonJobTitleProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("职位：\(jobTitle)")
            tempModel.jobTitle = jobTitle
            
            //部门
            let department = ABRecordCopyValue(contact as ABRecord, kABPersonDepartmentProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("部门：\(department)")
            tempModel.department = department
            
            //备注
            let note = ABRecordCopyValue(contact as ABRecord, kABPersonNoteProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("备注：\(note)")
            tempModel.note = note
            
            //获取电话
            let phoneValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord, kABPersonPhoneProperty).takeRetainedValue()
            if phoneValues != nil {
                print("电话：")
                for i in 0 ..< ABMultiValueGetCount(phoneValues){
                    
                    // 获得标签名
                    let phoneLabel = ABMultiValueCopyLabelAtIndex(phoneValues, i).takeRetainedValue()
                        as CFString;
                    // 转为本地标签名（能看得懂的标签名，比如work、home）
                    let localizedPhoneLabel = ABAddressBookCopyLocalizedLabel(phoneLabel)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(phoneValues, i)
                    let phone = value?.takeRetainedValue() as! String
                    
                    tempModel.phoneAr?.append(phone)
                    
                    print("  \(localizedPhoneLabel):\(phone)")
                }
            }
            
            //获取Email
            let emailValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord, kABPersonEmailProperty).takeRetainedValue()
            if emailValues != nil {
                print("Email：")
                for i in 0 ..< ABMultiValueGetCount(emailValues){
                    
                    // 获得标签名
                    let label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue()
                        as CFString;
                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(emailValues, i)
                    let email = value?.takeRetainedValue() as! String
                    
                    tempModel.emailAr?.append(email)
                    
                    print("  \(localizedLabel):\(email)")
                }
            }
            
            //获取地址
            let addressValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord, kABPersonAddressProperty).takeRetainedValue()
            if addressValues != nil {
                print("地址：")
                for i in 0 ..< ABMultiValueGetCount(addressValues){
                    
                    // 获得标签名
                    let label = ABMultiValueCopyLabelAtIndex(addressValues, i).takeRetainedValue()
                        as CFString;
                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(addressValues, i)
                    let addrNSDict:NSMutableDictionary = value!.takeRetainedValue()
                        as! NSMutableDictionary
                    let country:String = addrNSDict.value(forKey: kABPersonAddressCountryKey as String)
                        as? String ?? ""
                    let state:String = addrNSDict.value(forKey: kABPersonAddressStateKey as String)
                        as? String ?? ""
                    let city:String = addrNSDict.value(forKey: kABPersonAddressCityKey as String)
                        as? String ?? ""
                    let street:String = addrNSDict.value(forKey: kABPersonAddressStreetKey as String)
                        as? String ?? ""
                    let contryCode:String = addrNSDict
                        .value(forKey: kABPersonAddressCountryCodeKey as String) as? String ?? ""
                    
                    tempModel.addressAr?.append(country + state + city + street)
                    
                    print("  \(localizedLabel): Contry:\(country) State:\(state) ")
                    print("City:\(city) Street:\(street) ContryCode:\(contryCode) ")
                }
            }
            
            #if false
                //获取纪念日
                let dateValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact as ABRecord, kABPersonDateProperty).takeRetainedValue()
                if dateValues != nil {
                    print("纪念日：")
                    for i in 0 ..< ABMultiValueGetCount(dateValues){
                        
                        // 获得标签名
                        let label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue()
                            as CFString;
                        let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as String
                        
                        let value = ABMultiValueCopyValueAtIndex(dateValues, i)
                        let date = (value?.takeRetainedValue() as? NSDate)?.description ?? ""
                        print("  \(localizedLabel):\(date)")
                    }
                }
                
                
                //获取即时通讯(IM)
                let imValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact as ABRecord, kABPersonInstantMessageProperty).takeRetainedValue()
                if imValues != nil {
                    print("即时通讯(IM)：")
                    for i in 0 ..< ABMultiValueGetCount(imValues){
                        
                        // 获得标签名
                        let label = ABMultiValueCopyLabelAtIndex(imValues, i).takeRetainedValue()
                            as CFString;
                        let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as String
                        
                        let value = ABMultiValueCopyValueAtIndex(imValues, i)
                        let imNSDict:NSMutableDictionary = value!.takeRetainedValue()
                            as! NSMutableDictionary
                        let serves:String = imNSDict
                            .value(forKey: kABPersonInstantMessageServiceKey as String) as? String ?? ""
                        let userName:String = imNSDict
                            .value(forKey: kABPersonInstantMessageUsernameKey as String) as? String ?? ""
                        print("  \(localizedLabel): Serves:\(serves) UserName:\(userName)")
                    }
                }
            #endif
            
            tempContactAr?.append(tempModel)
            
        }
        
        return tempContactAr
        
    }
    
    func allContactsSort(byContacts contacts: Array<ContactModel>?) -> (Array<Any>?, [String]?){
        
        var tempContactAr: [Any]? = Array()
        var tempContactTitleAr: [String]? = Array()
        
        var notNameContact: [ContactModel] = Array()
        
        let headerTitle = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
        
        for title: String in headerTitle {
            
            for  model :ContactModel in contacts! {
                //获取首字母大写
                let pinyin_name = model.contactName?.transformToPinYin()
                let pinyin_nickname = model.nikeName?.transformToPinYin()
                
                var firstStr = ""
                var firstStr_nick = ""
                
                //name
                if (pinyin_name?.characters.count)! > 0 {
                    let index = pinyin_name?.index((pinyin_name?.startIndex)! , offsetBy: 1)
                    firstStr = (pinyin_name?.substring(to: index!))!
                }
                
                //nickname
                if (pinyin_nickname?.characters.count)! > 0 {
                    let index_nick = pinyin_nickname?.index((pinyin_nickname?.startIndex)!, offsetBy: 1)
                    firstStr_nick = (pinyin_nickname?.substring(to: index_nick!))!
                }
                
                if ((firstStr.characters.count) > 0 && isAZ(str: firstStr)) || ((firstStr_nick.characters.count) > 0 && isAZ(str: firstStr_nick)) {
                    
                    if title == firstStr || title == firstStr_nick {
                        
                        if (tempContactTitleAr?.count)! > 0 {
                            if (tempContactTitleAr?[(tempContactTitleAr?.count)! - 1])! == title {
                                //已经添加过
                                var existAr: Array<ContactModel> = tempContactAr?[(tempContactAr?.count)! - 1] as! Array<ContactModel>
                                existAr.append(model)
                                tempContactAr?[(tempContactAr?.count)! - 1] = existAr
                            }else {
                                //没有添加
                                tempContactTitleAr?.append(title)
                                var tempAr: [ContactModel] = Array()
                                tempAr.append(model)
                                tempContactAr?.append(tempAr)
                                
                            }
                        }else {
                            //没有添加
                            tempContactTitleAr?.append(title)
                            var tempAr: [ContactModel] = Array()
                            tempAr.append(model)
                            tempContactAr?.append(tempAr)
                            
                        }
                    }
                }else {
                    if notNameContact.count > 0 {
                        //# 特殊字符处理
                        var isExist: Bool = false
                        for index: Int in 0..<notNameContact.count {
                            
                            if model == notNameContact[index] {
                                //已经存在
                                isExist = true
                                break
                            }
                        }
                        
                        if false == isExist {
                            //不存在
                            notNameContact.append(model)
                        }
                        
                    }else {
                        //不存
                        notNameContact.append(model)
                    }
                }
                
            }
        }
        
        if (notNameContact.count != 0) {
            tempContactTitleAr?.append("#")
            tempContactAr?.append(notNameContact)
        }
        
        print(tempContactAr ?? "")
        print(tempContactTitleAr ?? "")
        
        return (tempContactAr, tempContactTitleAr)
    }
    
    //判断是否是字母
    func isAZ(str: String) -> Bool {
        
        let pattern = "^[A-Za-z]"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue:0))
        let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, str.characters.count))
        
        if res.count > 0 {
            return true
        }
        
        return false
        
    }
    
    //MARK: - tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return (contactAr?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (contactAr![section] as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContactTableViewCell.cellWithTableView(tableView: tableView)
        //赋值
        var secAr: [ContactModel] = contactAr![indexPath.section] as! [ContactModel]
        let model: ContactModel = secAr[indexPath.row]
        
        cell.model = model
        
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactTitleAr
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactTitleAr?[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        
        var secAr: [ContactModel] = contactAr![indexPath.section] as! [ContactModel]
        let model: ContactModel = secAr[indexPath.row]
        
        if model.phoneAr?.count == 0 {
            //没有手机联系人
            
        }else if model.phoneAr?.count == 1 {
            //直接回调
            
        }else {
            //没有手机联系人、多个联系人
        }
    }
 
    
    //MARK: - lazy
    lazy var tableView: UITableView = {
        let tempTable = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-64))
        tempTable.delegate = self
        tempTable.dataSource = self
        
        return tempTable
    }()
    
    //MARK: - viewController 生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.view.subviews.contains(tableView) {
            self.view.addSubview(self.tableView)
        }
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

