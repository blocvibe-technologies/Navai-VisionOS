//
//  ShapesVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 24/04/24.
//

import UIKit
import Speech

protocol ShapesProtocal {
    func sendSelectedShape(name: String)
}

class ShapesVC: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var micImg: UIImageView!
    
    var items = ["1", "2" , "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
    
    var delegate: ShapesProtocal?
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    var micToggle = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    
}

extension ShapesVC {
    
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
        case "arrow":
            delegate?.sendSelectedShape(name: items[0])
            self.navigationController?.popViewController(animated: true)
        case "line":
            delegate?.sendSelectedShape(name: items[1])
            self.navigationController?.popViewController(animated: true)
        case "circle":
            delegate?.sendSelectedShape(name: items[2])
            self.navigationController?.popViewController(animated: true)
        case "triangle":
            delegate?.sendSelectedShape(name: items[3])
            self.navigationController?.popViewController(animated: true)
        case "angle":
            delegate?.sendSelectedShape(name: items[4])
            self.navigationController?.popViewController(animated: true)
        case "right":
            delegate?.sendSelectedShape(name: items[5])
            self.navigationController?.popViewController(animated: true)
        case "both":
            delegate?.sendSelectedShape(name: items[6])
            self.navigationController?.popViewController(animated: true)
        case "diamond":
            delegate?.sendSelectedShape(name: items[7])
            self.navigationController?.popViewController(animated: true)
        case "round":
            delegate?.sendSelectedShape(name: items[8])
            self.navigationController?.popViewController(animated: true)
        case "box":
            delegate?.sendSelectedShape(name: items[9])
            self.navigationController?.popViewController(animated: true)
        case "pentagon":
            delegate?.sendSelectedShape(name: items[10])
            self.navigationController?.popViewController(animated: true)
        case "star":
            delegate?.sendSelectedShape(name: items[11])
            self.navigationController?.popViewController(animated: true)
        case "square":
            delegate?.sendSelectedShape(name: items[12])
            self.navigationController?.popViewController(animated: true)
        case "roundsquare":
            delegate?.sendSelectedShape(name: items[13])
            self.navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
}

extension ShapesVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 210, height: 210)
    }
}

extension ShapesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapesCell", for: indexPath) as! ShapesCell
        
        cell.img.image = UIImage(named: items[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.sendSelectedShape(name: items[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}

