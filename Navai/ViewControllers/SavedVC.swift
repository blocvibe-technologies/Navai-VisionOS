//
//  SavedVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 30/04/24.
//

import UIKit
import CoreData
import Speech

class SavedVC: UIViewController, SFSpeechRecognizerDelegate {
    weak var boardModel: BoardModel?
    
    var isBool = false
    var isScrolling = true
    
//    let toolPicker = PKToolPicker.init()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    var micToggle = true
    
    var microphoneButton = UIButton()
    var micImg = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        setup()
        setupVoiceCommend()
        self.micImg.tintColor = .black
    }
    
    func setupVoiceCommend() {
        microphoneButton.isEnabled = false  //2
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        microphoneButton.isEnabled = false
        micImg.tintColor = .black
        self.micToggle = true
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUpView() {
        if let vv = self.boardModel?.items {
            if let decodedInfo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(vv) as? UIView {
                self.view.addSubview(decodedInfo)
            }
        }
    }
    
    func setup() {
        if let backBtn = self.view.viewWithTag(1) as? UIButton {
            backBtn.addTarget(self, action: #selector(self.goBackAction(_:)), for: .touchUpInside)
        }
        
        let stopRestartBtn = self.view.viewWithTag(10002) as! UIButton
        stopRestartBtn.addTarget(self, action: #selector(self.stopRestartAction(_:)), for: .touchUpInside)
        
//        let pencilBtn = self.view.viewWithTag(10003) as! UIButton
//        pencilBtn.addTarget(self, action: #selector(self.pencilBtnAction(_:)), for: .touchUpInside)
        
        let doneBtn = self.view.viewWithTag(10004) as! UIButton
        doneBtn.addTarget(self, action: #selector(self.doneBtnAction(_:)), for: .touchUpInside)
        
        let addStickyViewBtn = self.view.viewWithTag(10005) as! UIButton
        addStickyViewBtn.addTarget(self, action: #selector(self.addStickyViewBtnAction(_:)), for: .touchUpInside)
        
        let addShapesBtn = self.view.viewWithTag(10006) as! UIButton
        addShapesBtn.addTarget(self, action: #selector(self.addShapesBtnAction(_:)), for: .touchUpInside)
        
        let addTextBtn = self.view.viewWithTag(10007) as! UIButton
        addTextBtn.addTarget(self, action: #selector(self.addTextBtnAction(_:)), for: .touchUpInside)
        
        micImg = self.view.viewWithTag(100012) as! UIImageView
        microphoneButton = self.view.viewWithTag(100013) as! UIButton
        microphoneButton.addTarget(self, action: #selector(self.micBtnAction(_:)), for: .touchUpInside)
    }
    
    @objc func goBackAction(_ sender : UIButton!){
        //        hideCanvasView()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func stopRestartAction(_ sender : UIButton!){
        let scrollView = view.viewWithTag(10009) as! UIScrollView
        let stopRestartBtn = view.viewWithTag(10002) as! UIButton
        
        if isScrolling {
            scrollView.isScrollEnabled = false
            scrollView.bounces = false
            let playStopImg = self.view.viewWithTag(100011) as! UIImageView
            playStopImg.image = UIImage(systemName: "restart.circle")
            isScrolling = false
        } else {
            scrollView.isScrollEnabled = true
            scrollView.bounces = true
            let playStopImg = self.view.viewWithTag(100011) as! UIImageView
            playStopImg.image = UIImage(systemName: "stop.circle")
            isScrolling = true
        }
    }
    
    @objc func pencilBtnAction(_ sender : UIButton!){
        if isBool == false {
            isBool = true
            showCanvasView()
        } else {
            isBool = false
            hideCanvasView()
        }
    }
    
    func showCanvasView() {
//        let canvasView = view.viewWithTag(10008) as! PKCanvasView
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
//        toolPicker.addObserver(canvasView)
//        toolPicker.isRulerActive = false
//        canvasView.isOpaque = true
//        canvasView.becomeFirstResponder()
//        canvasView.drawingPolicy = .anyInput
    }
    
    func hideCanvasView() {
//        let canvasView = view.viewWithTag(10008) as! PKCanvasView
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
//        toolPicker.addObserver(canvasView)
//        toolPicker.isRulerActive = false
//        canvasView.isOpaque = true
//        canvasView.resignFirstResponder()
//        canvasView.drawingPolicy = .default
    }
    
    @objc func doneBtnAction(_ sender : UIButton!) {
        done()
    }
    
    
   private func done() {
        guard let id = boardModel?.id else {
            return
        }
        
        let info = getCDBoard(byIdentifier: id)
        
        guard info != nil else {return}
        
        if let vc = try? NSKeyedArchiver.archivedData(withRootObject: self.view!, requiringSecureCoding: false) {
            info?.items = vc
            PersistentStorage.shared.saveContext()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc func addStickyViewBtnAction(_ sender : UIButton!){
        addStickyNote()
    }
    
    private func addStickyNote() {
        let stickerView = HBStickerView(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height/3, width: 200, height: 200))
        stickerView.viewControls.backgroundColor = .systemYellow
        stickerView.imageView.image = nil // UIImage(named: "shapes")
        
        let txtTF = stickerView.viewWithTag(40) as! UITextView
        txtTF.removeFromSuperview()
        
        let canvasView = view.viewWithTag(10008)!
        canvasView.addSubview(stickerView)
    }
    
    @objc func addShapesBtnAction(_ sender : UIButton!){
        addShape()
    }
    
    private  func addShape() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ShapesVC") as! ShapesVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addTextBtnAction(_ sender : UIButton!){
        addText()
    }
    
    private func addText() {
        let stickerView = HBStickerView(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height/3, width: 200, height: 200))
        stickerView.viewControls.backgroundColor = .clear
        stickerView.viewControls.borderWidth = 0
        stickerView.imageView.isHidden = true
        stickerView.btnTopBoundry.isHidden = true
        stickerView.btnBottomBoundry.isHidden = true
        stickerView.btnRightBoundry.isHidden = true
        stickerView.btnLeftBoundry.isHidden = true
        stickerView.btnRotate.isHidden = true
        let canvasView = view.viewWithTag(10008)!
        canvasView.addSubview(stickerView)
    }
    
    
    @objc func micBtnAction(_ sender : UIButton!) {
        
        if self.micToggle == true {
            DispatchQueue.main.async {
                self.startRecording()
            }
            self.micImg.tintColor = .red
            // microphoneButton.setTitle("Stop Recording", for: .normal)
            self.micToggle = false
            
//            let alert = UIAlertController(title: "Voice Commend", message: "Say add arrow!", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            DispatchQueue.main.async {
                self.audioEngine.stop()
            }
            self.recognitionRequest?.endAudio()
            self.microphoneButton.isEnabled = false
            self.micImg.tintColor = .black
            // microphoneButton.setTitle("Start Recording", for: .normal)
            self.micToggle = true
        }
        
        //        if audioEngine.isRunning {
        //                audioEngine.stop()
        //                recognitionRequest?.endAudio()
        //                microphoneButton.isEnabled = false
        //            micImg.tintColor = .black
        ////                microphoneButton.setTitle("Start Recording", for: .normal)
        //            } else {
        //                startRecording()
        //                micImg.tintColor = .red
        ////                microphoneButton.setTitle("Stop Recording", for: .normal)
        //            }
    }
    
}

extension SavedVC: ShapesProtocal {
    
    func sendSelectedShape(name: String) {
        let stickerView = HBStickerView(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height/3, width: 200, height: 200))
        stickerView.viewControls.backgroundColor = .clear
        stickerView.viewControls.borderWidth = 0
        stickerView.imageView.image = UIImage(named: name)
        stickerView.btnTopBoundry.isHidden = true
        stickerView.btnBottomBoundry.isHidden = true
        stickerView.btnRightBoundry.isHidden = true
        stickerView.btnLeftBoundry.isHidden = true
        
        
        let txtTF = stickerView.viewWithTag(40) as! UITextView
        txtTF.removeFromSuperview()
        
        let canvasView = view.viewWithTag(10008)!
        canvasView.addSubview(stickerView)
    }
    
}

extension SavedVC {
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        //
        //        guard   else {
        //            fatalError("Audio engine has no input node")
        //        }
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            
            var isFinal = false
            
            if result != nil {
                
                let data = result?.bestTranscription.formattedString.last
                isFinal = (result?.isFinal)!
                
                //                print(data)
                guard let str = result?.transcriptions.last?.segments.last?.substring else {
                    return
                }
                
                self.autoNext(data: str)
                
                //                if self.isBool == false {
                //                    if (str.lowercased() == "new") {
                //
                //                    }
                //                }
                
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        // textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    
    private func autoNext(data: String) {
        switch data.lowercased() {
        case "sticky":
            addStickyNote()
        case "text":
            addText()
        case "shape":
            addShape()
        case "save":
            done()
        case "stop":
            let scrollView = view.viewWithTag(10009) as! UIScrollView
            
            scrollView.isScrollEnabled = false
            scrollView.bounces = false
            let playStopImg = self.view.viewWithTag(100011) as! UIImageView
            playStopImg.image = UIImage(systemName: "restart.circle")
            isScrolling = false
            
        case "start":
            let scrollView = view.viewWithTag(10009) as! UIScrollView
            
            scrollView.isScrollEnabled = true
            scrollView.bounces = true
            let playStopImg = self.view.viewWithTag(100011) as! UIImageView
            playStopImg.image = UIImage(systemName: "stop.circle")
            isScrolling = true
        default:
            break
        }
    }
    
}

extension SavedVC {
    
    func getCDBoard(byIdentifier id: UUID) -> AllBoard? {
        let fetchRequest = NSFetchRequest<AllBoard>(entityName: "AllBoard")
        let predicate = NSPredicate(format: "id==%@", id as CVarArg)
        
        fetchRequest.predicate = predicate
        do {
            let result = try PersistentStorage.shared.context.fetch(fetchRequest).first
            
            guard result != nil else {return nil}
            
            return result
            
        } catch let error {
            debugPrint(error)
        }
        
        return nil
    }
}

