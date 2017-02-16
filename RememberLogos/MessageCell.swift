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
    private var _message:Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.verseLabel.textColor = UIColor.clear
        self.messageLabel.textColor = UIColor.clear
    }
    
    func updateUI(message : Message) {
        verseLabel.text = "\(message.verse)"
        messageLabel.text = message.text
        currentIndex = message.text.startIndex
        _message = message
    }
    
    public func compareMessage(aResult: String!) -> Bool {
        var isVerseEnd = false
        
        if let message = _message, var currentIndex = self.currentIndex {
            
            var isChanged = false
            let text = message.text
            
            for ch in aResult.characters {
                
                // for Debug
                //print("voice: \(ch), message: \(message[currentIndex])")
                //print("messageIndex:\(currentIndex), message.endIndex: \(message.endIndex)")
                
                if(ch == text[currentIndex]) {
                    
                    isChanged = true
                    currentIndex = text.index(after: currentIndex)
                    
                    if currentIndex == text.index( before:text.endIndex) {
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
            mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.purple, range: discoveredRange)
            messageLabel.attributedText = mutableAttrStr
            
        }
        
        
    }

    
}
