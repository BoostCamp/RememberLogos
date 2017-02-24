//
//  MessageHistory.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class MessageResult : NSObject, NSCoding {
    
    private var _book:String
    private var _chapter:Int
    private var _verse:Int
    private var _latestDate:Date = Date()
    private var _recitationResults = [RecitationResult]()
    
    init(book:String, chapter:Int, verse:Int) {
        _book = book
        _chapter = chapter
        _verse = verse
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self._book = aDecoder.decodeObject(forKey: "book") as! String
        self._chapter = aDecoder.decodeInteger(forKey: "chapter")
        self._verse = aDecoder.decodeInteger(forKey: "verse")
        self._latestDate = aDecoder.decodeObject(forKey: "latestDate") as! Date
        self._recitationResults = aDecoder.decodeObject(forKey: "recitationResults") as! [RecitationResult]
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_book, forKey: "book")
        aCoder.encode(_chapter, forKey: "chapter")
        aCoder.encode(_verse, forKey: "verse")
        aCoder.encode(_latestDate, forKey: "latestDate")
        aCoder.encode(_recitationResults, forKey: "recitationResults")
    }
    
    var book:String {
        get {
            return _book
        }
    }
    
    var chapter:Int {
        get {
            return _chapter
        }
    }
    
    var verse:Int {
        get {
            return _verse
        }
    }
    
    var totalScore:Int {
        get {
            return _recitationResults.reduce(0) { (sum, result) -> Int in
                return sum + result.score
            }
        }
    }
    
    var latestDate:Date {
        get {
            return _latestDate
        }
        
        set {
            _latestDate = newValue
        }
    }
    
    var results:[RecitationResult] {
        get {
            return _recitationResults
        }
    }
    
    func appendResult(result: RecitationResult) {
        _recitationResults.append(result)
    }
    
    func updateLatestDate() {
        _latestDate = Date()
    }
}
