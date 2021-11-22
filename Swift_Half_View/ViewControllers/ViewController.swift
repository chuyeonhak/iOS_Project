//
//  ViewController.swift
//  Swift_Half_View
//  GitStart by Chuchu Pro on 2021/10/07.
//  Created by Chuchu Pro on 2021/10/07.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func btnTapped(_ sender: UIButton) {  //여자 클릭입니다.
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "halfView") as? HalfVC else { return }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.memSex = "F"
        self.present(viewController, animated: true, completion: nil)
        
        
    }
    @IBAction func ManButtonTapped(_ sender: UIButton) {    //남자 클릭입니다.
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "halfView") as? HalfVC else { return }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.memSex = "M"
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    @IBAction func sendListBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SendListVC") as? SendListVC else { return }
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
    }

}

