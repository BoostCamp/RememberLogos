//
//  CourseVC.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit

let coursePlistName = "courses"

class CourseVC: UITableViewController {
    
    var courses = [Course]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let coursesURL = Bundle.main.url(forResource: coursePlistName, withExtension: "plist") else {
            print("No Courses File URL")
            return
        }
        
        guard let coursesNSArray = NSArray(contentsOf: coursesURL) else {
            print("Cannot convert To Array")
            return
        }
        
        courses = coursesNSArray.map({ (item : Any) -> Course in
            guard let course = item as? [String:AnyObject] else {
                print("잘못된 형식의 course data : \(item)")
                return Course()
            }
            return Course(course: course)
        })
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
            if let recitationVC = segue.destination as? RecitationVC, let indexPath = self.tableView.indexPathForSelectedRow  {
                recitationVC.messages = courses[indexPath.row].messages
                recitationVC.course = courses[indexPath.row]
            }
        }
    }
 

}
