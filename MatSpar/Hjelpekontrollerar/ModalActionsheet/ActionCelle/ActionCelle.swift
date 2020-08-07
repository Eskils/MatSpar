//
//  ActionCelle.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 05/04/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

/// Befolk med „tekst”, „ikon“ og evt. „chevronTekst“
class ActionCelle: UITableViewCell {
    
    var tekst: String!
    var ikon: UIImage?
    
    var chevronTekst: String?
    
    @IBOutlet var Cellemembran: rundView!
    @IBOutlet var tekstLabel: UILabel!
    @IBOutlet var ikonBilde: UIImageView!
    
    @IBOutlet var chevronBilde: UIImageView!
    @IBOutlet var chevronLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func didMoveToSuperview() {
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        konfig()
    }
    
    func konfig() {
        
        tekstLabel.text = tekst
        ikonBilde.image = ikon
        
        tekstLabel.textColor = tema
        ikonBilde.tintColor = tema
        
        ikonBilde.layer.cornerRadius = 12
        
        if let chevron = chevronTekst {
            chevronLabel.text = chevron
        }else { chevronLabel.isHidden = YES; chevronBilde.isHidden = YES }
    }
    
}
