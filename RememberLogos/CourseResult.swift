//
//  CourseHistory.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class CourseResult {
    
    var _courseName:String = ""
    var _messageResults = [MessageResult]()
    
    init(courseName : String) {
        _courseName = courseName
    }
    
}
