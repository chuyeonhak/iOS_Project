//
//  MoreInfoVC.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/11.
//

import Foundation
import UIKit

class MoreInfo: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    var itemCount: [String] = [] //HalfVC에서 url리스트를 받으려고 만들었습니다.
    @IBOutlet weak var moreInfoCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func dismissTapped(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: false, completion: nil) // 백버튼입니다.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount.count  //itemCount의 개수로 셀의 개수를 만듭니다.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreInfoCell", for:  indexPath) as? MoreInfoCell else {return UICollectionViewCell()}
        let imageURL = URL(string: "\(itemCount[indexPath.row])") //itemCount의 indexPath.row를 url로 받고 imageURL 상수에 저장하였습니다.
        cell.photoList.kf.setImage(with: imageURL)// kf로 cell에 이미지를 뿌려줬습니다.

        return cell //셀로 반환합니다.
    }
}



class MoreInfoCell : UICollectionViewCell {
    
    @IBOutlet weak var photoList: UIImageView!  //이미지뷰 아울렛변수로 설정하였습니다.
    
}

