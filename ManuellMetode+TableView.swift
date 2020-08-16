//
//  ManuellMetode+TableView.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

extension LeggTilVareManuellMetodeKontroller: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celler.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celle = tableView.dequeueReusableCell(withIdentifier: "celle") as? LeggTilVareCelle else { fatalError() }
        
        let act = Action(target: self, selector: #selector(leggTilVare(_:)), sender: celle)
        celler[indexPath.row].action = act
        celle.celledata = celler[indexPath.row]
        
        return celle
    }
    
    
}
