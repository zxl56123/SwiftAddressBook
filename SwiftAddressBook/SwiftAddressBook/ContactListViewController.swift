//
//  ContactListViewController.swift
//  SwiftAddressBook
//
//  Created by zhengxl on 2017/4/24.
//  Copyright © 2017年 jashon jack. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

let SCREENHEIGHT = UIScreen.main.bounds.size.height
let SCREENWIDTH = UIScreen.main.bounds.size.width


class ContactListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource {

    //address Book对象，用来获取电话簿句柄
    var addressBook: ABAddressBook?
    var contactAr = [String:[ContactModel]]()
    var contactTitleAr = [String]()
    
    var selectedContact: ((_ selectedModel: ContactModel, _ phoneNum: String) -> Void)? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "通讯录"
        
        //获取通讯录
        
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
                    
                    //异步处理
                    let queue = DispatchQueue(label: "com.hgp.book", qos: DispatchQoS.utility, attributes: .concurrent)
                    queue.async {
//                        //获取并遍历所有联系人记录
//                        let allRecords: [ContactModel]? = self.readRecords();
//                        //排序
//                        //(self.contactAr, self.contactTitleAr) = self.allContactsSort(byContacts: allRecords)
//                        //返回主线程刷新UI
//                        DispatchQueue.main.async {
//                            //刷新tableview
//                            self.tableView.reloadData()
//                        }
                    }
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
            
            //异步处理
            let queue = DispatchQueue(label: "com.hgp.book", qos: DispatchQoS.utility, attributes: .concurrent)
            queue.async {
                //获取并遍历所有联系人记录
                (self.contactAr, self.contactTitleAr) = self.readRecords();
                //排序
                //(self.contactAr, self.contactTitleAr) = self.allContactsSort(byContacts: allRecords)
                //返回主线程刷新UI
                DispatchQueue.main.async {
                    //刷新tableview
                    self.tableView.reloadData()
                }
            }
            
        }

    }
    
    //获取并遍历所有联系人记录
    func readRecords() -> ([String:[ContactModel]],[String]) {
        let sysContacts:NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook as ABAddressBook)
            .takeRetainedValue() as NSArray
        
        var addressBookDict = [String:[ContactModel]]()
        
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
            
            let contactName = lastName + firstName
            //tempModel.contactName = lastName + firstName
            
            //昵称
            let nikeName = ABRecordCopyValue(contact as ABRecord, kABPersonNicknameProperty)?
                .takeRetainedValue() as! String? ?? ""
            print("昵称：\(nikeName)")
            //tempModel.nikeName = nikeName
            
            if contactName.characters.count > 0 {
                tempModel.contactName = contactName
            }else {
                tempModel.contactName = nikeName
            }
            
            

            
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
            
            
            // 获取到姓名的大写首字母
            let firstLetterString = getFirstLetterFromString(aString: tempModel.contactName!)
            
            if addressBookDict[firstLetterString] != nil {
                // swift的字典,如果对应的key在字典中没有,则会新增
                addressBookDict[firstLetterString]?.append(tempModel)
                
            } else {
                let arrGroupNames = [tempModel]
                addressBookDict[firstLetterString] = arrGroupNames as? [ContactModel]
            }
        }
        
        // 将addressBookDict字典中的所有Key值进行排序: A~Z
        var nameKeys = Array(addressBookDict.keys).sorted()
        
        // 将 "#" 排列在 A~Z 的后面
        if nameKeys.first == "#" {
            nameKeys.insert(nameKeys.first!, at: nameKeys.count)
            nameKeys.remove(at: 0);
        }
        
        return (addressBookDict,nameKeys)
        
    }
    
    // MARK: - 获取联系人姓名首字母(传入汉字字符串, 返回大写拼音首字母)
    func getFirstLetterFromString(aString: String) -> (String) {
        
        if aString.characters.count > 0 {
            
            // 注意,这里一定要转换成可变字符串
            let mutableString = NSMutableString.init(string: aString)
            // 将中文转换成带声调的拼音
            CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
            // 去掉声调(用此方法大大提高遍历的速度)
            let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
            // 将拼音首字母装换成大写
            let strPinYin = polyphoneStringHandle(nameString: aString, pinyinString: pinyinString).uppercased()
            // 截取大写首字母
            let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
            // 判断姓名首位是否为大写字母
            let regexA = "^[A-Z]$"
            let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
            return predA.evaluate(with: firstString) ? firstString : "#"
        }else {
            return "#"
        }
    }
    
    /// 多音字处理
    func polyphoneStringHandle(nameString:String, pinyinString:String) -> String {
        if nameString.hasPrefix("长") {return "chang"}
        if nameString.hasPrefix("沈") {return "shen"}
        if nameString.hasPrefix("厦") {return "xia"}
        if nameString.hasPrefix("地") {return "di"}
        if nameString.hasPrefix("重") {return "chong"}
        
        return pinyinString;
    }
    
    
    //MARK: - tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return (contactTitleAr.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = contactTitleAr[section]
        let array = contactAr[key]
        return array!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContactTableViewCell.cellWithTableView(tableView: tableView)
        //赋值
        let modelArray = contactAr[(contactTitleAr[indexPath.section])]
        let model: ContactModel = modelArray![indexPath.row]
        
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
        return contactTitleAr[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        
        let modelArray = contactAr[(contactTitleAr[indexPath.section])]
        let model: ContactModel = modelArray![indexPath.row]
        
        let contactDetailVC = ContactDetailViewController()
        contactDetailVC.model = model
        contactDetailVC.selectedBlock = { (_ selectedModel: ContactModel, _ phoneNum: String) -> Void in
            self.selectedContact!(selectedModel, phoneNum)
        }
        
        self.navigationController?.pushViewController(contactDetailVC, animated: true)
    }
    
    
    //MARK: - lazy
    lazy var tableView: UITableView = {
        let tempTable = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SCREENHEIGHT - 64))
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
        
        if !self.view.subviews.contains(tableView) {

            self.view.addSubview(self.tableView)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
