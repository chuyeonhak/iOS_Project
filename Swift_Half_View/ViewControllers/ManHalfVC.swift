//
//  ManHalfVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/12.
//


import Foundation
import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON


class ManHalfVC: UIViewController{
    var index = 1
    var getMemInfoSecond = [List]()
    
    var dataDelegate : SendListVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestConts(index)
    }
    
    @IBAction func openSendListBtn(_ sender: UIButton) {
        hello(nil)
    }
    func requestConts(_ index : Int) {
        
        
        let parameter : Parameters = [  //파라미터에 값을 넣어주었습니다.
            "bj_id" : "chuchu"
        ]
        let url = URL(string:"http://babyhoney.kr/api/story/page/\(index)")!   //url을 지정해주었습니다.
        
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
                        self.getMemInfoSecond = result.list
                    }
                    catch{
                        print(error)
                    }
                case .failure:
                    print(MyError.noContent)
                }
            }
    }
    func hello(_ completion: (([List]) -> Void)?) {
        guard let viewContrller = self.storyboard?.instantiateViewController(withIdentifier: "SendListVC") as? SendListVC else { return }
        viewContrller.delegate = self
//        viewContrller.getResponse2.append(contentsOf: getMemInfoSecond)
        viewContrller.getResponse2 = getMemInfoSecond
        self.present(viewContrller, animated: true, completion: nil)
        
        completion?(getMemInfoSecond)
    }
}
