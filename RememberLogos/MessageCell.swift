//
//  MessageCell.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.verseLabel.textColor = UIColor.clear
        self.messageLabel.textColor = UIColor.clear
    }
    
    func updateUI(message : Message) {
        verseLabel.text = "\(message.verse)"
        messageLabel.text = message.text
    }
    
    func displayAnswerText() {
        
    }
    
}
