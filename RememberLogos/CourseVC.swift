//
//  CourseVC.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit

class CourseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var courses = [Course]()
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var nextCourseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.courses = ContentDataController.shared.courses
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showCurrentCourseButton()
    }
    
    // delegate overriding - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                
                ResultDataController.shared.currentCourse = course
                
                recitationVC.messages = course.messages
                recitationVC.course = course
                recitationVC.courseResult = ResultDataController.shared.getCourseResult(name: course.name)
            }
        }
        if (segue.identifier == "nextRecitation") {
            if let recitationVC = segue.destination as? RecitationVC, let currentCourse = ResultDataController.shared.currentCourse, let last = courses.last {

                if last.name == currentCourse.name, let first = courses.first{
                    ResultDataController.shared.currentCourse = first
                } else if let curIndex = courses.index(where: { (course: Course) -> Bool in
                        return currentCourse.name == course.name ? true : false
                }) {
                    ResultDataController.shared.currentCourse = courses[curIndex + 1]
                }
                        
                recitationVC.messages = ResultDataController.shared.currentCourse.messages
                recitationVC.course = ResultDataController.shared.currentCourse
            }
        }
        if(segue.identifier == "showCurrentRecitation") {
            if let recitationVC = segue.destination as? RecitationVC, let currentCourse = ResultDataController.shared.currentCourse {
                
                recitationVC.messages = currentCourse.messages
                recitationVC.course = currentCourse
                recitationVC.courseResult = ResultDataController.shared.getCourseResult(name: currentCourse.name)
            }
        }
    }
    
    private func showCurrentCourseButton() {
        if let currentCourse = ResultDataController.shared.currentCourse {
            
            if let titleLabel = nextCourseButton.titleLabel {
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 0
                titleLabel.lineBreakMode = .byWordWrapping
            }
            
            let title = NSMutableAttributedString()
            
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = 1.5
            style.alignment = .center
            
            let firstLine = NSAttributedString(string: "현재 진행중인 코스", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSParagraphStyleAttributeName: style])
            
            let secondLine = NSAttributedString(string: "\n\(currentCourse.name)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 10), NSParagraphStyleAttributeName: style])
            
            title.append(firstLine)
            title.append(secondLine)
            
            nextCourseButton.setAttributedTitle(title, for: .normal)
            self.view.bringSubview(toFront: nextCourseButton)
        } else {
            print("No currnet Courses")
            nextCourseButton.isHidden = true
        }
    }

}
