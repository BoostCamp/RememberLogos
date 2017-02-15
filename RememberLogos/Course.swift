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
    
    init(name: String, desc: String, messages : [Message]) {
        _name = name
        _desc = desc
        _messages = messages
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
