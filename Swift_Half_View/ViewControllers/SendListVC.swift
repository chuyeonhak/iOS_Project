//
//  SendListVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/22.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftUI


class SendListVC: UIViewController{
    
    var getResponse = [List]()      // List타입의 배열을 받는 변수입니다.
    var index = 1                   // 페이지의 값을 올릴 index입니다.
    var totalPage = 1               // 전체 페이지를 1로 초기화하였습니다.
    var currentPage = 1             // 현재 페이지를 1로 초기화하였습니다.
    var flag = false
    lazy var centerLayout = self.sendListTableView.center
    @IBOutlet weak var sendListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestConts(index)     //최초 1회실행을 하게 하였습니다.
        let myTableViewCellNib = UINib(nibName: String(describing: SendListTableViewCell.self), bundle: nil)
        self.sendListTableView.register(myTableViewCellNib, forCellReuseIdentifier: "SendListTableViewCell")
        //커스텀 셀을 등록해주었습니다.
        //컴파일러에게 UITableView의 크기가 대충 120정도라고 얘기해주고 자동으로 뷰의 높이를 지정해주었습니다.
        self.sendListTableView.rowHeight = UITableView.automaticDimension
        self.sendListTableView.estimatedRowHeight = 120
        
        self.sendListTableView.delegate = self
        self.sendListTableView.dataSource = self
        
    }
    
    @IBAction func backButton(_ sender: UIButton) { // 배경화면을 눌렀을 때 뒤로가기 버튼입니다.
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissBtn(_ sender: UIButton) { // 테이블 뷰에있는 백버튼입니다.
        self.dismiss(animated: true, completion: nil)
    }
    
    func requestConts(_ index : Int) {              // Alamofire 실행 함수 입니다.
        self.flag = true
        let parameter : Parameters = [  //파라미터에 값을 넣어주었습니다.
            "bj_id" : "chuchu"
        ]
        let url = URL(string:"http://babyhoney.kr/api/story/page/\(index)")!   //index로 page를 지정해주었습니다.
        
        let decoder = JSONDecoder() //JSON디코더를 하기 위해 decoder 상수를 만들었습니다.
        AF.request(url,
                   method: .get,
                   parameters: parameter,
                   encoding: URLEncoding.queryString)
            .responseJSON { response in
                switch response.result{ //반응이 성공하면 성공케이스를 실행하고 실패하면 실패케이스를 실행합니다.
                case .success (let jsonValue):
                    guard let data = try? JSONSerialization.data(withJSONObject: jsonValue, options: .prettyPrinted) else { return }
                    do {
                        let result = try decoder.decode(SendListModel.self, from: data) // 리절트 상수에 데이터에서 온 것을 코딩키를 사용하여 디코딩해줍니다.
                        
                        self.totalPage = result.totalPage           // 토탈 페이지에 값을 넣어주었습니다.
                        if !(self.totalPage % 5 == 0){              // 페이지가 5로 나누어지지 않았을 때 몫을 더해줘서 마지막 페이지를 읽게 만들었습니다.
                            self.totalPage += (5 - self.totalPage % 5)
                        }
                        self.currentPage = result.currentPage       // 현재 페이지를 받아왔습니다.
                        self.getResponse.append(contentsOf: result.list)        //결과값을 getResponse에 더해주고
                        self.sendListTableView.tableFooterView = self.createSpinerFooter()  //인디케이터를 넣어주었습니다.
                        DispatchQueue.main.async{ [weak self] in     //지금시간부터 1초동안 테이블을 다시 써줬습니다.
                            self?.sendListTableView.reloadData()
                            self?.flag = false
                        }
                    }
                    catch{
                        print(error)
                    }
                case .failure:
                    print(MyError.noContent)
                }
            }
    }
     private func createSpinerFooter() -> UIView {      //인디게이터를 만드는 함수 입니다.
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
    @objc func presentActionSheet(sender: UIButton) {       // cell에서는 present함수가 안 되기때문에 VC에서 만들어서 넘겨주었습니다.
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelSheet = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self]_ in
            
            let indexPath = IndexPath(row: sender.tag, section: 0)  // 버튼에 태그로 indexPath를 넘겨주었습니다.
            self?.getResponse.remove(at: indexPath.row)             // List에서 삭제하고, 테이블 셀도 삭제하고 리로드 하였습니다.
            self?.sendListTableView.deleteRows(at: [indexPath], with: .fade)
            self?.sendListTableView.reloadData()
            self?.showToast(message: MyAlert.didDelete.rawValue)    // 삭제 완료시 생기는 토스트입니다.
        })
        
        actionSheet.addAction(deleteAction)     //AlertController에 취소액션과 삭제 액션을 넣어주었습니다.
        actionSheet.addAction(cancelSheet)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {  // Toast를 만드는 함수 입니다.
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.width/2 - 110, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0 }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
    }
}

