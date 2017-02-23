//
//  CourseVC.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit

class CourseVC: UITableViewController {
    
    var courses = [Course]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.courses = DataCenter.shared.courses
    }
    
    // delegate overriding - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
            
        let course = courses[indexPath.row]
        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = course.desc
            
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showRecitation") {
            if let recitationVC = segue.destination as? RecitationVC, let indexPath = self.tableView.indexPathForSelectedRow {
                
                let course = courses[indexPath.row]
                
                DataCenter.shared.currentCourse = course
                
                recitationVC.messages = course.messages
                recitationVC.course = course
                recitationVC.courseResult = DataCenter.shared.getCourseResult(name: course.name)
            }
        }
        if (segue.identifier == "nextRecitation") {
            if let recitationVC = segue.destination as? RecitationVC, let currentCourse = DataCenter.shared.currentCourse, let last = courses.last {

                if last.name == currentCourse.name, let first = courses.first{
                    DataCenter.shared.currentCourse = first
                } else if let curIndex = courses.index(where: { (course: Course) -> Bool in
                        return currentCourse.name == course.name ? true : false
                }) {
                    DataCenter.shared.currentCourse = courses[curIndex + 1]
                }
                        
                recitationVC.messages = DataCenter.shared.currentCourse.messages
                recitationVC.course = DataCenter.shared.currentCourse
            }
        }
    }
 

}
