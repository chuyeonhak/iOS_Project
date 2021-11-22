//
//  KakaoNaver.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/04.
//

import UIKit
import WebKit
import XHQWebViewJavascriptBridge
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon
import NaverThirdPartyLogin
import Alamofire


class KakaoNaverVC: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var moreInfoBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var enterLiveBtn: UIButton!
    
    
    // MARK: 상수, 변수 선언부
    var urlString: String = API.JOIN_URL
    var webViewFlag = false
    var joinMember = [MemInfo]()
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    lazy var bridge = WKWebViewJavascriptBridge.bridge(forWebView: webView)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("KakaoNaverVC viewDidLoad")
        loginInstance?.delegate = self
        webViewLoad(place: urlString)
        bridgeCall()
        buttonSetting(onOff: true)
    }
    
    //MARK: @IBAction Functions
    @IBAction func moreActionBtn(_ sender: UIButton) {
        createActionSheet()
    }
    
    @IBAction func homeBtn(_ sender: UIButton) {
        let url = URL(string: API.JOIN_URL)!
        self.webView.load(URLRequest(url: url))
        webViewFlag = false
    }

    @IBAction func enterLiveClicked(_ sender: UIButton) {
        print("라이브 입장띠")
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.reqRoomEnter(mem_id: joinMember.first?.email ?? "", chat_name: joinMember.first?.name ?? "", mem_photo: joinMember.first?.profileImage ?? "")
        guard let liveVC = UIStoryboard(name: "Live", bundle: nil).instantiateViewController(withIdentifier: "LiveVC") as? LiveVC else { return }
        self.modalPresentationStyle = .overFullScreen
        self.present(liveVC, animated: true, completion: nil)
    }
    
    //MARK: Normal Functions
    func webViewLoad(place : String) {
        self.loginInstance?.requestDeleteToken()
        let url = URL(string: place)!
        self.webView.load(URLRequest(url: url))
        self.view.addSubview(webView)
    }
    
    func buttonSetting(onOff: Bool) {
        moreInfoBtn.isHidden = onOff
        backBtn.isHidden = onOff
        enterLiveBtn.layer.zPosition = 5
        view.bringSubviewToFront(enterLiveBtn)
        enterLiveBtn.isHidden = onOff
    }
    
    func bridgeCall() {
        bridge.registerHandler(handlerName: "$.callFromWeb", handler: { [weak self] (data, responseCallback) in
            let jsonData = data as? [String: String]
            print(jsonData ?? "")
            
            switch jsonData{
            case ["cmd": "loginKakao"]:
                UserApi.shared.loginWithKakaoAccount {[weak self] (oauthToken, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("loginWithKakaoAccount() success.")
                        self?.kakaoEmail()
                        _ = oauthToken
                    }
                }
            case ["cmd": "loginNaver"]:
                self?.loginInstance?.requestThirdPartyLogin()
            default:
                print("default")
                guard let memEmail = jsonData?["userInfo"] else { return }
                print(memEmail)
                self?.checkYourEmail(email: memEmail)
            }
        })
    }
    
    func getInfo() {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken {
            return
        }
        
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
        
        let authorization = "\(tokenType) \(accessToken)"
        
        let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
        
        req.responseJSON { [weak self]response in
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
            //            guard let name = object["name"] as? String else { return }
            guard let email = object["email"] as? String else { return }
            //            guard let id = object["id"] as? String else {return}
            print(email)
            self?.checkYourEmail(email: email)
            
            self?.loginInstance?.requestDeleteToken()
            
        }
    }
    
    func kakaoEmail() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print(user?.kakaoAccount?.email ?? "")
                self.checkYourEmail(email: user?.kakaoAccount?.email ?? "")
                //do something
                _ = user
            }
        }
    }
    
    func checkYourEmail(email: String) {
        let url = URL(string: "http://babyhoney.kr/api/member/\(email)")!   //url을 지정해주었습니다.
        
        let decoder = JSONDecoder()
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{ //반응이 성공하면 성공케이스를 실행하고 실패하면 실패케이스를 실행합니다.
                case .success (let jsonValue):
                    guard let data = try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted) else { return }
                    do {
                        let result = try decoder.decode(MembershipEmail.self, from: data)
                        if result.isMember == false {
                            guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinYourMembershipVC") as? JoinYourMembershipVC else { return }
                            viewController.email = email
                            viewController.myPopUpDelegate = self
                            print(email)
                            viewController.modalPresentationStyle = .overFullScreen
                            self.present(viewController, animated: true, completion: nil)
                        } else {
                            let result = try decoder.decode(MembershipModel.self, from: data)
                            self.joinMember = [result.memInfo]
                            let redirectUrl = result.redirectURL
                            print(redirectUrl)
                            
                            if self.webViewFlag == false {
                                self.urlString = "http://babyhoney.kr\(redirectUrl)/\(email)"
                                self.webViewLoad(place: self.urlString)
                                self.buttonSetting(onOff: false)
                                self.webViewFlag = true
                            } else {
                                guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "halfView") as? HalfVC else { return }
                                viewController.memSex = result.memInfo.gender ?? "F"
                                viewController.openProfile = [result.memInfo]
                                viewController.modalPresentationStyle = .overFullScreen
                                self.present(viewController, animated: true, completion: nil)
                            }
                            
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                case .failure:
                    print(MyError.noContent)
                }
            }
    }
    
    func membershipWithdrawal(email: String) {
        let decoder = JSONDecoder()
        let url = URL(string: "http://babyhoney.kr/api/member/\(email)")!
        AF.request(url, method: .delete).responseJSON { response in
            switch response.result {
            case .success(let jsonValue):
                guard let data = try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted) else { return }
                
                do {
                    let result = try decoder.decode(MembershipWithdrawal.self, from: data)
                    print(result.msg)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: actionSheet and createAlert Functions
    func createActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelSheet = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let membershipWithdrawal = UIAlertAction(title: "회원 탈퇴하기", style: .default) { [weak self] action in
            self?.createAlert()
        }
        let updateMemberInfo = UIAlertAction(title: "회원정보 수정하기", style: .default) { action in
        }
        
        actionSheet.addAction(updateMemberInfo)
        actionSheet.addAction(membershipWithdrawal)
        actionSheet.addAction(cancelSheet)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "회원탈퇴", message: nil, preferredStyle: .alert)
        alert.addTextField { myTextField in
            myTextField.placeholder = "이메일을 입력해주세요."
        }
        let ok = UIAlertAction(title: "OK", style: .default) {  [weak self] _ in
            guard let email = alert.textFields?[0].text else { return }
            self?.membershipWithdrawal(email: email)
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    deinit {
        print("KakaoNaverVC deinit")
    }
}

    //MARK: NaverThirdPartyLoginConnectionDelegate
extension KakaoNaverVC: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        getInfo()
    }
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        _ = loginInstance?.accessToken
    }
    func oauth20ConnectionDidFinishDeleteToken() {
        print("log out")
    }
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("error = \(error.localizedDescription)")
    }
}

    //MARK: PopUpDelegate
extension KakaoNaverVC: PopUpDelegate {
    func onJoinMembershipClicked(email: String) {
        let url = "http://babyhoney.kr/member/list/\(email)"
        
        self.webViewLoad(place: url)
        self.webViewFlag = true
        buttonSetting(onOff: false)
    }
}
