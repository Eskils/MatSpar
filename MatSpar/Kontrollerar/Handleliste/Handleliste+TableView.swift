//
//  Handleliste+TableView.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 10/08/2020.
//

import UIKit

extension HandlelisteKontroller: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = sorterteCeller.nøklar[section]
        print(sorterteCeller.nøklar)
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sorterteCeller.nøklar.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sorterteCeller.verdiar[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as? HandlelisteCelle else { fatalError() }
        
        let idx = sorterteCeller.verdiar[indexPath.section][indexPath.row]
        celle.celledata = celler[idx]
        
        return celle
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let celle = tableView.cellForRow(at: indexPath) as? HandlelisteCelle else { return nil }
        let hVare = celle.celledata!
        
        let action = UIContextualAction(style: .destructive, title: "Sjekk") { (action, view, b) in
            Lagring.slett(medNøkkel: hVare.id)
            self.celler = self.lastInnCeller()
            tableView.reloadData()
        }
        var img = UIImage(systemName: "checkmark.circle")!
        img = img.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        action.image = img
        action.backgroundColor = .app
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return YES
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            for subview in tableView.subviews {
                if NSStringFromClass(type(of: subview)) == "_UITableViewCellSwipeContainerView" {
                    for swipeContainerSubview in subview.subviews {
                        if NSStringFromClass(type(of: swipeContainerSubview)) == "UISwipeActionPullView" {
                            for case let button as UIButton in swipeContainerSubview.subviews {
                                let knapps = [button.superview, button.subviews.first]
                                knapps.forEach { knapp in
                                    knapp?.layer.cornerRadius = 12
                                    knapp?.frame.size.height -= 8
                                    knapp?.frame.origin.y += 8
                                }
                            }
                        }
                    }
                }
            }
        } else {
            for subview in tableView.subviews {
                if NSStringFromClass(type(of: subview)) == "UISwipeActionPullView" {
                    for case let button as UIButton in subview.subviews {
                        let knapps = [button.superview, button.subviews.first]
                        knapps.forEach { knapp in
                            knapp?.layer.cornerRadius = 12
                            knapp?.frame.size.height -= 8
                            knapp?.frame.origin.y += 8
                        }
                    }
                }
            }
        }
    }
}
