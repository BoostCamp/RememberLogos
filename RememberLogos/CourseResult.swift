//
//  CourseHistory.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class CourseResult : NSObject, NSCoding {
    
    private var _courseName:String
    private var _resultCount:Int = 0
    private var _messageResults = [MessageResult]()
    
    init(courseName : String) {
        _courseName = courseName
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self._courseName = aDecoder.decodeObject(forKey: "courseName") as! String
        self._resultCount = aDecoder.decodeInteger(forKey: "resultCount")
        self._messageResults = aDecoder.decodeObject(forKey: "messageResults") as! [MessageResult]
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
//        if let courseName = self._courseName {
            aCoder.encode(_courseName, forKey: "courseName")
//        }
        
//        if let resultCount = self._resultCount {
            aCoder.encode(_resultCount, forKey: "resultCount")
//        }
        
//        if let messageResults = self._messageResults {
            aCoder.encode(_messageResults, forKey: "messageResults")
//        }
    }
    
    var courseName:String {
        get {
            return _courseName
        }
    }
    
    var resultCount:Int {
        get {
            return _resultCount
        }
    }
    
    var totalScore:Int {
        get {
            return _messageResults.reduce(0) { (sum, messageResult) -> Int in
                return sum + messageResult.totalScore
            }
        }
    }
    
    var messageResults: [MessageResult] {
        get {
            return _messageResults
        }
    }
    
    func updateOneSession(_ recitationResults: [Message: RecitationResult]) {
        let date = Date()
        _resultCount += 1
        for (key, result) in recitationResults {
            let messageResult = getMessageResult(book: key.book, chapter: key.chapter, verse: key.verse)
            result.date = date
            messageResult.latestDate = date
            messageResult.appendResult(result: result)
        }
    }
    
    func getMessageResult(book:String, chapter:Int, verse:Int) -> MessageResult {
        
        for result in _messageResults {
            if(result.book == book && result.chapter == chapter && result.verse == verse) {
                return result
            }
        }
        
        let result = MessageResult(book: book, chapter: chapter, verse: verse)
        _messageResults.append(result)
        return result
    }
}
