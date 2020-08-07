//
//  VareDetalj+TableView.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 07/08/2020.
//

import UIKit

extension VareDetaljKontroller: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let antal = tilbodar.count
        let cellehøgde = self.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: section))
        
        tableView.fjernConstraints(.height)
        let høgde = cellehøgde * CGFloat(antal)
        tableView.heightAnchor.constraint(equalToConstant: max(høgde, self.view.bounds.height  - imageView.bounds.height)).isActive = YES
        
        return antal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as! TilbodCelle
        
        celle.celledata = tilbodar[indexPath.row]
        
        return celle
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as? TilbodCelle else { return }
        celle.cellemembran.backgroundColor = .valgtCelle
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as? TilbodCelle else { return }
        celle.cellemembran.backgroundColor = .celle
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
