// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let sendListModel = try? newJSONDecoder().decode(SendListModel.self, from: jsonData)

import Foundation

struct SendListModel: Codable {
    let status: String
    let list: [List]
    let totalPage, currentPage: Int

    enum CodingKeys: String, CodingKey {
        case status, list
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

// MARK: - List
struct List: Codable {
    let regNo, sendMemGender, sendMemNo, sendChatName: String
    let insDate, readYn: String
    let sendMemPhoto: String?
    let storyConts, bjID: String?

    enum CodingKeys: String, CodingKey {
        case regNo = "reg_no"
        case sendMemGender = "send_mem_gender"
        case sendMemNo = "send_mem_no"
        case sendChatName = "send_chat_name"
        case insDate = "ins_date"
        case readYn = "read_yn"
        case sendMemPhoto = "send_mem_photo"
        case storyConts = "story_conts"
        case bjID = "bj_id"
    }
}
