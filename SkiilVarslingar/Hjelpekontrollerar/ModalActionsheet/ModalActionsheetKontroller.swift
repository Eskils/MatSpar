//
//  ModalActionsheetKontroller.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 03/04/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit
//import Motion

public struct ActionsheetAction {
    public let tekst: String
    public let bilde: UIImage?
    public let action: Action?
    
    public let erMeny: Bool
    public var menytekst: String? = nil
    /// Tittel, erVald, ikonn, action
    public var menyceller: [(String, Bool, UIImage, Action)]? = nil
    
}

public class ModalActionsheetKontroller: UIViewController, ActionsheetDelegat {
    
    @IBOutlet var bakgrunnsView: UIView!
    
    @IBOutlet var modalView: UIView!
    
    public var modalActions : ModalActionsheet!
    
    public  var actions: [ActionsheetAction] = []
    public var cellehøgd: Int? = nil
    
    public init(actions: [ActionsheetAction]) {
        self.actions = actions
        super.init(nibName: "ModalActionsheetKontroller", bundle: bundle)
    }
    
    public init() {
        super.init(nibName: "ModalActionsheetKontroller", bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sheet = ModalActionsheet(celler: actions)
        
        if let cellehøgd = self.cellehøgd {
            sheet.cellehøgd = cellehøgd
        }
        
        let actNav = UINavigationController(rootViewController: sheet)
        modalActions = (actNav.topViewController as! ModalActionsheet)
        
        self.addChild(actNav)
        
        self.modalView.addSubview(actNav.view)
        //setConstrsLikView(view: modalActions.view, [.top, .bottom, .leading, .trailing])
        actNav.view.translatesAutoresizingMaskIntoConstraints = NO
        actNav.view.constrDekkView()
        modalActions.delegat = self
        
        
        self.bakgrunnsView.alpha = 0
        
        UIApplication.shared.keyWindow!.bringSubviewToFront(bakgrunnsView)
        
        let sveipeRecog = UIPanGestureRecognizer(target: self, action: #selector(self.sveipeanim(sender:)))
        sveipeRecog.maximumNumberOfTouches = 1
        self.bakgrunnsView.addGestureRecognizer(sveipeRecog)
        
    }
    
    func maskerRadius() {
        
        let path = UIBezierPath(roundedRect: self.modalView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.modalView.bounds
        maskLayer.path = path.cgPath
        self.modalView.layer.mask = maskLayer
        
    }
    
    public func addAction(tittel: String, bilde: UIImage? = nil, target: NSObject?, selector: Selector?) {
        let actiondata = ActionsheetAction(tekst: tittel, bilde: bilde, action: Action(target: target ?? self, selector: selector ?? #selector(ingenting)), erMeny: NO)
        actions.append(actiondata)
    }
    
    public func addMeny(tittel: String, bilde: UIImage? = nil, celler: [(String, Bool, UIImage, Action)], valdTekst: String) {
        var actiondata = ActionsheetAction(tekst: tittel, bilde: bilde, action: nil, erMeny: YES)
        actiondata.menytekst = valdTekst
        actiondata.menyceller = celler
        actions.append(actiondata)
    }
    
    @objc func ingenting() {}
    
    public func actionSheet(celleVartVald indeks: Int) {
        let celle = actions[indeks]
        guard let act = celle.action else { return }
        
        close {
            (act.target).perform(act.selector, with: act.sender ?? celle)
        }
    }
    
    public func actionSheet(menyVartVald indeks: Int, iMeny menyIndeks: Int) {
        let celle = actions[indeks]
        let menycelle = celle.menyceller?[menyIndeks]
        guard let act = menycelle?.3 else { return }
        
        (act.target).perform(act.selector)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hgt = actions.count * (cellehøgd ?? 50) + 220
        self.modalView.heightAnchor.constraint(equalToConstant: CGFloat(hgt)).isActive = YES
        
        self.modalView.transform = CGAffineTransform(translationX: 0, y: 500)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.bakgrunnsView.alpha = 1
            self.modalView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        // Kan skape problem.
        maskerRadius()
        modalHeight = self.modalView.frame.height
        
    }

    public func close(completion: (()->Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.bakgrunnsView.alpha = 0
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 500)
        }) { (f) in
            self.dismiss(animated: NO, completion: completion)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let touch = touches.first!
        
        if touch.location(in: bakgrunnsView).y < self.view.frame.height - 50*3+20  {
            close{}
        }
    }
    
    var modalHeight: CGFloat = 100
    @objc func sveipeanim(sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 12, options: .curveEaseInOut, animations: {
                self.modalView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            return
        }
        
        let trans = sender.translation(in: bakgrunnsView)
        
        if trans.y >= 150 {
            UIView.animate(withDuration: 0.1, animations: {
                self.bakgrunnsView.alpha = 0
                self.modalView.transform = CGAffineTransform(translationX: 0, y: 200)
            }) { (f) in
                self.dismiss(animated: NO, completion: nil)
            }
            return
        }
        
        UIView.animate(withDuration: 0.1) {
            let stiffness = 1 - min((self.modalView.frame.minY / self.modalView.frame.minY + 200), 0.8)
            self.modalView.transform = self.modalActions.view.transform.translatedBy(x: 0, y: trans.y * stiffness)
        }
    }
    
    
}