extension SendListVC: UITableViewDelegate {

}

        //MARK: UITableViewDataSource
extension SendListVC: UITableViewDataSource {   // 테이블셀의 개수를 지정해줬습니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 테이블 셀의 구성을 해줬습니다.
        
        let cell = sendListTableView.dequeueReusableCell(withIdentifier: "SendListTableViewCell", for: indexPath) as! SendListTableViewCell
        cell.sendStory.text = getResponse[indexPath.row].storyConts
        cell.sender.text = getResponse[indexPath.row].sendChatName
        if #available(iOS 13.0, *) {
            cell.howMuchTime.text = getResponse[indexPath.row].insDate.stringToDate.relativeTime_abbreviated
        } else {
            // Fallback on earlier versions
        }
        
        if getResponse[indexPath.row].sendMemGender == "M" {
            cell.textViewColor.backgroundColor = UIColor(red: 238, green: 238, blue: 238)
            cell.senderSex.image = UIImage(named: "badge_sex_m")
        } else {
            cell.textViewColor.backgroundColor = UIColor(red: 241, green: 238, blue: 255)
            cell.senderSex.image = UIImage(named: "badge_sex_fm")
        }
        
        if getResponse[indexPath.row].sendMemPhoto == nil {
            cell.senderImage.image = UIImage(named: "img_default")
        } else {
            let imageURL = URL(string: "\(getResponse[indexPath.row].sendMemPhoto ?? "")")
            cell.senderImage.kf.setImage(with: imageURL)
        }
        cell.optionBtn.tag = indexPath.row      // indexPath.row값을 Btn.tag에 저장하였습니다.
        cell.optionBtn.addTarget(self, action: #selector(presentActionSheet(sender:)), for: .touchUpInside) //버튼에 액션을 추가하였습니다.
        
        return cell
    }
    
    // 슬라이드해서 삭제하는 함수입니다.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            getResponse.remove(at: indexPath.row)
            sendListTableView.deleteRows(at: [indexPath], with: .fade)
            self.showToast(message: MyAlert.didDelete.rawValue)
        } else if editingStyle == .insert { }
    }
}

        //MARK: UIScrollViewDelegate
extension SendListVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height: CGFloat = scrollView.frame.size.height
        let contentYOffset: CGFloat = scrollView.contentOffset.y
        let scrollViewHeight: CGFloat = scrollView.contentSize.height
        let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
        
        if distanceFromBottom < height {
            if flag == false {
                if self.currentPage < (self.totalPage / 5){
                    self.index += 1
                    self.requestConts(index)
                    //                self.flag = false
                } else {
                    self.sendListTableView.tableFooterView = nil
                    showToast( message: MyAlert.lastPage.rawValue)
                }
            }
        }
    }
}

class SendListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textViewColor: UIView!
    @IBOutlet weak var senderSex: UIImageView!
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var howMuchTime: UILabel!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var sendStory: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        senderImage.cornerRadius = senderImage.frame.height / 2
        senderImage.contentMode = .scaleToFill
    }
    
    @IBAction func moreInfoBtn(_ sender: UIButton) {
        //MARK: 액션쉽 추가
    }
}
