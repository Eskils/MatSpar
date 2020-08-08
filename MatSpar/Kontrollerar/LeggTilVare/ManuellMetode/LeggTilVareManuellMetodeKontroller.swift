//
//  LeggTilVareManuellMetodeKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import Verdensrommet

class LeggTilVareManuellMetodeKontroller: UIViewController, LeggTilVareMetodeKontroller {
    
    var delegat: LeggTilVareMetodeKontrollerDelegat?
    
    typealias Resultatinnhald = SøkeforslagResultat.SøkeforslagInnhaldskjelde.SøkeforslagInnhald
    
    
    @IBOutlet var søkeFelt: IconifisertTextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var statusLabel: UILabel!
    
    
    @IBOutlet var søkeBarTopConst: NSLayoutConstraint!
    
    var navBarHøgd: CGFloat!
    
    var celler: [Resultatinnhald] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var harLagtTilVarer: Bool = NO
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        søkeFelt.addTarget(self, action: #selector(søkEtterVare(sender:)), for: .editingDidEndOnExit)
        
        let celle = UINib(nibName: "LeggTilVareCelle", bundle: nil)
        tableView.register(celle, forCellReuseIdentifier: "celle")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 12
        
        søkeBarTopConst.constant = navBarHøgd + 24
        søkeFelt.backgroundColor = .felt
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if harLagtTilVarer {
            delegat?.brukarVilIkkjeLeggeTilFleireVarer()
        }
    }
    
    @objc func søkEtterVare(sender: IconifisertTextField) {
        let butikk = butikkManager.spar
        butikk.hentSøkeforslag(til: sender.text ?? "") { (resultat) in
            DispatchQueue.main.async {
                if (resultat != nil) && !(resultat!.isEmpty)  {
                    self.statusLabel.isHidden = YES
                    self.celler = resultat!.compactMap { $0.contentData._source }
                }else {
                    self.celler = []
                    self.statusLabel.isHidden = NO
                    self.statusLabel.text = "Fann ingen varer."
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        søkeFelt.endEditing(YES)
    }
    
    let haptikk = UINotificationFeedbackGenerator()
    @objc func leggTilVare(_ celle: Any) {
        guard let celle = celle as? LeggTilVareCelle else { fatalError() }
        
        celle.knappAktiv = NO
        celle.knappikon = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        
        haptikk.prepare()
        haptikk.notificationOccurred(.success)
        
        let vare = celle.celledata!.vare()
        harLagtTilVarer = YES
        delegat?.brukarLaTilVare(vare: vare, kanLeggeTilFleire: YES)
    }


}
