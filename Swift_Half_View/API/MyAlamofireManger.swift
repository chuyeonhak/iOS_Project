////
////  MyAlamofireManger.swift
////  Swift_Half_View
////
////  Created by Chuchu Pro on 2021/10/07.
////
//
//import Foundation
//import Alamofire
//import SwiftyJSON
// 디자인 패턴 : 싱글턴
//final class MyAlamofireManger { //
//
//        static let shared = MyAlamofireManger()
//
//        let interceptors = Interceptor(interceptors:
//                                        [
//                                            BaseInterceptor()
//                                        ])
//
//        var session: Session
//
//        private init() {
//            session = Session(interceptor: interceptors)
//        }
//
//    func getPhotos(completion: @escaping (Result<[Photo], MyError>) -> Void) {
//        let parameter : Parameters = [
//            "cmd":"getProfile",
//            "gender":"F",
//            "id":"ID"
//        ]
//        let url = URL(string: "https://pida83.gabia.io/api/profile")!
//        self.session
//            .request(url,
//                   method: .post,
//                   parameters: parameter)
//            .validate().responseJSON(completionHandler: { response in
//                guard let responseValue = response.value else { return }
//
//                let responseJson = JSON(responseValue)
//
//                let jsonArray = responseJson["results"]
//
//                var photos = [Photo]()
//
//                print("jsonArray.count: \(jsonArray.count)")
//                for (index, subJson): (String, JSON) in jsonArray {
//                    print("index: \(index), subJson: \(subJson)")
//                    guard let photoList = subJson["photo"]["photoList"].string
////                          let likesCount = subJson["member"]["totLikeCnt"].string,
////                          let gender = subJson["member"]["mem_sex"].string,
////                          let age = subJson["member"]["mem_age"].string,
////                          let nickName = subJson["member"]["chat_name"].string,
////                          let location = subJson["member"]["loc"].string,
////                          let chatConts = subJson["member"]["chat_conts"].string,
////                          let photoSlck = subJson["member"]["mem_photo_slct"].string
//                    else { return }
//
//                    let photoItem = Photo(photoList: photoList)
////                    let memberItem = Member(likesCount: likesCount, gender: gender, age: age, nickName: nickName, location: location, chatConts: chatConts, photoSlct: photoSlck)
//                    // 배열에 넣고
//                    photos.append(photoItem)
//
//                }
//                if photos.count > 0 {
//                    completion(.success(photos))
//                    print(photos)
//                } else {
//                    completion(.failure(.noContent))
//                }
//            })
//    }
//}
////    func getPhotos(completion: @escaping (Result<[PhotoAndMember], MyError>) -> Void) {
////        self.session
////            .request(MyRouter.always)
////            .validate()
////            .responseJSON(completionHandler: { response in
////                guard let responseValue = response.value else { return }
////
////                let responseJson = JSON(responseValue)
////
////                let jsonArray = responseJson["results"]
////
////                var photosAndMebers = [PhotoAndMember]()
////
////                print("jsonArray.count: \(jsonArray.count)")
////                for (index, subJson): (String, JSON) in jsonArray {
////                    print("index: \(index), subJson: \(subJson)")
////                    guard let photoURL = subJson["photoList"]["urls"].string,
////                          let likesCount = subJson["member"]["totLikeCnt"].string,
////                          let gender = subJson["member"]["mem_sex"].string,
////                          let age = subJson["member"]["mem_age"].string,
////                          let nickName = subJson["member"]["chat_name"].string,
////                          let location = subJson["member"]["loc"].string,
////                          let chatConts = subJson["member"]["chat_conts"].string,
////                          let photoSlck = subJson["member"]["mem_photo_slct"].string else { return }
////
////                    let photoMemberItem = PhotoAndMember(photoURL: photoURL, likesCount: likesCount, gender: gender, age: age, nickName: nickName, location: location, chatConts: chatConts, photoSlct: photoSlck)
////
////                    // 배열에 넣고
////                    photosAndMebers.append(photoMemberItem)
////
////                }
////                if photosAndMebers.count > 0 {
////                    completion(.success(photosAndMebers))
////                } else {
////                    completion(.failure(.noContent))
////                }
////            })
//
//
//
