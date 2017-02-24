//
//  ContentDataController.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 24..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation
//
//  DataCenter.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 22..
//  Copyright © 2017년 김필환. All rights reserved.
//

import Foundation

class ContentDataController {
    static let coursePlistName = "courses"
    
    private var _courses = [Course]()
    
    private static var sharedDataController: ContentDataController = {
        let dataCenter = ContentDataController()
        
        // Load Data - start
        dataCenter.loadCourses()
        // Load Data - end
        
        return dataCenter
    }()
    
    private init() { }
    
    class var shared : ContentDataController {
        get {
            return ContentDataController.sharedDataController
        }
    }
    
    private func loadCourses() {
        guard let coursesURL = Bundle.main.url(forResource: ContentDataController.coursePlistName, withExtension: "plist") else {
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
    
    func getCourse(name: String) -> Course! {
        if let index = _courses.index(where: { (course : Course) -> Bool in
            return (course.name == name) ? true : false
        }) {
            return _courses[index]
        }
        return nil
    }
}
