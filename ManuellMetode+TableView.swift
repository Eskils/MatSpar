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
        
        celle.celledata = celler[indexPath.row]
        celle.action = Action(target: self, selector: #selector(leggTilVare(_:)), sender: celle)
        
        return celle
    }
    
    
}
