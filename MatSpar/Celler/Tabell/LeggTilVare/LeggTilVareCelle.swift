//
//  LeggTilVareCelle.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 06/08/2020.
//

import UIKit
import Verdensrommet
import Biilde

class LeggTilVareCelle: UITableViewCell, BildeDelegat {
    
    @IBOutlet var bildeView: UIImageView!
    @IBOutlet var tittelLabel: UILabel!
    @IBOutlet var addKnapp: IconKnapp!
    
    var celledata: SøkeforslagResultat.SøkeforslagInnhaldskjelde.SøkeforslagInnhald?
    var action: Action?
    fileprivate weak var bilde: UIImage? {
        didSet {
            bildeView.image = bilde
        }
    }
    var knappikon = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))! {
        didSet {
            addKnapp.icon = knappikon
        }
    }
    var knappAktiv: Bool = YES {
        didSet {
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
            let bilde = data.bilde(siz: Int(bildeView.frame.height * 2))
            bilde.delegat = self
            bilde.last()
        }else {
            bildeView.image = bilde
        }
        
        tittelLabel.text = data.title
        addKnapp.icon = knappikon
        if knappAktiv {
            addKnapp.action = action
        }
    }
    
    func bilde(avsluttaNedlastingAv bilde: UIImage) {
        self.bilde = bilde
    }
    
}
