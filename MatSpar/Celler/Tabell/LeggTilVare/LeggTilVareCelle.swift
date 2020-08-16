//
//  LeggTilVareCelle.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 06/08/2020.
//

import UIKit
import Verdensrommet
import Biilde

class LeggTilVareCelledata {
    typealias Varedata = SøkeforslagResultat.SøkeforslagInnhaldskjelde.SøkeforslagInnhald
    var vare : Varedata
    var action: Action?
    var bilde: UIImage?
    var knappikon: UIImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
    var erKnappAktiv: Bool = YES
    
    init(vare: Varedata, action: Action?, bilde: UIImage?=nil) {
        self.vare = vare
        self.action = action
        self.bilde = bilde
    }
}

class LeggTilVareCelle: UITableViewCell, BildeDelegat {
    
    @IBOutlet var bildeView: UIImageView!
    @IBOutlet var tittelLabel: UILabel!
    @IBOutlet var undertittelLabel: UILabel!
    @IBOutlet var addKnapp: IconKnapp!
    
    var celledata: LeggTilVareCelledata?
    fileprivate weak var bilde: UIImage? {
        didSet {
            celledata?.bilde = bilde
            bildeView.image = bilde
        }
    }
    var knappikon = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))! {
        didSet {
            celledata?.knappikon = knappikon
            addKnapp.icon = knappikon
        }
    }
    var knappAktiv: Bool = YES {
        didSet {
            celledata?.erKnappAktiv = knappAktiv
            if knappAktiv == NO {
                addKnapp.action = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        konfig()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        konfig()
    }
    
    func konfig() {
        guard let data = celledata else { return }
        
        if bilde == nil {
            let bilde = data.vare.bilde(siz: Int(bildeView.frame.height * 2))
            bilde.delegat = self
            bilde.last()
        }else {
            bildeView.image = data.bilde
        }
        
        tittelLabel.text = data.vare.title
        undertittelLabel.text = data.vare.vendor
        addKnapp.icon = data.knappikon
        if data.erKnappAktiv {
            addKnapp.action = data.action
        }
    }
    
    func bilde(avsluttaNedlastingAv bilde: UIImage) {
        self.bilde = bilde
    }
    
}
