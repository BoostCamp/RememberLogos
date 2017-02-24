//
//  DataCenter.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class ResultDataController {
    
    private var _courseResults = [CourseResult]()
    private var _currentCourse:Course!
    private var _currentMessage:Message!

    private static var sharedDataController: ResultDataController = {
        let dataCenter = ResultDataController()
        // Load Data - start
        
        loadCurrentCourse(dataCenter)
        
        // Load Data - end
        return dataCenter
    }()
    
    private init() { }
    
    class var shared : ResultDataController {
        get {
            return ResultDataController.sharedDataController
        }
    }
    
    var currentCourse:Course! {
        get {
            return _currentCourse
        }
        set {
            _currentCourse = newValue
            save()
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
//        UserDefaults.standard.setValue(_courseResults, forKey: "courseResult")
        UserDefaults.standard.setValue(_currentCourse.name, forKey: "currentCourseName")
//        UserDefaults.standard.setValue(_currentMessage, forKey: "currentMessage")
    }
    
    private static func loadCurrentCourse(_ dataCenter: ResultDataController) {
        if let currentCourseName = UserDefaults.standard.string(forKey: "currentCourseName"), let currentCourse = ContentDataController.shared.getCourse(name : currentCourseName) {
            
            dataCenter._currentCourse = currentCourse
            
        }
    }
    
}
