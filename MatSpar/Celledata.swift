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

struct Vare: Codable, Identifiable, Equatable {
    
    static func == (lhs: Vare, rhs: Vare) -> Bool {
        return lhs.eanKode == rhs.eanKode
    }
    
    var bilde: Bilde?
    var id: String = UUID().uuidString
    var tittel: String
    var eanKode: Int
    var kategori: Varekategori
    var levrandør: String
    
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

struct HandlelisteVare: Codable, Identifiable, Equatable {
    
    static func == (lhs: HandlelisteVare, rhs: Vare) -> Bool {
        return lhs.eanKode == rhs.eanKode
    }
    
    static func == (lhs: HandlelisteVare, rhs: HandlelisteVare) -> Bool {
        return lhs.eanKode == rhs.eanKode
    }
    
    var bilde: Bilde?
    var id: String = UUID().uuidString
    var tittel: String
    var eanKode: Int
    var kategori: Varekategori
    var levrandør: String
    var butikk: Butikk
    var originalpris: Float
    var tilbodspris: Float
    var erKjøpt: Bool = NO
    
    init(bilde: Bilde?, tittel: String, ean: Int, kategori: Varekategori, levrandør: String, butikk: Butikk, pris: Float, tilbodspris: Float) {
        self.bilde = bilde
        self.tittel = tittel
        self.eanKode = ean
        self.kategori = kategori
        self.levrandør = levrandør
        self.butikk = butikk
        self.originalpris = pris
        self.tilbodspris = tilbodspris
    }
    
    init(vare: Vare, tilbod: Tilbod) {
        self.bilde = vare.bilde
        self.tittel = vare.tittel
        self.eanKode = vare.eanKode
        self.kategori = vare.kategori
        self.levrandør = vare.levrandør
        self.butikk = tilbod.butikk
        self.originalpris = tilbod.originalpris
        self.tilbodspris = tilbod.tilbodspris
    }
    
    func presbilde(fallbacsize: CGSize?=nil) -> UIImage {
        if let bilde = self.bilde?.uiImage {
            return bilde
        }else {
            let hue = (abs(tittel.hash) % 360)
            let bilde = UIImage.tekstBilde(med: tittel, size: CGSize(width: fallbacsize?.width ?? 256, height: fallbacsize?.height ?? 256), hue: hue)
            return bilde
        }
    }
    
    func faktiskPris() -> Float {
        return tilbodspris
    }
    
    func butikknavn() -> String {
        return butikk.beskrivelse.navn
    }
    
    func erTilbod() -> Bool {
        return originalpris != tilbodspris
    }
    
    func vare() -> Vare {
        return Vare(bilde: self.bilde, id: self.id, tittel: self.tittel, eanKode: self.eanKode, kategori: self.kategori, levrandør: self.levrandør)
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
