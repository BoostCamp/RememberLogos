//
//  MessageResult.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class RecitationResult {
    
    static let correctPointWeight = 20
    static let hintPointWeight = 5
    static let wrongPointWeight = 1
    
    private var _correct:Int = 0
    private var _hint:Int = 0
    private var _wrong:Int = 0
    private var _date:Date = Date()
    
    init(correct:Int, hint:Int, wrong:Int) {
        _correct = correct
        _hint = hint
        _wrong = wrong
    }
    
    init() {
        
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
