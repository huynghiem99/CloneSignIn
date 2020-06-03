//
//  ViewController.swift
//  CloneSignIn
//
//  Created by macOS on 6/1/20.
//  Copyright © 2020 macOS. All rights reserved.
//

import UIKit
import Alamofire
import MagicMapper
import RxSwift
import RealmSwift
import SwiftyJSON

class ViewController: UIViewController,UITextFieldDelegate {
    
    
    //outlet
    @IBOutlet weak var textFieldEmail:UITextField!
    @IBOutlet weak var textFieldPassword:UITextField!
    @IBOutlet weak var lblWariningLoginPassword:UILabel!
    @IBOutlet weak var lblWariningLoginEmail:UILabel!
    @IBOutlet weak var viewUnderTextFieldEmail:UIView!
    @IBOutlet weak var viewUnderTextFieldPassWord:UIView!
    @IBOutlet weak var btnSignIn:UIButton!
    @IBOutlet weak var btnEyeHiddenOrNot: UIButton!
    
    //var
    let link = "https://fordevv2.gatbook.org/api/v1/user/login_by_email" //post
    let userRequest = "https://fordevv2.gatbook.org/api/v1/user/self/info" //get
    var hidden:Bool = false
    
    //action
    @IBAction func doSignIn(_ sender: Any) {
        guard let usermail:String = textFieldEmail.text else {return}
        guard let password:String = textFieldPassword.text else {return}
        if(!usermail.contains("@gmail.com")){
            self.lblWariningLoginEmail.isHidden = false
            self.lblWariningLoginEmail.text = "Sai cấu trúc"
        }
        hiddenLblWarning()
        alamofireRequest()
        checkPasswordEmtyOrNot()
        checkEmailEmtyOrNot()
        
    }
    
    
    @IBAction func doDeleteEmaiInTextField(_ sender: Any) {
        textFieldEmail.text = ""
    }
    
    @IBAction func doShowPassword(_ sender: Any) {
        
        if hidden == true {
            textFieldPassword.isSecureTextEntry = true
            btnEyeHiddenOrNot.setImage(UIImage.init(named: "eye"), for: .normal)
        }
        
        if hidden == false {
            textFieldPassword.isSecureTextEntry = false
            btnEyeHiddenOrNot.setImage(UIImage.init(named: "eyeSlash"), for: .normal)
        }
        hidden = !hidden
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        setUpTextFieldEmailAndPassword()
        drawLineUnderTextField()
        cornerRadius()
        setUpNavigationBar()
        hideKeyboardWhenTappedAround()
        dissMissKeyBoardWhenTapReturn()
        hiddenLblWarning()
    }
    
    func hiddenLblWarning(){
        lblWariningLoginPassword.isHidden = true
        lblWariningLoginEmail.isHidden = true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    
    func dissMissKeyBoardWhenTapReturn(){
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    

    
    func setUpNavigationBar(){
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 90/255, green: 164/255, blue: 204/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)]
    }
    
    func setUpTextFieldEmailAndPassword(){
        textFieldEmail.borderStyle = UITextField.BorderStyle.none;
        textFieldEmail.layer.borderWidth = 0;
        textFieldPassword.borderStyle = UITextField.BorderStyle.none;
        textFieldPassword.layer.borderWidth = 0;
        textFieldPassword.isSecureTextEntry = true
    }
    
    func cornerRadius(){
        btnSignIn.layer.cornerRadius = 5
    }
    
    func alamofireRequest(){
        AF.request(link, method: .post, parameters: ["email": textFieldEmail.text! , "password":textFieldPassword.text! , "uuid" : "5b621a87-6905-4191-8540-d3f0637cf79d"], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON{ (respone) in
            switch respone.result{
            case .success(let value):
                if let jsonIncludeToken = value as? KeyValue {
                    if let status = jsonIncludeToken["status"] as? Int{
                        if status == 200 {
                            let alert = UIAlertController(title: "Đăng nhập thành công", message: "Bạn đã đăng nhập thành công", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        if status != 200 {
                            let alert = UIAlertController(title: "Đăng nhập thất bại", message: "Bạn đã đăng nhập thất bại", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    if let dataIncludeToken = jsonIncludeToken["data"] as? KeyValue{
                        if let token = dataIncludeToken["loginToken"] as? String{
                            AF.request(self.userRequest, method: .get, headers: ["Authorization":"Bearer \(token)"], interceptor: nil, requestModifier: nil).responseJSON { (respone) in
                                switch respone.result {
                                case .success(let value):
                                    if let infoJSON = value as? KeyValue{
                                        if let data = infoJSON["data"] as? KeyValue{
                                            let user = User()
                                            user.name = data["name"] as? String
                                            user.phoneNumber = data["phoneNumber"] as? String
                                            
                                            let realm = try! Realm()
                                            try! realm.write{
                                                realm.add(user)
                                            }
                                        }
                                        
                                    }
                                case .failure(let err):
                                    print("\(err) failllllllllllll1")
                                }
                            }
                            
                        }
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    
    func checkPasswordEmtyOrNot(){
        if textFieldPassword.text?.count == 0 {
            self.lblWariningLoginPassword.isHidden = false
            self.lblWariningLoginPassword.text = "Password chưa được nhập"
        }
    }
    
    func checkEmailEmtyOrNot(){
        if textFieldEmail.text?.count == 0 {
            self.lblWariningLoginEmail.isHidden = false
            self.lblWariningLoginEmail.text = "Email chưa được nhập"
        }
    }
    
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    func drawLineUnderTextField(){
        drawLineFromPoint(start: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 350, y: 0), ofColor: UIColor(red: 225/255, green: 229/255, blue: 230/255, alpha: 1.0), inView: viewUnderTextFieldEmail)
        drawLineFromPoint(start: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 350, y: 0), ofColor: UIColor(red: 225/255, green: 229/255, blue: 230/255, alpha: 1.0), inView: viewUnderTextFieldPassWord)
    }
    
    
}

