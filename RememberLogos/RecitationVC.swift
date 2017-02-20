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
    var recitaionStartTimer: Timer!
    
    // Naver Speech
    private let ClientID = "710CwSWlxkzXAQdSa6CV"
    private let nskSpeechRecognizer: NSKRecognizer
    
    // controller init
    
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
        
        self.currentVerse = 0
        self.currentMessage = course.messages[currentVerse]
        self.courseRangePb.setProgress(Float(currentVerse) / Float(messages.count), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectMessage(row: currentVerse)
        // FOR TEST
//        showComplateCourse()
    }
    
    // delegate overriding - UITableViewDelegate
    
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
//            print("Final result: \(result)")
            voiceTextView.text = result
            compareMessage(aResult: result)
        }
        
        stopRecognizer()
    }
    
    var privResult: String!
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceivePartialResult aResult: String!) {

        if (privResult == nil) || (aResult != privResult) {

            self.voiceTextView.text = aResult
//            print("Partial result: \(aResult)")
//            compareMessage(aResult: aResult)
        }
        privResult = aResult
        
    }
    
    public func recognizerDidEnterReady(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Ready")
        self.recitaionStartTimer = Timer(timeInterval: 1, target: self, selector: #selector(RecitationVC.onReady), userInfo: nil, repeats: false)
        RunLoop.main.add(self.recitaionStartTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    public func recognizerDidDetectEndPoint(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: End point detected")
    }
    
    public func recognizerDidEnterInactive(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Inactive")
        self.voiceTextView.text = Constants.inactiveText
    }
    
    // recognizerStartTimer func
    
    func onReady() {
        self.voiceTextView.text = Constants.defaultVoiceText
        
        if let updateTimer = recitaionStartTimer {
            updateTimer.invalidate()
        }
    }
    
    // controller private func
    
    private func compareMessage(aResult: String!) {
        if let selectedRow = messageTableView.indexPathForSelectedRow,
            let cell = messageTableView.cellForRow(at: selectedRow) as? MessageCell {
            
            if cell.compareMessage(aResult: aResult) {
                changeVerse()
            }
        }
    }
    
    private func changeVerse() {
        
        print("currentVerse:\(currentVerse), messages.count: \(messages.count)")
        
        if currentVerse < messages.count - 1 {
            currentVerse = currentVerse + 1
            selectMessage(row: currentVerse)
        } else {
            showComplateCourse()
        }
        
    }
    
    private func showComplateCourse() {
    
        let alertController = UIAlertController(title: "암송을 완료하였습니다. 다음 코스를 진행하시겠습니까?", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "예", style: .default) { (action: UIAlertAction!) in
            self.nextCourse()
            }
        )
        
        alertController.addAction(UIAlertAction(title: "아니요", style: .default) { (action: UIAlertAction!) in
            
            if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                
            }
            }
        )
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func nextCourse() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: false)
            if let courseVC = navigationController.topViewController as? CourseVC {
                courseVC.performSegue(withIdentifier: "nextRecitation", sender: nil)
            }
            
        }
    }
    
    private func selectMessage(row : Int) {
        let numberOfRows = messageTableView.numberOfRows(inSection: 0)
        guard numberOfRows > row else {
            return
        }
        messageTableView.selectRow(at: IndexPath(row: row, section:0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
        self.courseRangePb.setProgress(Float(currentVerse) / Float(messages.count), animated: true)
    }
    
    private func startRecognizer() {
        
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
    
    private func stopRecognizer() {
        
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
