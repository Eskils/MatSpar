
//
//  PickerView+TableView.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 11/03/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

@objc public protocol PickerViewDelegat {
    func pickerView(_ pickerView: Int, valdeCelle celle: String)
    @objc optional func pickerView(_ pickerView: Int, bildeForCelle index: Int) -> UIImage?
    
    @objc optional func pickerViewCelleVald(_ pickerView: Int, erCelleVald index: Int) -> ObjCBool
}

extension PickerView {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let antal = celler.count
        let tableHøgd = (radhøgd * CGFloat(celler.count)) + 8
        
        tableView.fjernConstraints(.height)
        tableView.heightAnchor.constraint(equalToConstant: tableHøgd).isActive = YES
        
        return antal
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as! PickerCelle
        
        celle.data = NSLocalizedString(celler[indexPath.row], comment: "")
        if let bilde = delegat?.pickerView?(0, bildeForCelle: indexPath.row) {
            celle.bildeView.image = bilde
            celle.bildeView.isHidden = NO
            celle.bildeView.tintColor = .tema
        }
        
        if let vald = delegat?.pickerViewCelleVald?(0, erCelleVald: indexPath.row) {
            if vald.boolValue {
                celle.valgt = YES
                
                celle.bildeView.tintColor = .white
                celle.label.textColor = .white
                celle.label.text = celle.data
                celle.cellemembran.backgroundColor = .tema
                celle.bildeView.image = #imageLiteral(resourceName: "round_check_black_36pt")
            }
        }
        
        return celle
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if valdCelle == celle { return }
        let data = celle.data
        
        celle.velg()
        valdCelle?.avvelg()
        
        self.valdCelle = celle
        self.delegat?.pickerView(self.tag-1, valdeCelle: data!)
        impactor.selectionChanged()
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if celle.valgt { return }
        celle.cellemembran.backgroundColor = .valgtCelle
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let celle = tableView.cellForRow(at: indexPath) as! PickerCelle
        if celle.valgt { return }
        celle.cellemembran.backgroundColor = .celle
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return radhøgd
    }
    
}
