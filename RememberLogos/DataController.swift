//
//  DataCenter.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class DataController {
    static let coursePlistName = "courses"
    
    private var _courses = [Course]()
    
    private var _courseResults = [CourseResult]()
    private var _currentCourse:Course!
    private var _currentMessage:Message!

    private static var sharedDataController: DataController = {
        let dataCenter = DataController()
        
        // Load Data - start
        dataCenter.loadCourses()
        if let currentCourseName = UserDefaults.standard.string(forKey: "currentCourseName"), let currentCourse = dataCenter.getCourse(name : currentCourseName) {
                dataCenter._currentCourse = currentCourse
        }
        // Load Data - end
        
        return dataCenter
    }()
    
    private init() { }
    
    class var shared : DataController {
        get {
            return DataController.sharedDataController
        }
    }
    
    private func loadCourses() {
        guard let coursesURL = Bundle.main.url(forResource: DataController.coursePlistName, withExtension: "plist") else {
            print("No Courses File URL")
            return
        }
        
        guard let coursesNSArray = NSArray(contentsOf: coursesURL) else {
            print("Cannot convert To Array")
            return
        }
        
        _courses = coursesNSArray.map({ (item : Any) -> Course in
            guard let course = item as? [String:AnyObject] else {
                print("잘못된 형식의 course data : \(item)")
                return Course()
            }
            return Course(course: course)
        })
    }
    
    var courses: [Course] {
        get {
            return _courses
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
    
    func getCourse(name: String) -> Course! {
        if let index = _courses.index(where: { (course : Course) -> Bool in
            return (course.name == name) ? true : false
        }) {
            return _courses[index]
        }
        return nil
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
    
}
