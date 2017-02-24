//
//  CourseCell.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 24..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit
import BadgeSwift

class CourseCell: UITableViewCell {

    @IBOutlet weak var resultCountBadge: BadgeSwift!
    @IBOutlet weak var totalScoreBadge: BadgeSwift!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
