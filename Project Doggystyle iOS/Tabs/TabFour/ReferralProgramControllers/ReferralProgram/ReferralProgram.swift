//
//  ReferralProgram.swift
//  Project Doggystyle iOS
//
//  Created by Charlie Arcodia on 10/14/21.
//

import Foundation
import UIKit
import Firebase

class ReferralProgram : UIViewController, UITextFieldDelegate, CustomAlertCallBackProtocol {
    
    enum CodeState {
        case RandomlyGenerated
        case CustomCode
    }
    
    var clientHasGroomingLocation : Bool?,
        hasRandomCodeBeenGenerated : Bool?,
        handleOne = DatabaseHandle(),
        observingRefTwo = Database.database().reference(),
        codeState = CodeState.RandomlyGenerated,
        isKeyboardPresented : Bool = false
    
    let databaseRef = Database.database().reference()
    
    lazy var backButton : UIButton = {
        
        let cbf = UIButton(type: .system)
        cbf.translatesAutoresizingMaskIntoConstraints = false
        cbf.backgroundColor = .clear
        cbf.tintColor = UIColor.dsOrange
        cbf.contentMode = .scaleAspectFill
        cbf.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        cbf.setTitle(String.fontAwesomeIcon(name: .chevronLeft), for: .normal)
        cbf.addTarget(self, action: #selector(self.handleBackButton), for: UIControl.Event.touchUpInside)
        return cbf
        
    }()
    
    let earnLabel : UILabel = {
        
        let thl = UILabel()
        thl.translatesAutoresizingMaskIntoConstraints = false
        thl.textAlignment = .left
        thl.text = ""
        thl.font = UIFont(name: dsHeaderFont, size: 24)
        thl.numberOfLines = -1
        thl.adjustsFontSizeToFitWidth = true
        thl.textColor = dsFlatBlack
        return thl
        
    }()
    
    let descriptionLabel : UILabel = {
        
        let thl = UILabel()
        thl.translatesAutoresizingMaskIntoConstraints = false
        thl.textAlignment = .left
        thl.text = ""
        thl.font = UIFont(name: rubikRegular, size: 16)
        thl.numberOfLines = -1
        thl.adjustsFontSizeToFitWidth = true
        thl.textColor = dsFlatBlack
        return thl
        
    }()
    
    let createLabel : UILabel = {
        
        let thl = UILabel()
        thl.translatesAutoresizingMaskIntoConstraints = false
        thl.textAlignment = .left
        thl.text = "Create your own referral code!"
        thl.font = UIFont(name: rubikMedium, size: 20)
        thl.numberOfLines = 1
        thl.adjustsFontSizeToFitWidth = true
        thl.textColor = coreOrangeColor
        return thl
        
    }()
    
    lazy var referralTextField: UITextField = {
        
        let etfc = UITextField()
        let placeholder = NSAttributedString(string: "ex: BESTDOG1", attributes: [NSAttributedString.Key.foregroundColor: dsFlatBlack.withAlphaComponent(0.4)])
        etfc.attributedPlaceholder = placeholder
        etfc.translatesAutoresizingMaskIntoConstraints = false
        etfc.textAlignment = .center
        etfc.textColor = dsFlatBlack
        etfc.font = UIFont(name: rubikMedium, size: 15)
        etfc.allowsEditingTextAttributes = false
        etfc.autocorrectionType = .no
        etfc.delegate = self
        etfc.backgroundColor = coreWhiteColor
        etfc.keyboardAppearance = UIKeyboardAppearance.light
        etfc.returnKeyType = UIReturnKeyType.done
        etfc.keyboardType = .alphabet
        etfc.layer.masksToBounds = true
        etfc.layer.cornerRadius = 15
        etfc.leftViewMode = .always
        etfc.layer.borderColor = coreOrangeColor.cgColor
        etfc.layer.borderWidth = 1
        etfc.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        etfc.clipsToBounds = false
        etfc.layer.masksToBounds = false
        etfc.layer.shadowColor = coreBlackColor.withAlphaComponent(0.8).cgColor
        etfc.layer.shadowOpacity = 0.02
        etfc.layer.shadowOffset = CGSize(width: 2, height: 3)
        etfc.layer.shadowRadius = 9
        etfc.layer.shouldRasterize = false
        etfc.isSecureTextEntry = false
        etfc.setRightPaddingPoints(20)
        etfc.autocapitalizationType = .allCharacters
        return etfc
        
    }()
    
    let dogWithGlassesImage : UIImageView = {
        
        let dcl = UIImageView()
        dcl.translatesAutoresizingMaskIntoConstraints = false
        dcl.backgroundColor = .clear
        dcl.contentMode = .scaleAspectFit
        dcl.isUserInteractionEnabled = false
        let image = UIImage(named: "dog_glasses_icon")?.withRenderingMode(.alwaysOriginal)
        dcl.image = image
        
        return dcl
    }()
    
    lazy var submitButton : UIButton = {
        
        let cbf = UIButton(type: .system)
        cbf.translatesAutoresizingMaskIntoConstraints = false
        cbf.setTitle("Submit code", for: UIControl.State.normal)
        cbf.titleLabel?.font = UIFont.init(name: dsHeaderFont, size: 18)
        cbf.titleLabel?.adjustsFontSizeToFitWidth = true
        cbf.titleLabel?.numberOfLines = 1
        cbf.titleLabel?.adjustsFontForContentSizeCategory = true
        cbf.titleLabel?.textColor = coreBlackColor
        cbf.backgroundColor = coreOrangeColor.withAlphaComponent(0.2)
        cbf.layer.cornerRadius = 15
        cbf.layer.masksToBounds = true
        cbf.tintColor = coreOrangeColor
        cbf.addTarget(self, action: #selector(self.doubleCheck), for: .touchUpInside)
        
        return cbf
        
    }()
    
    lazy var createButton : UIButton = {
        
        let cbf = UIButton(type: .system)
        cbf.translatesAutoresizingMaskIntoConstraints = false
        cbf.setTitle("Create a code for me", for: UIControl.State.normal)
        cbf.titleLabel?.font = UIFont.init(name: dsHeaderFont, size: 18)
        cbf.titleLabel?.adjustsFontSizeToFitWidth = true
        cbf.titleLabel?.numberOfLines = 1
        cbf.titleLabel?.adjustsFontForContentSizeCategory = true
        cbf.titleLabel?.textColor = coreBlackColor
        cbf.backgroundColor = coreOrangeColor.withAlphaComponent(0.2)
        cbf.layer.cornerRadius = 15
        cbf.layer.masksToBounds = true
        cbf.tintColor = coreOrangeColor
        cbf.addTarget(self, action: #selector(self.handleRandomCodeGenerator), for: .touchUpInside)
        
        return cbf
        
    }()
    
    let activityIndicator : UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(style: .medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        aiv.backgroundColor = .clear
        
        return aiv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = coreBackgroundWhite
        self.addViews()
        self.fillValues()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func fillValues() {
        
        if self.clientHasGroomingLocation == true {
            
            self.earnLabel.text = "Earn $5 for future Groomz"
            self.descriptionLabel.text = "Re-fur a friend in your neighborhood to Doggystyle"
            
        } else {
            
            self.earnLabel.text = "Re-fur a friend and give them credit towards their first groom"
            self.descriptionLabel.text = "Give a friend grooming credit and get $5 back when they treat their dog to their first groom."
            
        }
    }
    
    func addViews() {
        
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.earnLabel)
        self.view.addSubview(self.descriptionLabel)
        self.view.addSubview(self.createLabel)
        self.view.addSubview(self.referralTextField)
        
        self.view.addSubview(self.createButton)
        self.view.addSubview(self.submitButton)
        self.view.addSubview(self.activityIndicator)
        
        self.backButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        self.backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        self.backButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        self.backButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        
        self.earnLabel.topAnchor.constraint(equalTo: self.backButton.bottomAnchor, constant: 23).isActive = true
        self.earnLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.earnLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.earnLabel.sizeToFit()
        
        self.descriptionLabel.topAnchor.constraint(equalTo: self.earnLabel.bottomAnchor, constant: 29).isActive = true
        self.descriptionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.descriptionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.descriptionLabel.sizeToFit()
        
        self.createLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 13).isActive = true
        self.createLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.createLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.createLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        self.referralTextField.topAnchor.constraint(equalTo: self.createLabel.bottomAnchor, constant: 16).isActive = true
        self.referralTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.referralTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.referralTextField.heightAnchor.constraint(equalToConstant: 79).isActive = true
        
        self.submitButton.topAnchor.constraint(equalTo: self.referralTextField.bottomAnchor, constant: 20).isActive = true
        self.submitButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.submitButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.submitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.createButton.topAnchor.constraint(equalTo: self.submitButton.bottomAnchor, constant: 20).isActive = true
        self.createButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.createButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.referralTextField.centerYAnchor, constant: 0).isActive = true
        self.activityIndicator.rightAnchor.constraint(equalTo: self.referralTextField.rightAnchor, constant: -30).isActive = true
        self.activityIndicator.sizeToFit()
        
    }
    
    @objc func handleKeyboardShow(notification : Notification) {
        
        if self.isKeyboardPresented == true {return}
        
        self.hasRandomCodeBeenGenerated = false
        self.referralTextField.text = ""
        self.handleCodeRemoval()
        self.codeState = .CustomCode
        
        UIView.animate(withDuration: 0.25) {
            self.createButton.alpha = 0
            self.submitButton.alpha = 0
        }
        
        self.isKeyboardPresented = true
    }
    
    @objc func handleKeyboardHide(notification : Notification) {
        
        UIView.animate(withDuration: 0.25) {
            
            self.createButton.alpha = 1
            self.submitButton.alpha = 1
            
        }
        
        self.isKeyboardPresented = false
        
    }
    
    func resignation() {
        self.referralTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignation()
        return false
    }
    
    @objc func handleBackButton() {
        self.handleCodeRemoval()
        self.dismiss(animated: true, completion: nil)
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    @objc func handleCodeRemoval() {
        
        guard let user_uid = Auth.auth().currentUser?.uid else {return}
        let ref = self.databaseRef.child("referral_codes").child(user_uid)
        ref.removeValue()
        userProfileStruct.user_created_referral_code_grab = "nil"
        self.referralTextField.text = ""
        
    }
    
    @objc func fetchAndLoop(passedReferralCode : String, completion : @escaping (_ isCodeTaken : Bool)->()) {
        
        let ref = self.databaseRef.child("referral_codes")
        
        var isCodeTaken : Bool = false
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            //MARK: - FIRE THE LOOP UP
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                if let dict = child.value as? [String : AnyObject] {
                    
                    let referralCode = dict["users_referral_code"] as? String
                    
                    if referralCode == passedReferralCode {
                        isCodeTaken = true
                        break
                    }
                }
            }
            print("here and: \(isCodeTaken)")
            completion(isCodeTaken)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.codeState = .CustomCode
        
        let numbers = ["!","~","@", "#", "$","%","^", "&", "*","(",")", "-", "+","=",".", "?","<",">"]
        for number in numbers{
            if string == number{
                return false
            }
        }
        
        return true
        
    }
    
    @objc func handleRandomCodeGenerator() {
        
        self.codeState = .RandomlyGenerated
        
        self.referralTextField.text = ""
        
        guard let user_uid = Auth.auth().currentUser?.uid else {
            self.handleCustomPopUpAlert(title: "AUTHENTICATION", message: "Seems we do not have authentication for this account. Please log out and log back in.", passedButtons: [Statics.OK])
            return
        }
        
        self.activityIndicator.startAnimating()
        
        let randomArray : [String] = ["LOVESDOGS", "HEARTSDOGS", "LIKESDOGS", "DOGOBSESSION"]
        
        let usersFirstName = userProfileStruct.user_first_name?.uppercased().prefix(7) ?? "NIL"
        
        let stringRandomArrayPicker = randomInt(min: 0, max: randomArray.count - 1),
            randomDigitCreator = random(digits: 3)
        
        let stringIteration = "\(usersFirstName)\(randomArray[stringRandomArrayPicker])\(randomDigitCreator)"
        
        let ref = self.databaseRef.child("referral_codes")
        
        ref.observeSingleEvent(of: .value) { snap in
            
            if snap.exists() {
                
                self.fetchAndLoop(passedReferralCode: stringIteration) { isCodeTaken in
                    
                    if isCodeTaken {
                        self.activityIndicator.stopAnimating()
                        self.referralTextField.layer.borderColor = coreRedColor.cgColor
                        
                    } else {
                        
                        self.completeAndFinalizeCode(referralCode: stringIteration, user_uid: user_uid) { completion in
                          
                            self.referralTextField.text = stringIteration
                            self.activityIndicator.stopAnimating()
                            self.referralTextField.layer.borderColor = coreOrangeColor.cgColor
                            
                        }
                    }
                }
                
            } else {
                
                self.completeAndFinalizeCode(referralCode: stringIteration, user_uid: user_uid) { completion in

                    self.referralTextField.layer.borderColor = coreOrangeColor.cgColor
                    self.referralTextField.text = stringIteration
                    self.activityIndicator.stopAnimating()

                }
            }
        }
    }
    
    func pushOverReferralMonetaryController() {
        
        let referralMonetaryController = ReferralMonetaryController()
        referralMonetaryController.modalPresentationStyle = .fullScreen
        referralMonetaryController.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(referralMonetaryController, animated: true)
    }
    
    func completeAndFinalizeCode(referralCode : String, user_uid : String, completion : @escaping (_ isComplete : Bool)->()) {

        let first_name = userProfileStruct.user_first_name ?? "nil",
            last_name = userProfileStruct.user_last_name ?? "nil",
            firebase_uid = userProfileStruct.users_firebase_uid ?? "nil",
            referralCode = referralCode,
            timeStamp : Double = Date().timeIntervalSince1970
        
        let ref = self.databaseRef.child("referral_codes").child(user_uid)
        
        let values : [String : Any] = ["users_first_name" : first_name, "users_last_name" : last_name, "users_firebase_uid" : firebase_uid, "users_referral_code" : referralCode, "time_stamp" : timeStamp]
        
        ref.updateChildValues(values) { error, ref in
            
            if error != nil {
                
                self.referralTextField.layer.borderColor = coreRedColor.cgColor
                self.activityIndicator.stopAnimating()
                self.handleCustomPopUpAlert(title: "ERROR", message: "Something wen't wrong. Please try again.", passedButtons: [Statics.OK])
                completion(false)
                return
                
            } else {
                self.observingRefTwo.removeObserver(withHandle: self.handleOne)
                completion(false)
                return
                
            }
        }
    }
    
    @objc func handleCustomPopUpAlert(title : String, message : String, passedButtons: [String]) {
        
        let alert = AlertController()
        alert.passedTitle = title
        alert.passedMmessage = message
        alert.passedButtonSelections = passedButtons
        alert.customAlertCallBackProtocol = self
        alert.passedIconName = .infoCircle
        alert.modalPresentationStyle = .overCurrentContext
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func onSelectionPassBack(buttonTitleForSwitchStatement type: String) {
        
        switch type {
        
        case Statics.GOT_IT: self.handleBackButton()
        case Statics.OK: print(Statics.OK)
        case Statics.SAVE: self.handleSubmitButton()
        case Statics.CANCEL: self.handleCodeRemoval()
            
        default: print("Should not hit")
            
        }
    }
    
    @objc func doubleCheck() {
        
        guard let code = self.referralTextField.text else {return}
        
        var containsNSFWText : Bool = false
        
        //MARK: - START LOOP
        for word in code.split(separator: " ") {
          
            if NSFWComparisonArray.contains(word.lowercased()) {
                containsNSFWText = true
            } else {
                containsNSFWText = false
            }
        }
        
        //MARK: - SAFE FROM NAUGHTY WORDS
        if containsNSFWText == false {
        
        //MARK: - NO INPUT
        if code.count <= 0 {
            self.referralTextField.layer.borderColor = coreRedColor.cgColor
            self.handleCustomPopUpAlert(title: "Empty", message: "Please enter a Referral Code of your choice. We recommend at least 10 characters long.", passedButtons: [Statics.OK])
        //MARK: - SHORT INPUT
        } else if code.count < 5 {
            self.referralTextField.layer.borderColor = coreRedColor.cgColor
            self.handleCustomPopUpAlert(title: "Empty", message: "Please make sure your Referral Code is at least 5 characters.", passedButtons: [Statics.OK])
        } else {
            self.handleCustomPopUpAlert(title: "Looks Good!", message: "Just so you know, this code can not be changed. Would you like to go with \(code)", passedButtons: [Statics.SAVE, Statics.CANCEL])
        }
            
        } else {
            self.handleCustomPopUpAlert(title: "Ruh roh! Some words aren’t allowed on Doggystyle", message: "Please enter another referral code, we aim to keep a friendly environment here at Doggystyle - for both humans and pups.", passedButtons: [Statics.OK])
        }
    }
    
    @objc func handleSubmitButton() {
        
        guard let user_uid = Auth.auth().currentUser?.uid else {return}
        
        if let text = self.referralTextField.text {
            
            if text.count <= 0 {
                self.referralTextField.layer.borderColor = coreRedColor.cgColor
                self.handleCustomPopUpAlert(title: "Empty", message: "Please enter a Referral Code of your choice. We recommend at least 10 characters long.", passedButtons: [Statics.OK])
            } else if text.count < 5 {
                self.referralTextField.layer.borderColor = coreRedColor.cgColor
                self.handleCustomPopUpAlert(title: "Empty", message: "Please make sure your Referral Code is at least 5 characters.", passedButtons: [Statics.OK])
            } else {
                
                self.referralTextField.layer.borderColor = coreOrangeColor.cgColor
                
                if self.codeState == .CustomCode {
                    
                    self.activityIndicator.startAnimating()
                    
                    self.fetchAndLoop(passedReferralCode: text) { isCodeTaken in
                        
                        if isCodeTaken == true {
                            
                            self.activityIndicator.stopAnimating()
                            self.referralTextField.layer.borderColor = coreRedColor.cgColor
                            self.handleCustomPopUpAlert(title: "Taken", message: "This referral code has already been used. Please select another one.", passedButtons: [Statics.OK])
                            
                        } else {
                            
                            self.completeAndFinalizeCode(referralCode: text, user_uid: user_uid) { completion in
                                self.nextRoute(passedReferralCode: text)
                            }
                        }
                    }
                    
                } else if codeState == .RandomlyGenerated {
                    self.nextRoute(passedReferralCode: text)
                }
            }
            
        } else {
            self.referralTextField.layer.borderColor = coreRedColor.cgColor
            self.handleCustomPopUpAlert(title: "Empty", message: "Please enter in an awesome referral code!", passedButtons: [Statics.OK])
        }
    }
    
    func nextRoute(passedReferralCode : String) {
        
        //MARK: - UPDATE THE REFERRAL CODE HERE
        userProfileStruct.user_created_referral_code_grab = passedReferralCode
        
        let referralMonetaryController = ReferralMonetaryController()
        referralMonetaryController.modalPresentationStyle = .fullScreen
        referralMonetaryController.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.pushViewController(referralMonetaryController, animated: true)
        
    }
}

