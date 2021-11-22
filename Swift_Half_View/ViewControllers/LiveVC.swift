//
//  Live.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/11.
//

import Foundation
import UIKit
import SocketIO
import SwiftyJSON
import Kingfisher
import Alamofire
import Lottie

class LiveVC: UIViewController {
    
    /* MARK: IBOutlet 선언부
     제약조건을 코딩으로 지정할 것 이 있어서 선언하였습니다.
     */
    @IBOutlet weak var tableSuperView: UIView!
    @IBOutlet weak var goToButtom: UIButton!
    @IBOutlet weak var sendChatTV: UITextView!
    @IBOutlet weak var heartOnOffBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var bottomLine: NSLayoutConstraint!
    
    /* MARK: 상수, 변수 선언부
     전역 상수와 전역 변수에 담아서 사용하려고 선언해주었습니다.
     소켓 연결에 필요한 것과, 멤버정보를 받으려고 구조체를 초기화 해주었습니다.
     타이머를 사용하기 위해서 타이머 변수를 선언하고 타이머의 초를 0 으로 초기화했습니다.
     좋아요 애니메이션을 전역상수로 선언해 on / off를 어디서든 할 수 있게 해주었습니다.
     플레이스홀더를 선언해주고 마지막으로 JSON디코더를 선언해주었습니다.
     */
    
    var socket: SocketIOManager!
    var getSocket = SocketIOManager.shared.getSocket()
    var memInfo = [LiveModel]()
    var timer: Timer?
    var timerNum: Int = 0
    let heartAnimation = AnimationView(name: "Hearts")
    let placeHolder = "대화를 입력하세요"
    let decoder = JSONDecoder()
    
    /* MARK: ViewDidLoad 선언부
     뷰가 로드가 될때 어떤 함수를 부를 것인지 선언해주었습니다.
     소켓과, 배경, 블러뷰 함수를 실행하고
     테이블 뷰의 델리게이트와 데이터소스와 텍스트뷰의 델리게이트를 사용한다고 선언하였습니다.
     그 후에는 커스텀 셀을 등록하고 노티피케이션에 등록된 것들을 바라보게 해주었습니다.
     Objective - C 함수인 adjustInputView라는 함수를 실행합니다.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        settingSocket()
        setBackground()
        setBlurView()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        sendChatTV.delegate = self
        
        let myTableViewCellNib = UINib(nibName: String(describing: SystemTableViewCell.self), bundle: nil)
        self.chatTableView.register(myTableViewCellNib, forCellReuseIdentifier: "SystemTableViewCell")
        
        let myTableViewCellSystem = UINib(nibName: String(describing: UserTableViewCell.self), bundle: nil)
        self.chatTableView.register(myTableViewCellSystem, forCellReuseIdentifier: "UserTableViewCell")

        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.chatTableView.estimatedRowHeight = 120
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    /* MARK: IBAction tabBG() onOffBtnClicked()
     tabBG : 백그라운드를 탭하면 텍스트뷰에 first로 된 것을 포기한다고 해주었습니다.
     onOffBtnClicked : 이 버튼을 누르면 이미지가 off로 바뀌면서 애니메이션을 정지되고 sendLike함수를 실행하고 버튼이 비활성화되게 만들었습니다.
     그리고 로티애니메이션을 추가하고 타이머 60초가 돌아가고 timerCallback함수를 실행합니다.
    
     */
    @IBAction func tabBG(_ sender: UITapGestureRecognizer) {
        sendChatTV.resignFirstResponder()
    }
    
    @IBAction func onOffBtnClicked(_ sender: UIButton) {
        heartOnOffBtn.setImage(UIImage(named: "btn_heart_off"), for: .normal)
        SocketIOManager.shared.sendLike()
        heartAnimation.stop()
        heartOnOffBtn.isUserInteractionEnabled = false
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        timerNum = 59
    }
    
