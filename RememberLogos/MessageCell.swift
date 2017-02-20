//
//  MessageCell.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit
import CoreText
import TTTAttributedLabel

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    
    private let messageColor = UIColor(red: 7.0/255.0, green: 171.0/255.0, blue: 195.0/255.0, alpha: 1)
    
    var currentIndex: String.Index!
    private var _message:Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        messageLabel.textColor = UIColor.clear
        
    }
    
    func updateUI(message : Message) {

        let text = message.text
        
        verseLabel.text = "\(message.verse)"
        messageLabel.text = text
        currentIndex = message.text.startIndex
        _message = message
        
        blankText(text)
        
    }
    
    private func blankText(_ text: String) {
        
        
        var ranges = [Range<String.Index>]()
        text.enumerateSubstrings(in: (text.startIndex..<text.endIndex), options: String.EnumerationOptions.byWords) { (substring: String?, substringRange  : Range<String.Index>, enclosingRange: Range<String.Index>, false) in
            if let substring = substring {
                if !substring.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    ranges.append(enclosingRange)
                }
                
            }
        }
        
        if let attributedText = messageLabel.attributedText {
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = 1.5
            
            mutableAttrStr.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            
            for range in ranges {
                let hiddenRange = NSMakeRange(text.distance(from: text.startIndex, to: range.lowerBound), text.distance(from: range.lowerBound, to: range.upperBound))
                
                
                mutableAttrStr.addAttribute(kTTTBackgroundFillColorAttributeName, value: globalTintColor, range: hiddenRange)
                mutableAttrStr.addAttribute(kTTTBackgroundCornerRadiusAttributeName, value: 5.0, range: hiddenRange)
            }
            
            messageLabel.attributedText = mutableAttrStr
        }
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
                    
                    if currentIndex == text.endIndex {
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
            
            mutableAttrStr.removeAttribute(kTTTBackgroundFillColorAttributeName, range: discoveredRange)
            mutableAttrStr.addAttribute(kCTForegroundColorAttributeName as String, value: messageColor, range: discoveredRange)
            
            messageLabel.attributedText = mutableAttrStr
        }
        
        
    }

    
}
