//
//  JoinYourMembershipVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/03.
//

import Foundation
import UIKit
import Alamofire

class JoinYourMembershipVC: UIViewController{
    
    // MARK: 변수 or 정상수
    var memNickname = ""
    var memGender = ""
    var memAge = ""
    var nickName = ""
    var birthDay = ""
    var email = ""
    var myPopUpDelegate: PopUpDelegate?
    
    var imageData = Data()
    let picker = UIImagePickerController()
    let gradient: CAGradientLayer = CAGradientLayer()
    let datePiker = UIDatePicker()
    
    // MARK: @IBOutlet 정상수
    @IBOutlet weak var constCountLabel: UILabel!
    @IBOutlet weak var userConstsTV: UITextView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var joinMemberBtn: UIButton!
    @IBOutlet weak var bottomLine: NSLayoutConstraint!
    @IBOutlet weak var insertImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        userConstsTV.delegate = self
        picker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: @IBAction Function
    @IBAction func whatIsYourSex(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            manButton.backgroundColor = UIColor(red: 241, green: 249, blue: 255)
            manButton.borderColor = UIColor(red: 118, green: 159, blue: 200)
            clearButton(button: womanButton)
            memGender = "m"
            
        case 2:
            womanButton.backgroundColor = UIColor(red: 255, green: 230, blue: 240)
            womanButton.borderColor = UIColor(red: 255, green: 152, blue: 193)
            clearButton(button: manButton)
            memGender = "f"
            
        default:
            print("")
        }
        conditionCheck()
    }
    
    @IBAction func registerImage(_ sender: UIButton) {
        presentActionSheet()
    }
    @IBAction func dismissBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tabBackground(_ sender: Any) {
        userConstsTV.resignFirstResponder()
        nicknameTextField.resignFirstResponder()
        conditionCheck()
    }
    @IBAction func sendMembership(_ sender: UIButton) {
        if gradient.isHidden == false {
            multiAF()
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: normal Function
    func clearButton(button: UIButton) {
        button.borderColor = UIColor(red: 223, green: 223, blue: 223)
        button.backgroundColor = .white
    }
    
    func setConfig() {
        let img = UIImage(named: "send_story_dismiss")
        addRightImage(textField: yearTextField, image: img!)
        addRightImage(textField: monthTextField, image: img!)
        addRightImage(textField: dayTextField, image: img!)
        
        gradient.frame = self.joinMemberBtn.bounds
        gradient.colors = [
            UIColor(red: 133, green: 129, blue: 255).cgColor,
            UIColor(red: 152, green: 107, blue: 255).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0,1]
        joinMemberBtn.layer.masksToBounds = true
        joinMemberBtn.layer.insertSublayer(gradient, at: 0)
        gradient.isHidden = true
    }
    
    func addRightImage(textField: UITextField, image: UIImage){
        let rightImgView = UIImageView(frame: CGRect(x: 12, y: 0, width: 20, height: 20))
        rightImgView.image = image
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        if #available(iOS 13.4, *) {
            datePiker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePiker.locale = Locale(identifier: "ko-KR")
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        textField.textAlignment = .left
        textField.rightView = rightImgView
        textField.rightViewMode = .always
        textField.inputAccessoryView = toolbar
        datePiker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
        datePiker.maximumDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
        
        textField.inputView = datePiker
        datePiker.datePickerMode = .date
    }
    
    func iWantNumber(comeOnNumber: String) -> String{
        let endIndex: String.Index = comeOnNumber.index(comeOnNumber.startIndex, offsetBy: 1)
        let result = String(comeOnNumber[...endIndex])
        let yourAge = "\(Int(result) ?? 0)"
        
        return yourAge
    }
    
    func presentActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelSheet = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let choicePhotoSheet = UIAlertAction(title: "사진에서 가져오기", style: .default) { [weak self] action in
            self?.openLibrary()
        }
        let openCameraAction = UIAlertAction(title: "카메라 열기", style: .default) { [weak self] action in
            self?.openCamera()
        }
        
        actionSheet.addAction(openCameraAction)
        actionSheet.addAction(choicePhotoSheet)
        actionSheet.addAction(cancelSheet)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func openLibrary(){
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
        } else {
            print("시뮬레이터 입니다.")
        }
    }
    
    func multiAF() {
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { [weak self] multipartFormData in
            
            multipartFormData.append("\(self?.nicknameTextField.text ?? "")".data(using: .utf8) ?? Data(), withName: "name")
            multipartFormData.append("\(self?.memGender ?? "")".data(using: .utf8) ?? Data(), withName: "gender")
            multipartFormData.append("\(self?.memAge ?? "")".data(using: .utf8) ?? Data(), withName: "age")
            multipartFormData.append("\(self?.email ?? "" )".data(using: .utf8) ?? Data(), withName: "email")
            multipartFormData.append("\(self?.userConstsTV.text ?? "")".data(using: .utf8) ?? Data(), withName: "costs")
            multipartFormData.append(self?.imageData ?? Data(), withName: "profile_img", fileName: "name.png", mimeType: "image/jpeg")
        }, to: "http://babyhoney.kr/api/member",
                  headers: headers).responseJSON(completionHandler: { data in
            switch data.result{
            case .success(let jsonData):
                self.myPopUpDelegate?.onJoinMembershipClicked(email: self.email)
                guard let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted) else { return }
                do {
                    let result = try JSONDecoder().decode(MembershipModel.self, from: data)
                    print(result)
                } catch {
                    print(data.description)
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    func conditionCheck(){
        if nicknameTextField.text?.count ?? 0 > 1 && memGender.isEmpty != true && birthDay.isEmpty != true && userConstsTV.text.lengthOfBytes(using: .utf8) > 10 {
            gradient.isHidden = false
        } else {
            gradient.isHidden = true
        }
    }
    
    deinit {
        print("JoinYourMembershipVC deinit")
    }
}

// MARK: Extension TextViewDelegate
extension JoinYourMembershipVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let trimCurrentText = self.userConstsTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimedCurrentText = trimCurrentText.lengthOfBytes(using: String.Encoding.utf8)
        self.constCountLabel.text = "\(trimedCurrentText)/200"
        
        let attributedCount = NSMutableAttributedString(string: constCountLabel.text!)
        attributedCount.addAttribute(.foregroundColor, value: UIColor.black, range: (constCountLabel.text! as NSString).range(of: "\(trimedCurrentText)"))
        
        self.constCountLabel.attributedText = attributedCount
        conditionCheck()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if !(changedText.lengthOfBytes(using: String.Encoding.utf8) <= 200) {
            print("200자 넘음") }
        return changedText.lengthOfBytes(using: String.Encoding.utf8) <= 200
    }
    
}

// MARK: Extension UITextFieldDelegate
extension JoinYourMembershipVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        conditionCheck()
    }
}