    /* MARK: IBAction closeBtnClicked(), sendBtnClick(), goToButton()
     클로즈 버튼을 누르면 소켓 연결을 종료시키고 노티피케이션을 해제하고 창이 닫히도록 하였습니다.
     전송 버튼을 누르면 제가 만든 메세지가 앞 뒤 공백을 제거하고 전송 후 텍스트뷰를 공백으로 만들었습니다.
     아래로 가는 버튼을 누르면 컨텐트 옵셋을 최상위로 올려주었습니다.
     */
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        SocketIOManager.shared.closeConnection()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        heartAnimation.removeFromSuperview()
        self.dismiss(animated: true)
    }
    
    @IBAction func sendBtnClick(_ sender: UIButton) {
        let msg = self.sendChatTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if msg.count > 2 {
            SocketIOManager.shared.sendMessage(msg: msg)
            sendChatTV.text = ""
            textViewDidChange(sendChatTV)
        } else {
            createToast(msg: "너무 적게 씀 ㅇㅈ?")
        }
    }
    
    @IBAction func goToButton(_ sender: UIButton) {
        chatTableView.setContentOffset(.zero, animated: true)
    }
    
    /* MARK: settingSocket() 선언부
     소켓 설정 함수로 "message"로 이벤트를 잡아서 json으로 디코딩하고 cmd를 판별하여
     어떤 행동을 해줘야할 것인지 설정해주었습니다. 좋아요를 누르면 7개의 하트가 생성됩니다.
     인덱스 0번에 계속 넣어서 배열을 반대로 해주었습니다. 다른 메세지가 오면 최하단으로 이동합니다.
     */
    func settingSocket() {
        getSocket.on(EVENT.MESSAGE) { [weak self] dataArray, ack in
            guard let data = try? JSONSerialization.data(withJSONObject: dataArray[0], options: .prettyPrinted) else { return }
            
            guard let result = try? self?.decoder.decode(LiveModel.self, from: data) else { return }
            print(result)
            let cmd = result.cmd
            
            switch cmd {
            case "rcvPlayLikeAni":
                for _ in 0...6 {
                    self?.createHeartAnimation()
                }
            case "rcvChatMsg", "rcvSystemMsg":
                self?.memInfo.insert(result, at: 0)
                self?.chatTableView.setContentOffset(.zero, animated: true)
                self?.chatTableView.reloadData()
            case "rcvAlertMsg":
                self?.createAlert(msg: "\(result.msg ?? "")")
            case "rcvToastMsg":
                self?.createToast(msg: "\(result.msg ?? "")")
            case "rcvRoomOut":
                self?.createAlert(msg: "채팅방에서 나가세요!!!")
            default:
                print("default")
            }
        }
    }
    /* MARK: setBackground(), setBlurView() 선언부
     뷰에 백그라운드 사진을 넣어주고 텍스트뷰의 최대 라인을 5줄로 제약해주었습니다.
     초기 실행시 텍스트뷰의 텍스트는 플레이스홀더로 해놨고 컬러를 lightGray로 해주었습니다.
     아래에서 위로 깔리는 형태를 만들기 위해서 테이블을 반대로 뒤집었습니다.
     초기 실행시 좋아요 버튼이 활성화되어 있기 때문에 바로 로티애니메이션을 실행하였습니다.
     블러뷰의 레이어 마스크에 그라데이션을 넣어주어서 최상단에서 블러 기능을 구현하였습니다.
     */
    
    func setBackground() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background.png")?.draw(in: self.view.bounds)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        sendChatTV.textContainer.maximumNumberOfLines = 5
        sendChatTV.text = placeHolder
        sendChatTV.textColor = UIColor(red: 203, green: 203, blue: 203)
        sendChatTV.backgroundColor = .white
        chatTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        createHeartLottie()
    }
    
    func setBlurView() {
        let gradient = CAGradientLayer()
        gradient.frame = self.tableSuperView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 0.1, 1]
        tableSuperView.layer.mask = gradient
        
        tableSuperView.backgroundColor = .clear
    }
    
    /* MARK: getYourInfo() 선언부
     Alamofire로 상대의 정보를 받아서 HalfViewController에 정보를 뿌려주었습니다.
     */
    func getYourInfo(email: String) {
        let url = URL(string: "http://babyhoney.kr/api/member/\(email)")!
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success (let jsonValue):
                    guard let data = try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted) else { return }
                    do {
                        let result = try self.decoder.decode(MembershipModel.self, from: data)
                        print(result)
                        
                        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "halfView") as? HalfVC else { return }
                        viewController.memSex = result.memInfo.gender ?? "F"
                        viewController.openProfile = [result.memInfo]
                        viewController.modalPresentationStyle = .overFullScreen
                        self.present(viewController, animated: true, completion: nil)
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                case .failure:
                    print(MyError.noContent)
                }
            }
    }
    
    /* MARK: createHeartAnimation() 선언부
     제가 필요한 랜덤 값을 저장해주는 상수가 있어서 정책에 맞게 표현해주었습니다.
     */
    func createHeartAnimation(){
        let startTime = Double.random(in: 5.5...6)
        let xStartRandom = Double.random(in: 0...60)
        let yStartRandom = self.view.bounds.size.height - Double.random(in: 0...80)
        let randomSize = Double.random(in: 20...30)
        
        let heartImg = UIImageView(frame: CGRect(x: xStartRandom , y: yStartRandom, width: 50, height: 50))
        heartImg.image = UIImage(named: RANDOM.HEARTNAME.randomElement() ?? "")
        self.view.addSubview(heartImg)
        UIImageView.animateKeyframes(withDuration: startTime, delay: 0, options: .calculationModePaced, animations: {
            heartImg.alpha = 0
            UIImageView.addKeyframe(withRelativeStartTime: 0, relativeDuration: startTime * 0.15 , animations: {
                heartImg.alpha = 1
                heartImg.frame = CGRect(x: xStartRandom + Double.random(in: -75...75), y: yStartRandom - Double.random(in: 100...150), width: 50, height: 50)})
            
            UIImageView.addKeyframe(withRelativeStartTime: startTime * 0.15, relativeDuration: startTime * 0.55, animations: {
                heartImg.alpha = 1
                heartImg.frame = CGRect(x: xStartRandom + Double.random(in: -75...75), y: yStartRandom - Double.random(in: 100...150) - 150, width: 50 + randomSize, height: 50 + randomSize)})
            
            UIImageView.addKeyframe(withRelativeStartTime: startTime * 0.7, relativeDuration: startTime * 0.3, animations: {
                heartImg.alpha = 0
                heartImg.frame = CGRect(x: xStartRandom + Double.random(in: -75...75), y: Double.random(in: 0...80), width: 70 + randomSize, height: 70 + randomSize)
            })
        })
    }
    /* MARK: createHeartLottie() 선언부
     로티를 버튼 위에다가 활성화 시키고 버튼이 활성화 상황에서는 애니메이션을 플레이하고
     addSubView가 버튼을 가리기 때문에 UserInteractionEnabled를 false로 해주어서 뷰를 무시할 수 있습니다.
     */
    func createHeartLottie(){
        self.view.addSubview(heartAnimation)
        heartAnimation.loopMode = .loop
        heartAnimation.translatesAutoresizingMaskIntoConstraints = false
        heartAnimation.centerXAnchor.constraint(equalTo: heartOnOffBtn.centerXAnchor).isActive = true
        heartAnimation.centerYAnchor.constraint(equalTo: heartOnOffBtn.centerYAnchor).isActive = true
        heartAnimation.heightAnchor.constraint(equalToConstant: 36).isActive = true
        heartAnimation.widthAnchor.constraint(equalToConstant: 36).isActive = true
        heartAnimation.contentMode = .scaleAspectFit
        heartAnimation.play()
        heartAnimation.isUserInteractionEnabled = false
    }
    
    /* MARK: createAlert(), createToast() 선언부
     알럿 메세지와 토스트 메세지 선언부입니다.
     */
    func createAlert(msg: String) {
        let alert = UIAlertController(title: nil, message: "\(msg)", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default)
        let cancel = UIAlertAction(title: "cancel", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createToast(msg: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height - 100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = msg
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.bringSubviewToFront(toastLabel)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0 }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
    }
    
    deinit {
        print("LiveVC deinit")
    }
}

    /* MARK: UITextViewDelegate 선언부
     유저가 엔터를 누를 것 카운트해서 제약해주고 100자를 넘지 못하게 구현해주었습니다.
     공백만 보낼때 카운트가 0으로 잡히므로 1글자 이하일 경우 버튼이 비활성화를 만들어 주었습니다.
     텍스트뷰의 컨스트레인트를 estimatedSize의 높이를 각각 다 잡아주었습니다.
     */
