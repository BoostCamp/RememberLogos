//
//  RecitationVC.swift
//  RememberLogos
//
//  Created by 김필환 on 2017. 2. 15..
//  Copyright © 2017년 김필환. All rights reserved.
//

import UIKit
import AVFoundation
import NaverSpeech

class RecitationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSKRecognizerDelegate {
    
    @IBOutlet weak var courseRangeLbl: UILabel!
    @IBOutlet weak var courseRangePb: UIProgressView!
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var voiceTextView: UITextView!
    @IBOutlet weak var recitaionButton: UIButton!
    
    var messages = [Message]()
    var course: Course!
    
    var currentMessage: Message!
    var currentVerse: Int!
    var messageIndex: String.Index!
    var updateTimer: Timer!
    
    // Naver Speech
    private let ClientID = "710CwSWlxkzXAQdSa6CV"
    private let nskSpeechRecognizer: NSKRecognizer
    
    required init?(coder aDecoder: NSCoder) {
        // NSKRecognizer를 초기화 하는데 필요한 NSKRecognizerConfiguration을 생성
        let configuration = NSKRecognizerConfiguration(clientID: ClientID)
        configuration?.canQuestionDetected = true
        self.nskSpeechRecognizer = NSKRecognizer(configuration: configuration)
        super.init(coder: aDecoder)
        self.nskSpeechRecognizer.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.voiceTextView.text = Constants.inactiveText
        
        self.navigationItem.title = course.name
        self.courseRangeLbl.text = course.desc
        
        self.currentVerse = 5
        self.currentMessage = course.messages[currentVerse]
        self.courseRangePb.setProgress(Float(currentVerse + 1) / Float(messages.count), animated: true)
        
        self.messageIndex = messages[self.currentVerse].text.startIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectMessage(row: currentVerse)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // delegate overriding - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            
            let message = messages[indexPath.row]
            cell.updateUI(message: message)
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    // delegate overriding - NSKRecognizerDelegate
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceiveError aError: Error!) {
        print("Error: \(aError)")
        self.recitaionButton.isEnabled = true
    }
    
    func recognizer(_ aRecognizer: NSKRecognizer!, didReceive aResult: NSKRecognizedResult!) {
        if let result = aResult.results.first as? String {
            print("Final result: \(result)")
            compareMessage(aResult: result)
            voiceTextView.text = result
        }
        
        stopRecognizer()
    }
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceivePartialResult aResult: String!) {
        print("Partial result: \(aResult)")
        self.voiceTextView.text = aResult
        compareMessage(aResult: aResult)
    }
    
    public func recognizerDidEnterReady(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Ready")
        self.updateTimer = Timer(timeInterval: 1, target: self, selector: #selector(RecitationVC.onReady), userInfo: nil, repeats: false)
        RunLoop.main.add(self.updateTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    public func recognizerDidDetectEndPoint(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: End point detected")
    }
    public func recognizerDidEnterInactive(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Inactive")
        self.voiceTextView.text = Constants.inactiveText
    }
    
    // viewCotroller func
    func compareMessage(aResult: String!) {
        if let selectedRow = messageTableView.indexPathForSelectedRow,
            let cell = messageTableView.cellForRow(at: selectedRow) as? MessageCell,
            let label = cell.messageLabel,
            let attributedText = label.attributedText {
            
            var isChanged = false, isVerseEnd = false
            let message = attributedText.string
            
            for ch in aResult.characters {
                if messageIndex >= message.endIndex {
                    isVerseEnd = true
                    break
                }
                
                if(ch == message[messageIndex]) {
                    messageIndex = message.index(after: messageIndex)
                    isChanged = true
                }
            }
            
            if isChanged {
                changeMessageLabel(message, attributedText, label)
            }
            
            if isVerseEnd {
                changeVerse()
            }
        }
    }
    
    private func changeMessageLabel(_ message: String,_ attributedText: NSAttributedString,_ detailTextLabel: UILabel) {
        
        let discoveredRange = NSMakeRange(message.distance(from: message.startIndex, to: message.startIndex),
                                          message.distance(from: message.startIndex, to: messageIndex))
        
        
        let shadowRange = NSMakeRange(message.distance(from: message.startIndex, to: messageIndex),
                                      message.distance(from: messageIndex, to: message.endIndex))
        
        
        let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
        
        mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: discoveredRange)
        mutableAttrStr.removeAttribute(NSShadowAttributeName, range: discoveredRange)
        
        
        mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.clear, range: shadowRange)
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.blue
        shadow.shadowBlurRadius = 10.0
        mutableAttrStr.addAttribute(NSShadowAttributeName, value: shadow, range: shadowRange)
        
        detailTextLabel.attributedText = mutableAttrStr
    }
    
    private func changeVerse() {
        
        print("currentVerse:\(currentVerse), messages.count: \(messages.count)")
        
        if currentVerse < messages.count - 1 {
            currentVerse = currentVerse + 1
            selectMessage(row: currentVerse)
            self.messageIndex = messages[currentVerse].text.startIndex
        } else {
            let alertController = UIAlertController(title: "암송을 완료하였습니다. 다음 코스를 진행하시겠습니까?", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "아니요", style: .default) { (action: UIAlertAction!) in
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
                }
            )
            alertController.addAction(UIAlertAction(title: "예", style: .default) { (action: UIAlertAction!) in
                alertController.dismiss(animated: true, completion: nil)
                }
            )
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func onReady() {
        self.voiceTextView.text = Constants.defaultVoiceText
        
        if let updateTimer = updateTimer {
            updateTimer.invalidate()
        }
    }
    
    func selectMessage(row : Int) {
        let numberOfRows = messageTableView.numberOfRows(inSection: 0)
        guard numberOfRows > row else {
            return
        }
        messageTableView.selectRow(at: IndexPath(row: row, section:0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
        self.courseRangePb.setProgress(Float(currentVerse + 1) / Float(messages.count), animated: true)
        shadowSelectedMessage()
    }
    
    func shadowSelectedMessage() {
        
        if let selectedRow = messageTableView.indexPathForSelectedRow,
            let cell = messageTableView.cellForRow(at: selectedRow) as? MessageCell,
            let label = cell.messageLabel,
            let attributedText = label.attributedText {
            
            let message = attributedText.string
            let shadowRange = NSMakeRange(message.distance(from: message.startIndex, to: message.startIndex),
                                          message.distance(from: message.startIndex, to: message.endIndex))
            
            
            let mutableAttrStr = NSMutableAttributedString(attributedString: attributedText)
            
            mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.clear, range: shadowRange)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.blue
            shadow.shadowBlurRadius = 10.0
            mutableAttrStr.addAttribute(NSShadowAttributeName, value: shadow, range: shadowRange)
            
            label.attributedText = mutableAttrStr
        }
    }
    
    func startRecognizer() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            nskSpeechRecognizer.start(with: .korean)
            self.voiceTextView.text = Constants.readyText
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
    }
    
    func stopRecognizer() {
        
        nskSpeechRecognizer.stop()
        
        recitaionButton.isEnabled = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
    }
    
    @IBAction func startRecitation(_ sender: UIButton) {
        recitaionButton.isEnabled =
            !recitaionButton.isEnabled
        
        startRecognizer()
    }
    
}
