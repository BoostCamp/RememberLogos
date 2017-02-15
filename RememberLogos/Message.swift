//
//  Message.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class Message {
    
    private var _book: String!
    private var _chapter: Int!
    private var _verse: Int!
    private var _text: String!
    
    init(book: String, chapter: Int, verse: Int, text: String) {
        _book = book
        _chapter = chapter
        _verse = verse
        _text = text
    }
    
    var book: String {
        return _book
    }
    var chapter: Int {
        return _chapter
    }
    var verse: Int {
        return _verse
    }
    var text: String {
        return _text
    }
}