extension LiveVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        if(text == "\n") {
            return linesAfterChange <= textView.textContainer.maximumNumberOfLines
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 100
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let trimCurrentText = self.sendChatTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimCurrentText.count < 2 {
            sendBtn.isEnabled = false
        } else {
            sendBtn.isEnabled = true
        }
        textView.isScrollEnabled = false
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height{
                constraint.constant = estimatedSize.height
            }
        }
    }
    /* MARK: UITextViewDelegate 선언부
     텍스트가 시작되었을때 플레이스홀더라면 공백으로 바꿔주고 텍스트컬러를 검정색으로 바꿔주었습니다.
     텍스트가 공백이라면 플레이스 홀더로 대체하고 컬러 색상도 lightGray로 바꿔주었습니다.
     */
    func textViewDidBeginEditing(_ textView: UITextView) {
        if sendChatTV.text == placeHolder {
            sendChatTV.text = ""
            sendChatTV.textColor = .black
        }
    }
    
    // 스토리뷰가 비어있으면 플레이스 홀더로 대체하기
    func textViewDidEndEditing(_ textView: UITextView) {
        if sendChatTV.text == "" {
            sendChatTV.text = placeHolder
            sendChatTV.textColor = UIColor(red: 203, green: 203, blue: 203)
        }
    }
}
//MARK: UITableViewDelegate
extension LiveVC: UITableViewDelegate {
    
}

    /* MARK: UITableViewDataSource 선언부
     멤버인포의 숫자를 셀의 섹션개수로 정하고 멤버인포의 커맨드에 따라서 어떤 셀로 구성할지 정해놓고 테이블을 뒤집었기 때문에 셀도 같이 뒤집어 주었습니다.
     셀의 백그라운드를 투명으로 하기 위해서 셀이 보여지기 전에 지정을 해줬습니다.
     */
