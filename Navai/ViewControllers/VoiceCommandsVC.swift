//
//  VoiceCommandsVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 21/05/24.
//

import UIKit
import AVFoundation


class VoiceCommandsVC: UIViewController {

    @IBOutlet weak var tbl: UITableView!
    
    var items = [
        "Add new Board",
        "Open Settings",
        "Stop Scrolling",
        "Start Scrolling",
        "Add Sticky",
        "Open shapes",
        "Add text",
        "Save note",
        "Add arrow Shape",
        "Add line Shape",
        "Add circle Shape",
        "Add triangle Shape",
        "Add angle Shape",
        "Add right Shape",
        "Add both Shape",
        "Add diamond Shape",
        "Add round Shape",
        "Add box Shape",
        "Add pentagon Shape",
        "Add star Shape",
        "Add square Shape",
        "Add roundsquare Shape"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.delegate = self
        tbl.dataSource = self
    }
    
    @IBAction func goBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}


extension VoiceCommandsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceCommandCell", for: indexPath) as! VoiceCommandCell
        cell.lbl.text = items[indexPath.row]
        return cell
    }
    
}

extension VoiceCommandsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let utterance = AVSpeechUtterance(string: items[indexPath.row])
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.1

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
}

