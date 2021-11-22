//
//  MyError.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/07.
//

import Foundation

enum MyError: String, Error{    // 에러처리입니다.
    case noContent = "😭검색 결과가 없습니다."
    case textContent = "❗️10자 이상 300자 이하 입력❗️"
    case textIsfull = "❗️300자가 넘었습니다❗️"
    
    case lastPage = "마지막 페이지입니다." 
}

enum MyAlert: String {
    case didDelete = "❗️데이터가 삭제 되었습니다❗️"
    case sendStorySuccess = "❗️스토리가 전송되었습니다❗️"
    
    case lastPage = "❗️마지막 페이지입니다❗️"
    
}
