//
//  MessageHistory.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class MessageResult {
    
    var _course:String
    var _book:String
    var _chapter:Int
    var _verse:Int
    var _latestDate:Date = Date()
    var _recitationResults = [RecitationResult]()
    
    init(course:String, book:String, chapter:Int, verse:Int) {
        _course = course
        _book = book
        _chapter = chapter
        _verse = verse
    }
    
    var results:[RecitationResult] {
        get {
            return _recitationResults
        }
    }
    
    func appendResult(result: RecitationResult) {
        _recitationResults.append(result)
    }
    
}