// MARK: Extension UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension JoinYourMembershipVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        //        let imageThumbnail = image.preparingThumbnail(of: CGSize(width: self.insertImage.bounds.width, height: self.insertImage.bounds.height))
        let setting = image.setImgSize(newWidth: self.insertImage.frame.width)
        
        self.imageData = image.pngData() ?? Data()
        
        self.insertImage.setTitle("", for: .normal)
        self.insertImage.contentMode = .scaleAspectFill
        
        self.insertImage.layer.masksToBounds = true
        self.insertImage.setImage(setting, for: .normal)
        print(info)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: @objc Function
extension JoinYourMembershipVC{
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko-KR")
        
        let formatteredDate = formatter.string(from: datePiker.date)
        let componentsDate = formatteredDate.components(separatedBy: ["."])
        self.birthDay = formatteredDate
        
        if #available(iOS 13.0, *) {
            self.memAge = iWantNumber(comeOnNumber: formatteredDate.stringTodateAge.koreanAge)
        } else {
            // Fallback on earlier versions
        }
        
        print(self.memAge)
        yearTextField.text = componentsDate[0]
        monthTextField.text = componentsDate[1]
        dayTextField.text = componentsDate[2]
        conditionCheck()
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if self.view.frame.origin.y == 0 && userConstsTV.isFirstResponder == true{
                let keybaordRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keybaordRectangle.height
                self.view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if self.view.frame.origin.y != 0{
                let keybaordRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keybaordRectangle.height
                self.view.frame.origin.y += keyboardHeight
            }
        }
    }
}
