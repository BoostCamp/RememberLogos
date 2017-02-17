//
//  Course.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class Course {
    private var _name: String!
    private var _desc: String!
    private var _messages: [Message] = [Message]()
    
    init() { }
    
    init(name: String, desc: String, messages : [Message]) {
        _name = name
        _desc = desc
        _messages = messages
    }
    
    init(course:[String: AnyObject]) {
        _name = course["name"] as? String
        _desc = course["desc"] as? String
        if let messages = course["messages"] as? [AnyObject] {
            _messages = messages.map({ (item : AnyObject) -> Message in
                if let message = item as? [String: AnyObject] {
                    return Message(message: message)
                } else {
                    print("잘못된 형식의 message data : \(item)")
                    return Message()
                }
                
            })
        }
    }
    
    var name: String {
        return _name
    }
    var desc: String {
        return _desc
    }
    var messages: [Message] {
        return _messages
    }
}
