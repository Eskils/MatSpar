//
//  Varer+LeggTil.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

extension VarerKontroller: LeggTilVareDelegat {
    func laTilVarer(_ kontroller: LeggTilVareKontroller, varer: [Vare]) {
        kontroller.dismiss(animated: YES, completion: nil)
        
        /*for vare in varer {
            if vare.bilde?.uiImage == nil && vare.bilde?.getUrl() != nil {
                vare.bilde?.last()
                //Lagring.vare.lagre(verdi: <#T##Encodable#>, overstyrNøkkel: <#T##String?#>)
            }
        }*/
        self.varer += varer
        lagreVarer()
    }
    
    func avbrøytLeggTilVarer(_ kontroller: LeggTilVareKontroller) {
        kontroller.dismiss(animated: YES, completion: nil)
    }
    
}
