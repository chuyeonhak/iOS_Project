//
//  LiveModel.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/13.
//

struct LiveModel: Codable {
    let cmd: String
    let from: From?
    let msg: String?
}

struct From: Codable {
    let chatName, memID: String
    let memPhoto: String

    enum CodingKeys: String, CodingKey {
        case chatName = "chat_name"
        case memID = "mem_id"
        case memPhoto = "mem_photo"
    }
}
