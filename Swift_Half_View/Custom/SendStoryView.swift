//
//  SendStory.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftUI
class SendStoryView: UIView, UITextViewDelegate{
    
    @IBOutlet weak var bottomLine: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var limitTextLabel: UILabel!
    @IBOutlet weak var storyView: UITextView!
    let maxText: Int = 300
    var currentText: Int = 0
    let placeHolder: String = "10자 이상 300자 이하로 입력해주세요."
    var sendCont: String = ""

    let gradient: CAGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        storyView.delegate = self
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("SendStoryView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        storyView.text = placeHolder
        storyView.textColor = .lightGray
        sendBtn.isEnabled = false
        if sendBtn.isEnabled == false {
            sendBtn.backgroundColor = UIColor(red: 204, green: 204, blue: 204)
            sendBtn.titleLabel?.textColor = .white
        }
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        gradientSublayer()
    }
    
    func gradientSublayer() {
        gradient.frame = sendBtn.bounds
        gradient.colors = [
                   UIColor(red: 133, green: 129, blue: 255).cgColor,
                   UIColor(red: 152, green: 107, blue: 255).cgColor
               ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0,1]
        sendBtn.layer.cornerRadius = 19
        sendBtn.layer.masksToBounds = true
        sendBtn.layer.insertSublayer(gradient, at: 0)
        gradient.isHidden = true
    }
    //MARK: ButtonAction
    @IBAction func closeViewBtn(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func sendStoryBtn(_ sender: UIButton) {
        storyView.resignFirstResponder()
        self.frame.origin.y = 0
        sendCont = "\(storyView.text!)"
        sendRequest()
        showToast(message: MyAlert.sendStorySuccess.rawValue)
    }
    
    @IBAction func tabBackground(_ sender: Any) {
        storyView.resignFirstResponder()
        self.frame.origin.y = 0
    }
    
    //MARK: textViewAction
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if !(changedText.lengthOfBytes(using: String.Encoding.utf8) <= maxText) {
            showToast(message: MyError.textIsfull.rawValue) }
        return changedText.lengthOfBytes(using: String.Encoding.utf8) <= maxText
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let trimCurrentText = self.storyView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimedCurrentText = trimCurrentText.lengthOfBytes(using: String.Encoding.utf8)
        
        self.limitTextLabel.text = "(\(trimedCurrentText)/\(maxText))"
        
        if trimedCurrentText >= 10 {
            sendBtn.isEnabled = true
            gradient.isHidden = false
        } else {
            sendBtn.isEnabled = false
            gradient.isHidden = true
        }
        
    }

    // 텍스트를 쓰기 시작할 때 텍스트뷰가 플레이스 홀더면 다 지우고 색 바꿔주기
    func textViewDidBeginEditing(_ textView: UITextView) {
        if storyView.text == placeHolder {
            storyView.text = ""
            storyView.textColor = .black
        }
    }
    
    // 스토리뷰가 비어있으면 플레이스 홀더로 대체하기
    func textViewDidEndEditing(_ textView: UITextView) {
        if storyView.text.isEmpty {
            storyView.text = placeHolder
            storyView.textColor = .lightGray
        }
    }
    
    func sendRequest() {
        let parameter = [  //파라미터에 값을 넣어주었습니다.
            "send_mem_gender":"\(String(describing: RANDOM.GENDER.randomElement() ?? ""))",
            "send_mem_no":"9505",
            "send_chat_name":"추추추추",
            "send_mem_photo":"\(String(describing: RANDOM.PHOTO.randomElement() ?? "F"))",
            "story_conts":"\(sendCont)",
            "bj_id":"chuchu"
        ]
        let url = URL(string: "http://babyhoney.kr/api/story")!   //url을 지정해주었습니다.
        
        AF.request(url,
                   method: .post,
                   parameters: parameter,
                   encoder: JSONParameterEncoder.default)
            .responseJSON { response in
                switch response.result{ //반응이 성공하면 성공케이스를 실행하고 실패하면 실패케이스를 실행합니다.
                case .success:
                    self.showToast(message: MyAlert.sendStorySuccess.rawValue)
                case .failure:
                    print(MyError.noContent)
                }
            }
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.frame.size.width/2 - 75, y: self.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.bringSubviewToFront(toastLabel)
        self.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0 }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
    }
}

//MARK: 키보드 노티 등록하는거 구현
extension SendStoryView{
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // TODO: 키보드 높이에 따른 인풋뷰 위치 변경 Ok
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - self.safeAreaInsets.bottom
            // 필요한 만큼 올린다.
            let notchSize = abs(0 - self.safeAreaInsets.bottom)
            bottomLine.constant = adjustmentHeight
            if UIDevice.current.hasNotch {
                
                bottomLine.constant = adjustmentHeight + notchSize
            }
        } else {
            bottomLine.constant = 0
        }
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.layoutIfNeeded() },
            completion: nil)
    }
}
