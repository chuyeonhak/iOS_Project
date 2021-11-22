//
//  SocketIOManager.swift
//  Swift_Half_View
//
//  Created by Chuchu Pro on 2021/11/11.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    
    static let shared = SocketIOManager()
    let manager = SocketManager(socketURL: URL(string: "https://devsol6.club5678.com:5555")!, config: [.log(false), .compress, .reconnects(false)])
    var socket: SocketIOClient!
    
    var data: [Any]?
    
    override init() {
        super.init()
        
        socket = self.manager.socket(forNamespace: "/")

    }

    func establishConnection() {
        socket.connect()
        print("Socket 연결 시도")
    }

    func closeConnection() {
        socket.disconnect()
        print("Socket 연결 종료")
    }
    
    let reqRoomOut = ["cmd" : "reqRoomOut"]
    
    func reqRoomEnter(mem_id: String, chat_name: String, mem_photo: String) {
        let enterRoom = socket.emitWithAck(EVENT.MESSAGE, ["cmd" : "reqRoomEnter",
                                                           "mem_id" : "\(mem_id))",
                                                           "chat_name" : "\(chat_name)",
                                                          "mem_photo" : "\(mem_photo)"
                                                          ])
        let memId = mem_id
        let chatName = chat_name
        let memPhoto = mem_photo
        
        enterRoom.timingOut(after: 1) { [weak self] ack in
            if self?.checkResult(any: ack) == true {
                print("good")
            } else {
                print("bad")
                self?.socket.connect()
                self?.reqRoomEnter(mem_id: memId, chat_name: chatName, mem_photo: memPhoto)
            }
        }
    }
    
    func exitRoom() {
        socket.emit("message", reqRoomOut)
    }
    
    func sendMessage(msg: String){
        socket.emit("message", ["cmd" : "sendChatMsg",
                                "msg" : "\(msg)"])
    }
    
    func sendLike() {
        socket.emit(EVENT.MESSAGE, ["cmd" : "sendLike"])
    }
    
    func getSocket() -> SocketIOClient {
        return socket
    }
    
    func checkResult(any: [Any]) -> Bool{
        let stringArrayAny = any.first.map {String(describing: $0)}
        if (stringArrayAny ?? "hello").contains("success = y") {
            return true
        } else {
            return false
        }
    }

}
