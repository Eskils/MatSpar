//
//  VarslingController.swift
//  Kanindrakt
//
//  Created by Eskil Sviggum on 22/09/2019.
//  Copyright © 2019 SIGABRT. All rights reserved.
//

import UIKit

/// Syner ein varsling med Overskrift og Ingress. Du kan sjølv velje knapptekst, og om varslingan skal kunne avbrytast. fullføring vert kun kjøyrd om brukaren ikkje vel „avbryt”.
class VarslingController: UIViewController {
    
    @IBOutlet var Membran: UIView!
    @IBOutlet var Tittel: UILabel!
    @IBOutlet var Beskrivelse: UILabel!
    @IBOutlet var Knapp: UIButton!
    @IBOutlet var AvbrytKnapp: UIButton!
    
    @IBOutlet var actionKnappLeadingConstr: NSLayoutConstraint!
    
    @IBOutlet var avbrytTopConstr: NSLayoutConstraint!
    
    var tittel: String!
    var besk: String!
    var knapp: String!
    var avbrytbar: Bool!
    var fullføring: (() -> Void)?
    
    init(tittel: String, beskrivelse: String, knapptekst: String, avbrytbar: Bool = NO, fullføring: (() -> Void)? = nil) {
        super.init(nibName: "VarslingController", bundle: nil)
        
        self.tittel = tittel
        self.besk = beskrivelse
        self.knapp = knapptekst
        self.avbrytbar = avbrytbar
        self.fullføring = fullføring
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fraTrans = CGAffineTransform(scaleX: 0.55, y: 0.55)
        
        let anims = [Membran, Knapp, AvbrytKnapp]
        anims.forEach { av in
            av?.transform = fraTrans
            av?.alpha = 0
        }
        
        Knapp.addTarget(self, action: #selector(self.lukkMedFullforing), for: .touchUpInside)
        AvbrytKnapp.addTarget(self, action: #selector(self.lukkUtanFullforing), for: .touchUpInside)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        
        konfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            let anims = [Membran, Knapp, AvbrytKnapp]
        UIView.animate(withDuration: 0.25) {
            anims.forEach { av in
                av?.transform = CGAffineTransform.identity
                av?.alpha = 1
            }
            
        }
    }
    
    func konfig() {
        Membran.layer.cornerRadius = 12
        Knapp.layer.cornerRadius = 12
        AvbrytKnapp.layer.cornerRadius = 12
        
        self.Tittel.text = tittel
        self.Beskrivelse.text = besk
        if !self.avbrytbar {
            //Varslingen kan ikkje avbrytast.
            AvbrytKnapp.isHidden = YES
            actionKnappLeadingConstr.isActive = YES
            avbrytTopConstr.isActive = NO
        }else { AvbrytKnapp.setTitle(Localized("Avbryt"), for: .normal) }
        self.Knapp.setTitle(self.knapp, for: .normal)
    }
    
    @objc func lukkMedFullforing() { lukk(skalFullfore: YES) }
    @objc func lukkUtanFullforing() { lukk(skalFullfore: NO) }
    
    func lukk(skalFullfore: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            let anims = [self.Membran, self.Knapp, self.AvbrytKnapp]
            anims.forEach { av in
                av?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                av?.alpha = 0
            }
        }) { (b) in
            self.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: YES, completion: skalFullfore ? self.fullføring : nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        //Lukk self om den er avbrytbar og brukaren tappar utanfor viewen.
        if touch.view != Membran || touch.view != Knapp && avbrytbar {
            self.lukk(skalFullfore: NO)
        }
    }

}
