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

    private static var sharedDataController: ResultDataController = {
        let dataCenter = ResultDataController()
        // Load Data - start
        
        loadAll(dataCenter)
        
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
            saveCurrentCourse()
        }
    }
    
    var courseResults:[CourseResult] {
        get {
            return _courseResults
        }
    }
    
    func getCourseResult(name : String) -> CourseResult {
        for result in _courseResults {
            if result.courseName == name {
                return result
            }
        }
        
        return ResultDataController.shared.createCourseResult(courseName: name)
    }
    
    func loadAll() {
        
        if let data = UserDefaults.standard.data(forKey: "courseResults") as Data?, let courseResults = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CourseResult] {
            _courseResults = courseResults
        }
    }
    
    func saveAll()  {
        let mutable = NSKeyedArchiver.archivedData(withRootObject: _courseResults)
        UserDefaults.standard.setValue(mutable, forKey: "courseResults")
        UserDefaults.standard.setValue(_currentCourse.name, forKey: "currentCourseName")
    }
    
    
    func saveCurrentCourse()  {
        UserDefaults.standard.setValue(_currentCourse.name, forKey: "currentCourseName")
    }
    
    private func createCourseResult(courseName: String) -> CourseResult {
        let courseResult = CourseResult(courseName: courseName)
        _courseResults.append(courseResult)
        
        return courseResult
    }
    
    
    private static func loadAll(_ dataCenter: ResultDataController) {
        if let currentCourseName = UserDefaults.standard.string(forKey: "currentCourseName"), let currentCourse = ContentDataController.shared.getCourse(name : currentCourseName) {
            
            dataCenter._currentCourse = currentCourse
            
        }
        
        if let data = UserDefaults.standard.data(forKey: "courseResults") as Data?, let courseResults = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CourseResult]{
            dataCenter._courseResults = courseResults
        }
    }
    
}
