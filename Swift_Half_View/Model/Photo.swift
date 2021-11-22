//
//  Photo.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/10.
//

import Foundation   //포토 모델링입니다.

// MARK: - Welcome
struct Welcome: Codable {
    let status: String
    let result: Result
}

// MARK: - Result
struct Result: Codable {
    let photo: Photo
    let member: Member
}

// MARK: - Member
struct Member: Codable {
    let memLOC, memID: String
    let distance: Int
    let memVoice, chatName, lCode, loc: String
    let totLikeCnt, memPhotoSlct, dataInsYn, chatConts: String
    let memLCode, memPhoto, memJewel, memNo: String
    let memVoiceCERTYn, memSex, memAmt, memAge: String

    enum CodingKeys: String, CodingKey {
        case memLOC = "mem_loc"
        case memID = "mem_id"
        case distance
        case memVoice = "mem_voice"
        case chatName = "chat_name"
        case lCode = "l_code"
        case loc, totLikeCnt
        case memPhotoSlct = "mem_photo_slct"
        case dataInsYn
        case chatConts = "chat_conts"
        case memLCode = "mem_l_code"
        case memPhoto = "mem_photo"
        case memJewel = "mem_jewel"
        case memNo = "mem_no"
        case memVoiceCERTYn = "mem_voice_cert_yn"
        case memSex = "mem_sex"
        case memAmt = "mem_amt"
        case memAge = "mem_age"
    }
}

// MARK: - Photo
struct Photo: Codable {
    let certYn: String
    let defPhoto: String
    let photoCERTCnt: Int
    let yCnt, maxCnt: String
    let avataURL: String
    let photoList: [PhotoList]
    let photoDir: String
    let avataYn, cnt: String

    enum CodingKeys: String, CodingKey {
        case certYn, defPhoto
        case photoCERTCnt = "photoCertCnt"
        case yCnt, maxCnt
        case avataURL = "avataUrl"
        case photoList, photoDir, avataYn, cnt
    }
}

// MARK: - PhotoList
struct PhotoList: Codable {
    let url: String
}
