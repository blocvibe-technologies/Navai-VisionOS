//
//  HomeVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 23/04/24.
//

import UIKit
import CoreData
import Speech

class HomeVC: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var micImg: UIImageView!
    
    var boardModel = [BoardModel]()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    var isBool = false
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.audioEngine.stop()
        }
        recognitionRequest?.endAudio()
        microphoneButton.isEnabled = false
        micImg.tintColor = .white
        self.micToggle = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isBool = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let records = PersistentStorage.shared.fetchManagedObject(managedObject: AllBoard.self) {
            var results: [BoardModel] = []
            records.forEach({ (i) in
                results.append(i.convertToBoardItems())
            })
            boardModel = results.reversed()
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.boardModel.count == 0 {
                self.lbl.isHidden = false
            } else {
                self.lbl.isHidden = true
            }
        }
        
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
            self.micImg.tintColor = .white
            // microphoneButton.setTitle("Start Recording", for: .normal)
            self.micToggle = true
        }
        
        
        
        
        
        //        if audioEngine.isRunning {
        //                audioEngine.stop()
        //                recognitionRequest?.endAudio()
        //                microphoneButton.isEnabled = false
        //            micImg.tintColor = .white
        ////                microphoneButton.setTitle("Start Recording", for: .normal)
        //            } else {
        //                startRecording()
        //                micImg.tintColor = .red
        ////                microphoneButton.setTitle("Stop Recording", for: .normal)
        //            }
    }
    
}

extension HomeVC {
    
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
                
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: str)
                
                if self.isBool == false {
                    if (str.lowercased() == "new") {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "NewBoardVC") as! NewBoardVC
                        self.isBool = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
                
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
}

extension HomeVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width  / 3 - 20, height: 115)
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boardModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        cell.lbl.text = "Board \(indexPath.row + 1)"
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteButton(_:)), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        
        return cell
    }
    
    @objc func deleteButton(_ sender : UIButton!){
        if deleteBoard(id: boardModel[sender.tag].id) {
            boardModel.remove(at: sender.tag)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if self.boardModel.count == 0 {
                    self.lbl.isHidden = false
                } else {
                    self.lbl.isHidden = true
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SavedVC") as! SavedVC
        vc.boardModel = boardModel[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeVC {
    
    func getBoard(byIdentifier id: UUID) -> BoardModel? {
        let result = getCDBoard(byIdentifier: id)
        guard result != nil else {return nil}
        return result?.convertToBoardItems()
    }
    
    func deleteBoard(id: UUID) -> Bool {
        let data = getCDBoard(byIdentifier: id)
        guard data != nil else {return false}
        
        PersistentStorage.shared.context.delete(data!)
        PersistentStorage.shared.saveContext()
        return true
    }
    
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
