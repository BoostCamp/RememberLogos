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

    private static let messageColor = UIColor(red: 7.0/255.0, green: 171.0/255.0, blue: 195.0/255.0, alpha: 1)
    
    @IBOutlet weak var verseLabel: UILabel!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    
    private var _hiddenRanges:[NSRange]!
    private var _currentIndex: String.Index!
    private var _message:Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        messageLabel.textColor = UIColor.clear
        
    }
    
    public func updateUI(message : Message) {

        let text = message.text
        
        verseLabel.text = "\(message.verse)"
        messageLabel.text = text
        _currentIndex = message.text.startIndex
        _hiddenRanges = [NSRange]()
        _message = message
        
        blankText(text)
        
    }
    
    private func blankText(_ text: String) {
        
        text.enumerateSubstrings(in: (text.startIndex..<text.endIndex), options: String.EnumerationOptions.byWords) { (substring: String?, substringRange  : Range<String.Index>, enclosingRange: Range<String.Index>, false) in

            if let substring = substring, substring.trimmingCharacters(in: CharacterSet.alphanumerics).isEmpty {
                
                self._hiddenRanges.append(NSMakeRange(text.distance(from: text.startIndex, to: substringRange.lowerBound), text.distance(from: substringRange.lowerBound, to: substringRange.upperBound)))
                
            }
        }
        
        if let attributedText = messageLabel.attributedText {
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = 1.2
            
            mutableAttrStr.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, text.characters.count))
            
            for range in _hiddenRanges {
                mutableAttrStr.addAttribute(kTTTBackgroundFillColorAttributeName, value: globalTintColor, range: range)
                mutableAttrStr.addAttribute(kTTTBackgroundCornerRadiusAttributeName, value: 5.0, range: range)
            }
            
            messageLabel.attributedText = mutableAttrStr
        }
    }
    
    public func compareMessage(aResult: String!) -> [String: Any] {
        var isVerseEnd = false
        var correctCount = 0
        var correspondIndexes = [NSRange]()
        
        if let message = _message, var currentIndex = self._currentIndex {
            
            var isChanged = false
            let text = message.text
            
            for (index, ch) in aResult.characters.enumerated() {
                
                // for Debug
//                print("voice: \(ch), message: \(text[currentIndex])")
//                print("messageIndex:\(currentIndex), message.endIndex: \(text.endIndex)")
                
                if ch == text[currentIndex] {
                    
                    isChanged = true
                    
                    if let lastRange = correspondIndexes.last, NSMaxRange(lastRange) == index{
                        let _ = correspondIndexes.popLast()
                        correspondIndexes.append(NSMakeRange(lastRange.location, lastRange.length + 1))
                    } else {
                        correspondIndexes.append(NSMakeRange(index, 1))
                    }
                    
                    currentIndex = text.index(after: currentIndex)
                    if currentIndex == text.endIndex {
                        isVerseEnd = true
                        break
                    }
                    
                }
                
                while text[currentIndex] == " " || text[currentIndex] == "," || text[currentIndex] == "."{
                    currentIndex = text.index(after: currentIndex)
                    if currentIndex == text.endIndex {
                        isVerseEnd = true
                        break
                    }
                }
                
            }
            
            if isChanged {
                correctCount = text.distance(from: self._currentIndex, to: currentIndex)
                self._currentIndex = currentIndex
                changeMessageLabel()
            }
        }
        
        return ["ranges": correspondIndexes, "isVerseEnd": isVerseEnd, "correctCount": correctCount]
    }
    
    private func changeMessageLabel() {
        
        if let message = messageLabel.text, let attributedText = messageLabel.attributedText {
            
            let discoveredRange = NSMakeRange(message.distance(from: message.startIndex, to: message.startIndex),
                                              message.distance(from: message.startIndex, to: _currentIndex))
            
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            mutableAttrStr.removeAttribute(kTTTBackgroundFillColorAttributeName, range: discoveredRange)
            mutableAttrStr.addAttribute(kCTForegroundColorAttributeName as String, value: MessageCell.messageColor, range: discoveredRange)
            
            messageLabel.attributedText = mutableAttrStr
        }
        
    }
    
    public func discoverAllText () {
        if let message = messageLabel.text, let attributedText = messageLabel.attributedText {
            
            let discoveredRange = NSMakeRange(message.distance(from: message.startIndex, to: message.startIndex),
                                              message.distance(from: message.startIndex, to: message.endIndex))
            
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            mutableAttrStr.removeAttribute(kTTTBackgroundFillColorAttributeName, range: discoveredRange)
            mutableAttrStr.addAttribute(kCTForegroundColorAttributeName as String, value: MessageCell.messageColor, range: discoveredRange)
            
            messageLabel.attributedText = mutableAttrStr
        }
    }

    
}
