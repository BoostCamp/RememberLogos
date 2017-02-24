//
//  MessageResult.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class RecitationResult : NSObject, NSCoding {
    
    static let correctPointWeight = 20
    static let hintPointWeight = 5
    static let wrongPointWeight = 1
    
    private var _correct:Int = 0
    private var _hint:Int = 0
    private var _wrong:Int = 0
    private var _date:Date = Date()
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self._correct = aDecoder.decodeInteger(forKey: "correct")
        self._hint = aDecoder.decodeInteger(forKey: "hint")
        self._wrong = aDecoder.decodeInteger(forKey: "wrong")
        self._date = aDecoder.decodeObject(forKey: "date") as! Date
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_correct, forKey: "correct")
        aCoder.encode(_hint, forKey: "hint")
        aCoder.encode(_wrong, forKey: "wrong")
        aCoder.encode(_date, forKey: "date")
    }
    
    var score:Int {
        get {
            let score = (_correct * RecitationResult.correctPointWeight) - (_hint * RecitationResult.hintPointWeight * _correct) - (_wrong * RecitationResult.wrongPointWeight * _correct)
            if score > 0 {
                return score
            } else {
                return 0
            }
        }
    }
    
    var hint:Int {
        get {
            return _hint
        }
    }
    
    var correct:Int {
        get {
            return _correct
        }
    }
    
    var wrong:Int {
        get {
            return _wrong
        }
    }
    
    var date:Date {
        get {
            return _date
        }
        set {
            _date = newValue
        }
    }
    
    func increseHint() {
        _hint += 1
    }
    
    func increseWrong() {
        _wrong += 1
    }
    
    func increseCorrect(_ adder:Int) {
        _correct += adder
    }
}