extension LiveVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let systemCell = tableView.dequeueReusableCell(withIdentifier: "SystemTableViewCell") as? SystemTableViewCell else { return UITableViewCell()}
        if memInfo[indexPath.row].cmd == "rcvSystemMsg" {
            
            systemCell.systemAlertLabel.text = "\(memInfo[indexPath.row].msg ?? "채팅방에 입장하셨습니다.")"
            systemCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return systemCell
        } else {
            guard let userCell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell else { return UITableViewCell()}
            userCell.thumbnailBtn.tag = indexPath.row
            userCell.thumbnailBtn.addTarget(self, action: #selector(presentMiniProfile(sender:)), for: .touchUpInside) //버튼에 액션을 추가하였습니다.
            
            userCell.nameLabel.text = memInfo[indexPath.row].from?.chatName
            userCell.chatLabel.text = memInfo[indexPath.row].msg
            userCell.profilePhoto.contentMode = .scaleAspectFill
            userCell.profilePhoto.cornerRadius = userCell.profilePhoto.frame.width / 2
            userCell.profilePhoto.setImage(imageUrl: memInfo[indexPath.row].from?.memPhoto ?? "https://pida83.gabia.io/storage/i1ptqSvJMahIJHk04Izulg7vNNdrVcoeMqNJZomK.png")
            userCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return userCell
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
}
    /* MARK: UIScrollViewDelegate 선언부
     scrollView를 스크롤하는 중에 스크롤 뷰의 offset.y가 0보다 크다면 아래로 버튼을 보이게 해주었고 아닐 경우 버튼을 숨겼습니다.
     */
extension LiveVC: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        scrollOffset > 0 ? (goToButtom.isHidden = false) : (goToButtom.isHidden = true)
    }
}
    /* MARK: objc 선언부
     notification 센터에 키보드가 올라올 때, 없어질 때 바텀 제약조건을 조정하고 자연스럽게 하기 위해 애니메이션을 추가하였습니다.
     타이머를 올려서 0초가 되었을 때 다시 버튼을 활성화 시키게 해주고
     썸네일을 클릭하면 저장되어 있던 email을 받아서 API로 데이터를 받고 ViewController에 정보를 뿌려주는 것을 구현하였습니다.
     */
extension LiveVC {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // TODO: 키보드 높이에 따른 인풋뷰 위치 변경 Ok
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - self.view.safeAreaInsets.bottom
            // 필요한 만큼 올린다.
            let notchSize = abs(0 - self.view.safeAreaInsets.bottom)
            bottomLine.constant = adjustmentHeight
            self.sendBtn.isHidden = false
            if UIDevice.current.hasNotch {
                bottomLine.constant = adjustmentHeight + notchSize + 15
            }
        } else {
            bottomLine.constant = 15
            self.sendBtn.isHidden = true
        }
        let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
    
    @objc func timerCallback() {
        if timerNum == 0 {
            self.heartOnOffBtn.isUserInteractionEnabled = true
            heartOnOffBtn.setImage(UIImage(named: "btn_heart_on"), for: .normal)
            heartAnimation.play()
            timer?.invalidate()
            timer = nil
        }
        timerNum -= 1
    }
    
    @objc func presentMiniProfile(sender: UIButton) {
        guard let email = memInfo[sender.tag].from?.memID else { return }
        getYourInfo(email: email)
    }
}
