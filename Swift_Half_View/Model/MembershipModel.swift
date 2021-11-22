//
//  MembershipModel.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/04.
//

import Foundation


struct MembershipModel: Codable {
    let memInfo: MemInfo
    let code: Int
    let isMember: Bool
    let msg, redirectURL: String
    
    enum CodingKeys: String, CodingKey {
        case memInfo = "mem_info"
        case code
        case isMember = "is_member"
        case msg
        case redirectURL = "redirect_url"
    }
}


struct MemInfo: Codable {
    let name, email: String
    let profileImage: String?
    let contents, gender, age: String?
    
    enum CodingKeys: String, CodingKey {
        case name, email
        case profileImage = "profile_image"
        case contents, gender, age
    }
}

struct MembershipEmail: Codable{
    let isMember: Bool
    
    enum CodingKeys: String, CodingKey {
        case isMember = "is_member"
    }
}

struct MembershipWithdrawal: Codable {
    let msg: String
    
    enum CodingKeys: String, CodingKey {
        case msg = "msg"
    }
}
