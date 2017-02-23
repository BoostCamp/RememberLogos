//
//  DataCenter.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class DataCenter {
    
    var _courseResults = [CourseResult]()
    var _currentCourse:Course!
    var _currentMessage:Message!

    private static var sharedDataCenter: DataCenter = {
        let dataCenter = DataCenter()
        // Config
        return dataCenter
    }()
    
    private init() { }
    
    class var shared : DataCenter {
        get {
            return DataCenter.sharedDataCenter
        }
    }
    
    var currentCourse:Course! {
        get {
            return _currentCourse
        }
        set {
            _currentCourse = newValue
        }
    }
    
    
    var currentMessage:Message {
        get {
            return _currentMessage
        }
        set {
            _currentMessage = newValue
        }
    }
    
    var courseResults:[CourseResult] {
        get {
            return _courseResults
        }
    }
    
    func getCourseResult(index : Int) -> CourseResult! {
        guard index >= _courseResults.count else {
            return nil
        }
        return _courseResults[index]
    }
    
    func getCourseResult(name : String) -> CourseResult! {
        for result in _courseResults {
            if result._courseName == name {
                return result
            }
        }
        return nil
    }
    
    func createCourseResult(result : CourseResult) {
        _courseResults.append(result)
    }
    
    func save()  {
        UserDefaults.standard.setValue(_courseResults, forKey: "courseResult")
        UserDefaults.standard.setValue(_currentCourse, forKey: "currentCourse")
        UserDefaults.standard.setValue(_currentMessage, forKey: "currentMessage")
    }

    
}
