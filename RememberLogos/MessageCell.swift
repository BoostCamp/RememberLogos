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
    
    private var hiddenRanges:[NSRange] = [NSRange]()
    private var currentIndex: String.Index!
    private var _message:Message!
    
    private let messageColor = UIColor(red: 7.0/255.0, green: 171.0/255.0, blue: 195.0/255.0, alpha: 1)
    
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
        
        text.enumerateSubstrings(in: (text.startIndex..<text.endIndex), options: String.EnumerationOptions.byWords) { (substring: String?, substringRange  : Range<String.Index>, enclosingRange: Range<String.Index>, false) in
            if let substring = substring, !(substring.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
                    
                self.hiddenRanges.append(NSMakeRange(text.distance(from: text.startIndex, to: enclosingRange.lowerBound), text.distance(from: enclosingRange.lowerBound, to: enclosingRange.upperBound)))
                
            }
        }
        
        if let attributedText = messageLabel.attributedText {
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = 1.2
            
            mutableAttrStr.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            
            for range in hiddenRanges {
                mutableAttrStr.addAttribute(kTTTBackgroundFillColorAttributeName, value: globalTintColor, range: range)
                mutableAttrStr.addAttribute(kTTTBackgroundCornerRadiusAttributeName, value: 5.0, range: range)
            }
            
            messageLabel.attributedText = mutableAttrStr
        }
    }
    
    public func compareMessage(aResult: String!) -> [String: Any] {
        var isVerseEnd = false
        
        var correspondIndexes = [NSRange]()
        
        if let message = _message, var currentIndex = self.currentIndex {
            
            var isChanged = false
            let text = message.text
            
            for (index, ch) in aResult.characters.enumerated() {
                
                // for Debug
                print("voice: \(ch), message: \(text[currentIndex])")
                print("messageIndex:\(currentIndex), message.endIndex: \(text.endIndex)")
                while text[currentIndex] == " " {
                    currentIndex = text.index(after: currentIndex)
                }
                
                
                if ch == text[currentIndex] {
                    
                    isChanged = true
                    
                    if let lastRange = correspondIndexes.last, NSMaxRange(lastRange) == index{
                        print("last1 : \(lastRange)\n \(index)")
                        let _ = correspondIndexes.popLast()
                        correspondIndexes.append(NSMakeRange(lastRange.location, lastRange.length + 1))
                    } else {
                        print("last2 : \(index)\n")
                        correspondIndexes.append(NSMakeRange(index, 1))
                    }
                    
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
        
        return ["ranges": correspondIndexes, "isVerseEnd": isVerseEnd]
    }
    
    private func changeMessageLabel() {
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
