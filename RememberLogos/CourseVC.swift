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
        
        var messages = [Message]()
        
        messages.append(Message(book: "시편", chapter: 23, verse: 1, text: "여호와는 나의 목자시니 내게 부족함이 없으리로다"))
        messages.append(Message(book: "시편", chapter: 23, verse: 2, text: "그가 나를 푸른 풀밭에 누이시며 쉴 만한 물 가로 인도하시는도다"))
        messages.append(Message(book: "시편", chapter: 23, verse: 3, text: "내 영혼을 소생시키시고 자기 이름을 위하여 의의 길로 인도하시는도다"))
        messages.append(Message(book: "시편", chapter: 23, verse: 4, text: "내가 사망의 음침한 골짜기로 다닐지라도 해를 두려워하지 않을 것은 주께서 나와 함께 하심이라 주의 지팡이와 막대기가 나를 안위하시나이다"))
        messages.append(Message(book: "시편", chapter: 23, verse: 5, text: "주께서 내 원수의 목전에서 내게 상을 차려 주시고 기름을 내 머리에 부으셨으니 내 잔이 넘치나이다"))
        messages.append(Message(book: "시편", chapter: 23, verse: 6, text: "내 평생에 선하심과 인자하심이 반드시 나를 따르리니 내가 여호와의 집에 영원히 살리로다"))

        courses.append(Course(name: "초급 1 단계 - 나의 목자", desc: "시편 23:1~6", messages: messages))
        
        
        messages = [Message]()
        messages.append(Message(book: "신명기", chapter: 6, verse: 4, text: "이스라엘아 들으라 우리 하나님 여호와는 오직 유일한 여호와이시니"))
        messages.append(Message(book: "신명기", chapter: 6, verse: 5, text: "너는 마음을 다하고 뜻을 다하고 힘을 다하여 네 하나님 여호와를 사랑하라"))
        messages.append(Message(book: "신명기", chapter: 6, verse: 6, text: "오늘 내가 네게 명하는 이 말씀을 너는 마음에 새기고"))
        messages.append(Message(book: "신명기", chapter: 6, verse: 7, text: "네 자녀에게 부지런히 가르치며 집에 앉았을 때에든지 길을 갈 때에든지 누워 있을 때에든지 일어날 때에든지 이 말씀을 강론할 것이며"))
        messages.append(Message(book: "신명기", chapter: 6, verse: 8, text: "너는 또 그것을 네 손목에 매어 기호를 삼으며 네 미간에 붙여 표로 삼고"))
        messages.append(Message(book: "신명기", chapter: 6, verse: 9, text: "또 네 집 문설주와 바깥 문에 기록할지니라"))
        courses.append(Course(name: "초급 2 단계 - 이스라엘아 들으라", desc: "신명기 6:4~9", messages: messages))
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
