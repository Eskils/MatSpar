//
//  PickerCelle.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 11/03/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

public class PickerCelle: UITableViewCell {
    
    
    @IBOutlet var cellemembran: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var bildeView: UIImageView!
    
    public var data: String!
    
    public var valgt: Bool = NO
    public var valdBilde = #imageLiteral(resourceName: "round_check_black_36pt")
    final let animTid: Double = 0.25
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        konfig()
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        konfig()
        
        if valgt {
            velg()
        }
    }
    
    func konfig() {
        if valgt { return }
        self.label.text = data
        self.label.textColor = .tema
        //bildeView.tintColor = .white
    }
    
    public func velg() {
        self.valgt = YES
        bildeView.tintColor = .white
        UIView.transition(with: self.label, duration: animTid, options: .transitionCrossDissolve, animations: {
            self.label.textColor = .white
        }, completion: nil)
        UIView.animate(withDuration: animTid) {
            self.cellemembran.backgroundColor = .tema
            self.bildeView.image = self.valdBilde
        }
    }
    
    public func avvelg() {
        self.valgt = NO
        UIView.transition(with: self.label, duration: animTid, options: .transitionCrossDissolve, animations: {
            self.label.textColor = .tema
        }, completion: nil)
        UIView.animate(withDuration: animTid) {
            self.cellemembran.backgroundColor = .celle
            self.label.textColor = .tema
            self.bildeView.image = nil
        }
    }
    
}
