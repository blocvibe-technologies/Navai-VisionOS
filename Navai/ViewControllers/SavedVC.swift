//
//  SavedVC.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 30/04/24.
//

import UIKit
import CoreData

class SavedVC: UIViewController {
    weak var boardModel: BoardModel?
    
    var isBool = false
    var isScrolling = true
    
//    let toolPicker = PKToolPicker.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setup()
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
            stopRestartBtn.setImage(UIImage(systemName: "restart.circle"), for: .normal)
            isScrolling = false
        } else {
            scrollView.isScrollEnabled = true
            scrollView.bounces = true
            stopRestartBtn.setImage(UIImage(systemName: "stop.circle"), for: .normal)
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
        let stickerView = HBStickerView(frame: CGRect(x: self.view.frame.width/3, y: self.view.frame.height/3, width: 200, height: 200))
        stickerView.viewControls.backgroundColor = .systemYellow
        stickerView.imageView.image = nil // UIImage(named: "shapes")
        
        let txtTF = stickerView.viewWithTag(40) as! UITextView
        txtTF.removeFromSuperview()
        
        let canvasView = view.viewWithTag(10008)!
        canvasView.addSubview(stickerView)
    }
    
    @objc func addShapesBtnAction(_ sender : UIButton!){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ShapesVC") as! ShapesVC
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @objc func addTextBtnAction(_ sender : UIButton!){
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

