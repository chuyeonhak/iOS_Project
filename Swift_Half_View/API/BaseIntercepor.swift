////
////  BaseIntercepor.swift
////  Swift_Half_View
////
////  Created by Chuchu Pro on 2021/10/07.
////
//
//import Foundation
//import Alamofire
//
//class BaseInterceptor: RequestInterceptor {
//    // 리퀘스트를 호출할 때 같이 호출 됨 컴플레션 항상 호출해야함
//    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
//        
//        print("BaseInterceptor - adapt() called")
//        
//        var request = urlRequest
//        
//        // 에러가 남았을 때 html이 아니고 json으로 받는 것
//        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Accept")
//        
//        
//        // 공통 파라미터 추가
//        var dictionary = [String:String]()
//        
//        dictionary.updateValue(API.BASE_CMD, forKey: "cmd")
//        dictionary.updateValue(API.BASE_ID, forKey: "id")
//
//        do {
//            request = try URLEncodedFormParameterEncoder().encode(dictionary, into: request)
//        } catch {
//            print(error)
//        }
////
//        
//        
//        completion(.success(request))
//    }
//    
//    // 응답에 대한 결과,
//    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        print("BaseInterceptor - retry() called")
//        
//        guard let statusCode = request.response?.statusCode else {
//            completion(.doNotRetry)
//            return
//        }
//        
//        let data = ["statusCode" : statusCode]
//        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.API.AUTH_FAIL), object: nil, userInfo: data)
//        
//        completion(.doNotRetry)
//    }
//}
