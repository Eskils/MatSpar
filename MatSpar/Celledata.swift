//
//  Celledata.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import Tekstbilde
import Biilde
import Verdensrommet

struct Vare: Codable, Identifiable {
    var bilde: Bilde?
    var id: String = UUID().uuidString
    var tittel: String
    var eanKode: Int
    var kategori: Varekategori
    var antalTilbod: Int = 0
    
    func presbilde(fallbacsize: CGSize?=nil) -> UIImage {
        if let bilde = self.bilde?.uiImage {
            return bilde
        }else {
            let hue = (abs(tittel.hash) % 360)
            let bilde = UIImage.tekstBilde(med: tittel, size: CGSize(width: fallbacsize?.width ?? 256, height: fallbacsize?.height ?? 256), hue: hue)
            return bilde
        }
    }
}

struct Tilbod {
    var butikk: Butikk
    var originalpris: Float
    var tilbodspris: Float
    
    func faktiskPris() -> Float {
        return tilbodspris
    }
    
    func butikknavn() -> String {
        return butikk.beskrivelse.navn
    }
    
    func erTilbod() -> Bool {
        return originalpris != tilbodspris
    }
}
