//
//  fullScreen.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/11.
//

import Foundation
import UIKit

class FullScreen: UIViewController {
    @IBOutlet weak var fullScreenCV: UICollectionView! // 컬렉션뷰 아울렛변수 입니다.
    var fullScreen : [String] = []      //HalfVC에서 URL값들을 받기위한 배열입니다.
    var index = 0                       //인덱스를 사용하여 HalfVC에서 순서를 받아서 먼저 보여주기 위해 만든 변수입니다.
    var myDeviceSize = UIScreen.main.bounds.size.width
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenCV.delegate = self
        fullScreenCV.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
            DispatchQueue.main.async { [weak self] in
                self?.fullScreenCV.contentOffset.x = self!.myDeviceSize * CGFloat(self?.index ?? 0)
            }
        }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil) //백버튼입니다.
    }
}

extension FullScreen: UICollectionViewDelegate {
    
}
extension FullScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fullScreen.count //fullScreen의 개수만큼 만듭니다.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullScreenCell", for:  indexPath) as? FullScreenCell else {return UICollectionViewCell()}
        let imageURL = URL(string: "\(fullScreen[indexPath.row])") //kf를 활용하여 셀에 이미지를 넣었습니다.
        cell.fullScreenImg.kf.setImage(with: imageURL)

        return cell
    }
    
    // MARK: FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.width
        let itemHeight = collectionView.bounds.height - 100
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

class FullScreenCell : UICollectionViewCell{
    
    @IBOutlet weak var fullScreenImg: UIImageView!

}
