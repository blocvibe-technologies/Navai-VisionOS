//
//  NewBoardVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 23/04/24.
//

import Foundation
import UIKit
import PencilKit
import Speech

class NewBoardVC: UIViewController, UIScrollViewDelegate, SFSpeechRecognizerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: UIView! // PKCanvasView!
    
    @IBOutlet weak var stopAndStartScrollingImg: UIImageView!
    @IBOutlet weak var stopAndStartScrolling: UIButton!
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var micImg: UIImageView!
    
    
    let canvasWidth : CGFloat = 1500//768
    let canvasOverscrollHight : CGFloat = 1000//500
    var imageView = UIImageView()
    var drawing = PKDrawing()
    
    var toolPicker = PKToolPicker.init()
    
    var isBool = false
    var isScrolling = true
    
    var observers: NSMutableSet! = NSMutableSet()
    
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    var micToggle = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopAndStartScrollingImg.image = UIImage(systemName: "stop.circle")
        //        canvasView.delegate = self
        //        canvasView.drawing = drawing
        //
        //        canvasView.isScrollEnabled = true
        //        canvasView.alwaysBounceVertical = true
        //        canvasView.alwaysBounceHorizontal = true
        scrollViewSetup()
        
        setupVoiceCommend()
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
    
    fileprivate func scrollViewSetup() {
        scrollView.layoutIfNeeded()
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 6.0
        
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: self.view.frame.width + 400, height: scrollView.frame.size.height + 400)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        hideCanvasView()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func stopAndStartScreenButnAction(_ sender: UIButton) {
        if isScrolling {
            scrollView.isScrollEnabled = false
            scrollView.bounces = false
            stopAndStartScrollingImg.image = UIImage(systemName: "restart.circle")
            isScrolling = false
        } else {
            scrollView.isScrollEnabled = true
            scrollView.bounces = true
            stopAndStartScrollingImg.image = UIImage(systemName: "stop.circle")
            isScrolling = true
        }
    }
    
    @IBAction func stickyNotesAction(_ sender: UIButton) {
        addStickyNote()
    }
    
    private func addStickyNote() {
        let stickerView = HBStickerView(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height/3, width: 200, height: 200))
        stickerView.viewControls.backgroundColor = .systemYellow
        stickerView.imageView.image = nil // UIImage(named: "shapes")
        
        let txtTF = stickerView.viewWithTag(40) as! UITextView
        txtTF.removeFromSuperview()
        
        canvasView.addSubview(stickerView)
    }
    
    
    @IBAction func doneAction(_ sender: UIButton) {
        done()
    }
    
    private func done() {
        let boardList = AllBoard(context: PersistentStorage.shared.context)
        boardList.id = UUID()
        if let vc = try? NSKeyedArchiver.archivedData(withRootObject: self.view!, requiringSecureCoding: false) {
            boardList.items = vc
            PersistentStorage.shared.saveContext()
            hideCanvasView()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func pencilAction(_ sender: UIButton) {
        if isBool == false {
            isBool = true
            // showCanvasView()
        } else {
            isBool = false
            // hideCanvasView()
        }
    }
    
    func showCanvasView() {
        //        toolPicker.setVisible(true, forFirstResponder: canvasView)
        //        toolPicker.addObserver(canvasView)
        //        canvasView.isOpaque = true
        //        canvasView.drawingPolicy = .anyInput
        //        canvasView.becomeFirstResponder()
    }
    
    func hideCanvasView() {
        //        toolPicker.setVisible(true, forFirstResponder: canvasView)
        //        toolPicker.addObserver(canvasView)
        //        canvasView.isOpaque = true
        //        canvasView.resignFirstResponder()
        //        canvasView.drawingPolicy = .default
        //        toolPicker.removeObserver(canvasView)
    }
    
    @IBAction func shapeAction(_ sender: UIButton) {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        microphoneButton.isEnabled = false
        micImg.tintColor = .black
        self.micToggle = true
        addShape()
    }
    
    private func addShape() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ShapesVC") as! ShapesVC
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func textAction(_ sender: UIButton) {
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
        canvasView.addSubview(stickerView)
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        
        if self.micToggle == true {
            DispatchQueue.main.async {
                self.startRecording()
            }
            self.micImg.tintColor = .red
            // microphoneButton.setTitle("Stop Recording", for: .normal)
            self.micToggle = false
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        microphoneButton.isEnabled = false
        micImg.tintColor = .black
        self.micToggle = true
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
}

extension NewBoardVC {
    
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
            scrollView.isScrollEnabled = false
            scrollView.bounces = false
            stopAndStartScrollingImg.image = UIImage(systemName: "restart.circle")
            
            isScrolling = false
        case "start":
            scrollView.isScrollEnabled = true
            scrollView.bounces = true
            stopAndStartScrollingImg.image = UIImage(systemName: "stop.circle")
            isScrolling = true
        default:
            break
        }
    }
    
}

extension NewBoardVC: PKToolPickerObserver {
    // Delegate Methods
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
    }
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        
    }
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        
    }
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        
    }
}

extension NewBoardVC: ShapesProtocal {
    
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
        
        canvasView.addSubview(stickerView)
    }
    
}

