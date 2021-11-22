//
//  Constants.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/10/07.
//

import Foundation

enum API {  // 조금 더 편안한 구현을 위해 API 관련 값들을 저장했습니다.
    static let BASE_URL: String = "https://pida83.gabia.io/api/profile"
    
    static let JOIN_URL: String = "http://babyhoney.kr/login"
    
    static let GET_MEM: String = "http://babyhoney.kr/api/story"
    
    static let BASE_CMD: String = "getProfile"
    
    static let BASE_ID: String = "ID"
    
}

enum NOTIFICATION {
    enum API {
        static let AUTH_FAIL = "authentication_fail"
    }
}

enum RANDOM {
    static let PHOTO: [String] = ["http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT05PyYgIyEgJiYjKSAvNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiElJy4iLygtNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiElICcvLyAoNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiEmJCMjLCAjNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiEmJCMiKy8iNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiEmJCMhKiwsNXZteQ==",  "http://photo.club5678.com/prg/simg.php?type=pmchat&viewname=MjAxOzc0MjNXOzo5PT04PiAgKiEmJCMgKCo0cWx6","","",""]
    
    static let GENDER: [String] = ["M","F"]
    
    static let HEARTNAME: [String] = ["an_like_01", "an_like_02", "an_like_03", "an_like_04", "an_like_05", "an_like_06", "an_like_07"]
    
    static let RANDOMMARK: [String] = ["+", "-"]
}

enum EVENT {
    static let MESSAGE: String = "message"
}
