//
//  MyRouter.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/07.
//

import Foundation
import Alamofire

enum MyRouter: URLRequestConvertible{
    case always
    
    var baseURL: URL {
        return URL(string: API.BASE_URL)!
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: [String: String] {
        return ["cmd":"getProfile", "gender":"F", "id":"ID"]
    }
    func asURLRequest() throws -> URLRequest {
        let url = baseURL
        
        var request = URLRequest(url: url)
        
        request.method = method
        
        request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
        
        return request
    }
    
}
