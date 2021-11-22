//
//  TabBarVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/10.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        createTabbar()
    }
    func createTabbar() {
        
        guard let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as? ViewController else { return }
        
        guard let loginVC = UIStoryboard(name: "KakaoNaverVC", bundle: nil).instantiateViewController(withIdentifier: "KakaoNaverVC") as? KakaoNaverVC else { return }
        
        mainVC.title = "project1"
        loginVC.title = "project2"
        tabBar.backgroundColor = .lightGray
        self.setViewControllers([mainVC, loginVC], animated: true)
        
    }
}
