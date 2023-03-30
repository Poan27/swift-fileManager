//
//  ViewController.swift
//  Storage
//
//  Created by 呂晨汝 on 2023/3/13.
// 補充core data 1：https://www.tpisoftware.com/tpu/articleDetails/2448
// 補充core data 2：https://ithelp.ithome.com.tw/articles/10246041
// 補充fileManager 1：https://medium.com/@leeningthebest/關於儲存資料-filemanager-u-d1b7ae697914
// 補充fileManager 2：https://blog.csdn.net/u011146511/article/details/79362028

/*
 UserDefaults:
 適合少量的資量儲存（Boolean,一個數字,一個字串）可以帶有Array或者Dictionary,甚至於日期時間也都可以存,UserDefaults只能存放資料,UserDefaul是放在沙盒內,比如說帳號密碼就不適合放在這。
 */
/*
 Bundle Container:
 舉凡圖片、影音檔、SQLite 等檔案最常放置的地方就是 Bundle Container 了（如圖2），此目錄下的檔案是唯讀的
 */

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UISlider!
    @IBOutlet weak var ageSelectedLabel: UILabel!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var sex: UISegmentedControl!
    
    let fileManager = FileManager.default       //1
    let myDirectory = NSHomeDirectory() + "/Documents/Profile"      //2
    
    private var profileTXT : URL? {
        documentDirectoryURL?.appendingPathComponent("Profile").appendingPathExtension("txt")
    }
    
    private var documentDirectoryURL: URL? {
        //1+2
        //withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
        try! fileManager.createDirectory(atPath: myDirectory,withIntermediateDirectories: true, attributes: nil)
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Profile")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        someMethod()
        initView()
    }
    
    func initView() {
        //FIXME: 將先前存的資料取出並顯示(1)
        guard let stringFile = profileTXT else {         //方法一路徑
            print("string file url error")
            return
        }
        //方法1
        var birthdaytxt = ""
        var phonetxt = ""
        
        do {
            let readHandler = try FileHandle(forReadingFrom: stringFile)
            let data = readHandler.readDataToEndOfFile()
            let readString = String(data: data, encoding: String.Encoding.utf8)
//            print("文件内容1: \(readString)")
            if let string = readString {
                let txt = string.split(separator: "|")
                birthdaytxt = String(txt[0])
                phonetxt = String(txt[1])
            }
        } catch {
            print("1 error: \(error.localizedDescription)")
        }
        //方法二
        let appDirectory = myDirectory + "/Storage.jpg" //方法二路徑
        let imageData = fileManager.contents(atPath: appDirectory)
        if let imageData = imageData {
            let readImage = UIImage(data: imageData)
            imageView.image = readImage
        }
//        print("文件内容2: \(readImage)")
        //顯示在畫面上
        name.text = UserDefaults.standard.string(forKey: "USER_NAME")
        sex.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "USER_SEX")
        age.value = Float(UserDefaults.standard.integer(forKey: "USER_AGE"))
        ageSelectedLabel.text = String(Int(age.value))
        birthday.text = birthdaytxt
        phone.text = phonetxt
    }
    
    func validate() -> Bool{
        guard let nameStr = name.text, !nameStr.isEmpty else {
            showAlert(title: "資料錯誤訊息", message: "姓名不能為空白")
            return false
        }
        guard let birthdayStr = birthday.text, !birthdayStr.isEmpty  else {
            showAlert(title: "資料錯誤訊息", message: "生日不能為空白")
            return false
        }
        guard let birthdayInt = Int(birthdayStr), birthdayInt >= 0, birthdayStr.count == 8 else {
            showAlert(title: "資料錯誤訊息", message: "請輸入正確格式,如：202303")
            return false
        }
        guard let phoneStr = phone.text, !phoneStr.isEmpty else {
            showAlert(title: "資料錯誤訊息", message: "電話不能為空白")
            return false
        }
        guard let phoneInt = Int(phoneStr), phoneInt >= 0, phoneStr.count == 10 else {
            showAlert(title: "資料錯誤訊息", message: "請輸入正確電話格式")
            return false
        }
        return true
    }
    
    func showAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func someMethod() {
        // 獲取使用者文檔目錄路徑(1)
        let urlForDocument = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urlForDocument[0] as URL
        print("FileURL: ", url)
        // 判斷文件或文件夾是否存在(1+2)
        let exist = fileManager.fileExists(atPath: myDirectory)
        print("App directory exist: ", exist)
        if let stringFile = profileTXT {
            let stringExist = fileManager.fileExists(atPath: stringFile.path)
            print("stringFile exist: ", exist)
        } else {
            print("stringFile not exist")
        }
    }
    
    func saveProfile() {
        // 1. UserDefaults
        UserDefaults.standard.set(name.text, forKey: "USER_NAME")
        UserDefaults.standard.set(Int(age.value), forKey: "USER_AGE")
        UserDefaults.standard.set(sex.selectedSegmentIndex, forKey: "USER_SEX")
        // 2. FileManager
            // save birthday, phone
        if let profileURL = documentDirectoryURL?.appendingPathComponent("Profile").appendingPathExtension("txt") {
            do {
                let profileString = birthday.text! + "|" + phone.text!
                try profileString.write(to: profileURL, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("save profileString error: \(error.localizedDescription)")
            }
        } else {
            print("profileURL error!!!")
        }
            // save image
        if let imageURL = documentDirectoryURL?.appendingPathComponent("Storage").appendingPathExtension("jpg") {
            print("imageURL: \(imageURL)")
            let data = imageView.image!.pngData()!
            try? data.write(to: imageURL)
        } else {
            print("imageURL error!!!")
        }
    }
    
    @IBAction func selectImageOprions(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let segmentImage = sender.imageForSegment(at: index)
        imageView.image = segmentImage
    }
    
    @IBAction func selectAge(_ sender: UISlider) {
        ageSelectedLabel.text = String(Int(sender.value))
    }
    
    @IBAction func save(_ sender: UIButton) {
        if validate() {
            saveProfile()
        }
        print(UserDefaults.standard.string(forKey: "USER_NAME") ?? "name is nil")
        print(UserDefaults.standard.integer(forKey: "USER_AGE"))
        print(UserDefaults.standard.integer(forKey: "USER_SEX"))
    }
}
