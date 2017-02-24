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
import ABSteppedProgressBar
import BadgeSwift

class RecitationVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSKRecognizerDelegate, ABSteppedProgressBarDelegate {
    
    // UI
    @IBOutlet weak var courseProgressBar: ABSteppedProgressBar!
    @IBOutlet weak var scoreBadge: BadgeSwift!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var voiceTextView: UITextView!
    @IBOutlet weak var recitaionButton: UIButton!

    // Content Data
    var messages = [Message]()
    var course: Course!
    
    // User Data
    var currentVerse: Int!
    
    var recitationResults = [Message: RecitationResult]()
    var currentResult = RecitationResult()
    
    // Timer
    var recitaionStartTimer: Timer!
    var recitaionEndTimer: Timer!
    
    // Naver Speech
    private let ClientID = "710CwSWlxkzXAQdSa6CV"
    private let nskSpeechRecognizer: NSKRecognizer
    
    // Sound Effect
    var audioPlayer:AVAudioPlayer!
    var startSoundPath:String!
    var endSoundPath:String!
    var noResultSoundPath:String!
    var resultSoundPath:String!
    var endCourseSoundPath:String!

    
    // controller init
    required init?(coder aDecoder: NSCoder) {
        startSoundPath =  Bundle.main.path(forResource: "startRecitation", ofType: "wav")
        endSoundPath = Bundle.main.path(forResource: "endRecitation", ofType: "wav")
        noResultSoundPath = Bundle.main.path(forResource: "noResult", ofType: "wav")
        resultSoundPath = Bundle.main.path(forResource: "result", ofType: "wav")
        endCourseSoundPath = Bundle.main.path(forResource: "endCourse", ofType: "wav")
        
        // NSKRecognizer를 초기화 하는데 필요한 NSKRecognizerConfiguration을 생성
        let configuration = NSKRecognizerConfiguration(clientID: ClientID)
        configuration?.canQuestionDetected = true
        self.nskSpeechRecognizer = NSKRecognizer(configuration: configuration)
        super.init(coder: aDecoder)
        self.nskSpeechRecognizer.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init UI
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.messageTableView.estimatedRowHeight = 180
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        
        self.voiceTextView.text = Constants.inactiveText
        
        self.navigationItem.title = course.desc
        self.navigationItem.prompt = course.name
        
        if self.messages.count < 2 {
            courseProgressBar.isHidden = true
            let heightConstraint = self.courseProgressBar.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([heightConstraint])
        } else {
            courseProgressBar.delegate = self
            courseProgressBar.numberOfPoints = messages.count
            courseProgressBar.currentIndex = 0
        }
        
        // init Data
        self.currentVerse = 0
        
        createResultData()
        updateScoreBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectMessage(row: currentVerse)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        nskSpeechRecognizer.stop()
        
        UIView.performWithoutAnimation {
            self.navigationItem.prompt = nil
        }
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
            
            if indexPath.row < currentVerse {
                cell.discoverAllText()
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    // delegate overriding - ABSteppedProgressBarDelegate
    
    func progressBar(_ progressBar: ABSteppedProgressBar, canSelectItemAtIndex index: Int) -> Bool {
        
        if currentVerse < index {
            
            let targetMessage = messages[index]
            let skipActionSheetController = UIAlertController(title: "암송을 건너뛰기", message: "현재 암송중인 말씀을 외우지 않고 \(targetMessage.verse)절로 건너뛰길 원하십니까?\n 중간에 건너 뛴 말씀(들)은 점수가 0점이 됩니다.", preferredStyle: .actionSheet)
            
            skipActionSheetController.addAction(UIAlertAction(title: "예", style: .destructive) { (action: UIAlertAction!) in
                self.changeVerse(targetIndex:index)
                self.createResultData()
                self.updateScoreBadge()
            })
            
            skipActionSheetController.addAction(UIAlertAction(title: "아니요", style: .cancel) { (action: UIAlertAction!) in
                
                skipActionSheetController.dismiss(animated: true)
                
            })
            present(skipActionSheetController, animated: true, completion: nil)
            
        }
        
        return false
    }
    
    func progressBar(_ progressBar: ABSteppedProgressBar, textAtIndex index: Int) -> String {
        
        if messages.count > index {
            return "\(messages[index].verse)"
        } else {
            return "\(index)"
        }
    }
    
    // delegate overriding - NSKRecognizerDelegate
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceiveError aError: Error!) {
        print("Error: \(aError)")
        stopRecognizer()
    }
    
    func recognizer(_ aRecognizer: NSKRecognizer!, didReceive aResult: NSKRecognizedResult!) {
        if let result = aResult.results.first as? String {
// For Test
//            print("Final result: \(result)")
            
            if result.isEmpty {
                voiceTextView.text = Constants.noResultText
            } else {
                voiceTextView.text = result
                compareMessage(aResult: result)
            }
        } else {
            voiceTextView.text = Constants.noResultText
        }
        
    }
    
    var privResult: String!
    
    public func recognizer(_ aRecognizer: NSKRecognizer!, didReceivePartialResult aResult: String!) {

        if (privResult == nil) || (aResult != privResult) {

            self.voiceTextView.text = aResult
// For Performance
//            compareMessage(aResult: aResult)
        }
        
        privResult = aResult
        
    }
    
    public func recognizerDidEnterReady(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Ready")
        self.recitaionStartTimer = Timer(timeInterval: 1, target: self, selector: #selector(RecitationVC.onRecitationStart), userInfo: nil, repeats: false)
        RunLoop.main.add(self.recitaionStartTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    public func recognizerDidDetectEndPoint(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: End point detected")
    }
    
    public func recognizerDidEnterInactive(_ aRecognizer: NSKRecognizer!) {
        print("Event occurred: Inactive")
        
        stopRecognizer()
    }
    
    // Timer func
    
    func onRecitationStart() {
        playSound(path: startSoundPath)
        self.voiceTextView.text = Constants.defaultVoiceText
        
        if let updateTimer = recitaionStartTimer {
            updateTimer.invalidate()
        }
    }
    
    func onRecitationEnd() {
        self.voiceTextView.text = Constants.inactiveText
        self.voiceTextView.textColor = UIColor.darkGray
        self.recitaionButton.isEnabled = true
        
        if let endTimer = recitaionEndTimer {
            endTimer.invalidate()
        }
    }
    
    // controller private func
    
    private func compareMessage(aResult: String!) {
        if let selectedRow = messageTableView.indexPathForSelectedRow,
            let cell = messageTableView.cellForRow(at: selectedRow) as? MessageCell {
            
            let result = cell.compareMessage(aResult: aResult)
            
            if let correctCount = result["correctCount"] as? Int {
                currentResult.increseCorrect(correctCount)
                updateScoreBadge()
            }
            
            
            if let ranges = result["ranges"] as? [NSRange] {
            
                self.voiceTextView.textColor = UIColor.red
                
                if ranges.isEmpty {
                    playSound(path: noResultSoundPath)
                    currentResult.increseWrong()
                    updateScoreBadge()

                } else {
                    playSound(path: resultSoundPath)
                    
                    let mutableAttrStr = NSMutableAttributedString(attributedString: self.voiceTextView.attributedText)
                    
                    ranges.forEach({ (range :NSRange) in
                        mutableAttrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: range)
                    })
                    
                    self.voiceTextView.attributedText = mutableAttrStr
                    
                }
                
            }
            
            if (result["isVerseEnd"] as! Bool) {
                appendResultData()
                changeVerse(targetIndex: currentVerse + 1)
                createResultData()
            }
            
        }
    }
    
    private func changeVerse(targetIndex: Int) {
        // FOR TEST
//        print("currentVerse:\(currentVerse), targetIndex: \(targetIndex)")
        
        if targetIndex < messages.count {
            
            while(currentVerse < targetIndex) {
                if let cell = messageTableView.cellForRow(at:
                    IndexPath(row: currentVerse, section: 0)) as? MessageCell {
                    cell.discoverAllText()
                }
                currentVerse = currentVerse + 1
            }
            
            currentVerse = targetIndex
            courseProgressBar.currentIndex = targetIndex
            selectMessage(row: targetIndex)
            
        } else {
            // update result data.
            saveResultDataToController()
            showComplateCourse()
        }
        
    }
    
    
    private func showComplateCourse() {
    
        playSound(path: endCourseSoundPath)
        
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
        messageTableView.selectRow(at: IndexPath(row: row, section:0), animated: true, scrollPosition: UITableViewScrollPosition.bottom)
    }
    
    private func startRecognizer() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            nskSpeechRecognizer.start(with: .korean)
            self.voiceTextView.text = Constants.readyText
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
    }
    
    private func stopRecognizer() {
        self.recitaionEndTimer = Timer(timeInterval: 2, target: self, selector: #selector(RecitationVC.onRecitationEnd), userInfo: nil, repeats: false)
        RunLoop.main.add(self.recitaionEndTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        nskSpeechRecognizer.stop()
    }
    
    private func inactiveAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    private func playSound(path: String) {
        do {
            let url = URL(fileURLWithPath: path)
            try self.audioPlayer =  AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("play start sound error")
        }
    }
    
    private func updateScoreBadge() {
        let totalScore = recitationResults.reduce(0) { total, item in total + item.value.score } + currentResult.score
        self.scoreBadge.text = "\(totalScore)"
    }
    
    private func createResultData() {
        currentResult = RecitationResult()
    }
    
    private func appendResultData() {
        let currentMessage = messages[currentVerse]
        recitationResults.updateValue(currentResult, forKey: currentMessage)
    }
    
    private func saveResultDataToController() {

        let courseResult = ResultDataController.shared.getCourseResult(name: course.name)
        courseResult.updateOneSession(recitationResults)
        ResultDataController.shared.saveAll()
        
    }
    
    @IBAction func startRecitation(_ sender: UIButton) {
        recitaionButton.isEnabled =
            !recitaionButton.isEnabled
        
        startRecognizer()
    }
    
    @IBAction func showHintPopup(_ sender: UIBarButtonItem) {
        
        let hintActionSheetController = UIAlertController(title: "말씀 힌트!", message: "현재 진행중인 말씀이 기억나지 않으세요?\n 그렇다면 5초 동안 말씀을 보시겠습니까?", preferredStyle: .actionSheet)
        
        hintActionSheetController.addAction(UIAlertAction(title: "예", style: .destructive) { (action: UIAlertAction!) in
            
            let currentMsg = self.messages[self.currentVerse]
            let currentMsgVerse = currentMsg.book + " \(currentMsg.chapter):\(currentMsg.verse)"
            let currentMsgText = currentMsg.text
            
            let hintController = UIAlertController(title: currentMsgText, message: currentMsgVerse + " (5초)", preferredStyle: .alert)
            
            var remainningSec = 0
            let hintTimer = Timer(timeInterval: 1, repeats: true, block: { (timer) in
                remainningSec += 1
                
                hintController.message = currentMsgVerse + " (\(5 - remainningSec)초)"
                if(remainningSec >= 5) {
                    timer.invalidate()
                    hintController.dismiss(animated: true)
                }
                
            })
            
            hintController.addAction(UIAlertAction(title: "힌트 종료", style: .cancel, handler: { (UIAlertAction) in
                hintTimer.invalidate()
            }))
            self.present(hintController, animated: true) {
                
                RunLoop.main.add(hintTimer, forMode: RunLoopMode.defaultRunLoopMode)
            
            }
            
            self.currentResult.increseHint()
            self.updateScoreBadge()
            
            }
        )
        
        hintActionSheetController.addAction(UIAlertAction(title: "아니요", style: .cancel) { (action: UIAlertAction!) in
            
            hintActionSheetController.dismiss(animated: true)
            
            }
        )
        present(hintActionSheetController, animated: true, completion: nil)
    }
}
