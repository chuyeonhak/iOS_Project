//
//  halfVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/07.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON
import WebKit

class HalfVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var sendStoryView: SendStoryView!
    

    @IBOutlet weak var totalPhotoCount: UILabel!
    @IBOutlet weak var memSexAge: UIView!
    @IBOutlet weak var iconMemSex: UIImageView!
    @IBOutlet weak var memSexImage: UIImageView!
    @IBOutlet weak var halfView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var PhotoListCollection: UICollectionView!
    @IBOutlet weak var defImg: UIImageView!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var moreInfoLabel: UILabel!
    var globalMember = [Member]()
    var globalURL = [String]()
    var photoURL = [PhotoList]()
    var openProfile = [MemInfo]()
    var memSex: String = ""
    
    lazy var memUpperCase = self.memSex.uppercased()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if openProfile.isEmpty == true {
            sendRequest()
        } else {
            self.ageLabel.text = openProfile.first?.age
            self.nickNameLabel.text = openProfile.first?.name
            self.defImg.setImage(imageUrl: openProfile.first?.profileImage ?? "")
            self.defImg.contentMode = .scaleAspectFill
            self.defImg.cornerRadius = self.defImg.frame.width / 2
            self.moreInfoLabel.text = openProfile.first?.contents ?? "소개글이 없습니다."
        }
        
        layoutConfig()

        self.PhotoListCollection.delegate = self
        self.PhotoListCollection.dataSource = self
    }
    
    func layoutConfig() {
        halfView.layer.cornerRadius = 20
        halfView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if memUpperCase == "M" {
            iconMemSex.image = UIImage(named: "ico_sex_m")
            memSexImage.image = UIImage(named: "imgBoy")
            ageLabel.textColor = UIColor(red: 93, green: 126, blue: 232)
            memSexAge.layer.masksToBounds = false
            memSexAge.layer.borderColor = UIColor(red: 200, green: 211, blue: 249).cgColor
            memSexAge.layer.borderWidth = 1
            
        } else {
            iconMemSex.image = UIImage(named: "ico_sex_fm")
            memSexImage.image = UIImage(named: "imgGirl")
        }
        
    }
    func sendRequest() {
        let parameter : Parameters = [  //파라미터에 값을 넣어주었습니다.
            "cmd":"getProfile",
            "gender":"\(memSex)",
            "id":"ID"
        ]
        
        let url = URL(string: "http://babyhoney.kr/api/profile")!   //url을 지정해주었습니다.
        
        let decoder = JSONDecoder() //JSON디코더를 하기 위해 decoder 상수를 만들었습니다.
        AF.request(url,
                   method: .post,
                   parameters: parameter)
            .responseJSON { [self] response in
                switch response.result{ //반응이 성공하면 성공케이스를 실행하고 실패하면 실패케이스를 실행합니다.
                case .success (let jsonValue):
                    guard let data = try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted) else { return }
                    
                    do {
                        let result = try decoder.decode(Welcome.self, from: data) // 리절트 상수에 데이터에서 온 것을 코딩키를 사용하여 디코딩해줍니다.
                        let photoList = result.result.photo.photoList
                        let photoCount = photoList.count        //개수를 포토카운터 상수에 저장하였습니다.
                        let memInfo = result.result.member
                        self.likeCount.text = memInfo.totLikeCnt
                        self.ageLabel.text = memInfo.memAge
                        self.locLabel.text = memInfo.loc
                        self.nickNameLabel.text = memInfo.chatName
                        self.moreInfoLabel.text = memInfo.chatConts
                        let imageURL = URL(string: result.result.photo.defPhoto)
                        self.totalPhotoCount.text = "총 " + "\(photoCount)개"
                        let attributedCount = NSMutableAttributedString(string: totalPhotoCount.text!)
                        attributedCount.addAttribute(.foregroundColor, value: UIColor.red, range: (totalPhotoCount.text! as NSString).range(of: "\(photoCount)"))
                        self.totalPhotoCount.attributedText = attributedCount
                        self.defImg.kf.setImage(with: imageURL)
                        self.defImg.cornerRadius = self.defImg.frame.height / 2 // 원형으로 만들어줬습니다.
                        self.photoURL = Array(photoList)    //포토 url에 photolist를 배열형태로 저장하였습니다.
                        for i in 0..<photoCount{            // 포토카운터만큼 글로벌 url에 넣어주었습니다.
                            self.globalURL.append(photoList[i].url)
                        }
                        self.PhotoListCollection.reloadData()   //포토컬렉션에 데이터를 리로드하였습니다.
                    }
                    
                    catch{
                        print(error)
                    }
                    
                case .failure:
                    print(MyError.noContent)
                }
            }
        
    }
    
    deinit {
        print("deinit")
    }
    
    @IBAction func sendStoryBtnClicked(_ sender: UIButton) {
        sendStoryView = SendStoryView(frame: UIScreen.main.bounds)
        SendStoryView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(self.sendStoryView)
        }, completion: nil)
    }
    @IBAction func moreInfoButton(_ sender: UIButton) { // 화면전환 구현입니다.
        guard let moreInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "MoreInfoVC") as? MoreInfo else { return }
        moreInfoVC.itemCount = globalURL
        self.present(moreInfoVC, animated: true, completion: nil)
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {  // 백버튼입니다.
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {   // 셀의 개수를 반환해주었습니다.
        return self.globalURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{    //셀에 킹피셔를 활용해 이미지를 뿌렸습니다.
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:  indexPath) as? GridCell else {return UICollectionViewCell()}
        let imageURL = URL(string: "\(globalURL[indexPath.row])")
        cell.callImage.kf.setImage(with: imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { //show로 전체화면을 만들고 배열값도 보내주었습니다.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            guard let fullVC = storyboard.instantiateViewController(identifier: "FullScreen") as? FullScreen else { return }
            fullVC.fullScreen = globalURL
            fullVC.index = indexPath.row
            self.show(fullVC, sender: indexPath)
        } else {
            // Fallback on earlier versions
        }
    }
}

class GridCell : UICollectionViewCell {
    @IBOutlet weak var callImage: UIImageView!
}
