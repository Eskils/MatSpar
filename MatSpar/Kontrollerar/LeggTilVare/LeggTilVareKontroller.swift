//
//  LeggTilVareKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import AVFoundation

protocol LeggTilVareDelegat {
    func laTilVarer(_ kontroller: LeggTilVareKontroller, varer: [Vare])
    func avbrøytLeggTilVarer(_ kontroller: LeggTilVareKontroller)
}

protocol LeggTilVareMetodeKontroller: UIViewController {
    var navBarHøgd: CGFloat! {get set}
    var delegat: LeggTilVareMetodeKontrollerDelegat? {get set}
}

protocol LeggTilVareMetodeKontrollerDelegat {
    func brukarLaTilVare(vare: Vare, kanLeggeTilFleire: Bool)
    func brukarVilIkkjeLeggeTilFleireVarer()
}

fileprivate enum LeggTilMetode {
    case manuelt, strekkode
    
    mutating func inverter() {
        switch self {
            case .manuelt:
                self = .strekkode
            case .strekkode:
                self = .manuelt
        }
    }
    
    var ikon: UIImage {
        switch self {
            case .manuelt:
                return UIImage(systemName: "barcode.viewfinder", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))!
            case .strekkode:
                return UIImage(systemName: "pencil.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))!
        }
    }
    
    var kontroller: LeggTilVareMetodeKontroller {
        switch self {
            case .manuelt:
                return LeggTilVareManuellMetodeKontroller()
            case .strekkode:
                return LeggTilVareStrekkodeMetodeKontroller()
        }
    }
}

class LeggTilVareKontroller: UIViewController, LeggTilVareMetodeKontrollerDelegat {
    
    public var delegat: LeggTilVareDelegat?
    
    private var leggTilMetode: LeggTilMetode = .manuelt {
        didSet {
            metodeKnapp?.icon = leggTilMetode.ikon
            metodeKontroller = leggTilMetode.kontroller
        }
    }
    private var metodeKnapp: NavigationKnapp?
    private var ferdigKnapp: UIButton!
    private var metodeKontroller: LeggTilVareMetodeKontroller! {
        didSet {
            //Set opp variablar
            metodeKontroller.navBarHøgd = self.navigationController!.navigationBar.frame.height
            metodeKontroller.delegat = self
            
            self.view.viewWithTag(128)?.removeFromSuperview()
            
            let mView = metodeKontroller.view!
            mView.tag = 128
            mView.backgroundColor = .clear
            self.view.addSubview(mView)
            
            mView.translatesAutoresizingMaskIntoConstraints = NO
            mView.constrDekkView()
            
        }
    }
    
    private var transContainer: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if transContainer != nil { return }
        transContainer = self.transitionCoordinator?.containerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Legg til vare"
        
        if AVCaptureDevice.default(for: .video) != nil {
            //Dersom brukaren ikkje har eit kamera legg me ikkje til moglegheita for å scanne strekkodar.
            let ikon = UIImage(systemName: "barcode.viewfinder", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))!
            metodeKnapp = self.navigationController?.leggTilKnapp(ikon: ikon, action: Action(target: self, selector: #selector(bytMetode)), layoutHandler: .trailing)
            metodeKnapp!.skalRendreBakgrunn = NO
        }
        
        let _ = self.navigationController?.leggTilKnapp(tekst: "Avbryt", action: Action(target: self, selector: #selector(lukk)), layoutHandler: .leading)
        
        ferdigKnapp = self.navigationController?.leggTilKnapp(tekst: "Ferdig", action: Action(target: self, selector: #selector(lukk)), layoutHandler: .trailing)
        ferdigKnapp.isHidden = YES
        
        self.view.backgroundColor = .systemGroupedBackground
        
        leggTilMetode = .manuelt
    }
    
    @objc private func bytMetode() {
        if let strekkodeView = metodeKontroller as? LeggTilVareStrekkodeMetodeKontroller {
            strekkodeView.skalByteView()
        }
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: NO) { (_) in
            self.leggTilMetode.inverter()
        }
        
        let container = transContainer
        UIView.animate(withDuration: 0.3) {
            container?.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        } completion: {_ in
            UIView.animate(withDuration: 0.3) {
                container?.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc func lukk() {
        delegat?.avbrøytLeggTilVarer(self)
    }
    
    private var nyeVarer: [Vare] = []
    
    func brukarLaTilVare(vare: Vare, kanLeggeTilFleire: Bool) {
        nyeVarer.append(vare)
        if !kanLeggeTilFleire {
            delegat?.laTilVarer(self, varer: nyeVarer)
        }else {
            //Brukaren kan legge til fleire varer. Då syner me ein Ferdig-knapp.
            ferdigKnapp.alpha = 0
            ferdigKnapp.isHidden = NO
            
            UIView.animate(withDuration: 0.2) {
                self.ferdigKnapp.alpha = 1
                self.metodeKnapp?.alpha = 0
            } completion: { (_) in
                self.metodeKnapp?.isHidden = YES
            }

        }
    }
    
    func brukarVilIkkjeLeggeTilFleireVarer() {
        if nyeVarer.isEmpty { delegat?.avbrøytLeggTilVarer(self) }
        else { delegat?.laTilVarer(self, varer: nyeVarer) }
    }


}
