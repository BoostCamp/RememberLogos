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
    
    var currentIndex: String.Index!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.verseLabel.textColor = UIColor.clear
        self.messageLabel.textColor = UIColor.clear
    }
    
    func updateUI(message : Message) {
        verseLabel.text = "\(message.verse)"
        messageLabel.text = message.text
        currentIndex = message.text.startIndex
    }
    
    public func compareMessage(aResult: String!) -> Bool {
        var isVerseEnd = false
        
        if let label = messageLabel, let message = label.text, var currentIndex = self.currentIndex {
            
            var isChanged = false
            
            for ch in aResult.characters {
                //print("voice: \(ch), message: \(message[messageIndex])")
                //                print("messageIndex:\(messageIndex), message.endIndex: \(message.endIndex)")
                if(ch == message[currentIndex]) {
                    
                    isChanged = true
                    currentIndex = message.index(after: currentIndex)
                    
                    if currentIndex >= message.endIndex {
                        isVerseEnd = true
                        break
                    }
                    
                }
            }
            
            if isChanged {
                self.currentIndex = currentIndex
                changeMessageLabel()
            }
        }
        
        return isVerseEnd
    }
    
    public func changeMessageLabel() {
        if let message = messageLabel.text, let attributedText = messageLabel.attributedText {
            
            let discoveredRange = NSMakeRange(message.distance(from: message.startIndex, to: message.startIndex),
                                              message.distance(from: message.startIndex, to: currentIndex))
            
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: discoveredRange)
            messageLabel.attributedText = mutableAttrStr
            
        }
        
        
    }

    
}
