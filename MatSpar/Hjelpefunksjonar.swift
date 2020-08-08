//
//  Hjelpefunksjonar.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import AVFoundation
import Biilde
import Verdensrommet
import SkiilVarslingar

let NO = false
let YES = true

class ButikkManager {
    let spar = MatSparIVerdensrommet(butikk: .spar)
    let meny = MatSparIVerdensrommet(butikk: .meny)
    let joker = MatSparIVerdensrommet(butikk: .joker)
    
    fileprivate lazy var alleButikkar: [MatSparIVerdensrommet] = [spar, meny, joker]
    
    var count : Int {
        return alleButikkar.count
    }
    
    func alle(metode: (MatSparIVerdensrommet)->Void) {
        alleButikkar.forEach { butikk in
            metode(butikk)
        }
    }
}

func rad<T:BinaryFloatingPoint>(_ vinkel: T) -> T {
    return T(Double.pi / 180) * vinkel
}

extension UIColor {
    static var celle: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Cell")!
        }else {
            return .white
        }
    }
    
    static var valgtCelle: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "SelectedCell")!
        }else {
            return .lightGray
        }
    }
    
    static var felt: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Field")!
        }else {
            return .white
        }
    }
    
    static var app: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "AccentColor")!
        }else {
            return .green
        }
    }
    
    ///Gjer fargen gitt mykje mørkare. Oppgi eit desimaltal ∈[0,1]
    func darker(_ mengde: CGFloat) -> UIColor {
        var h:CGFloat = 0,
            s:CGFloat = 0,
            b:CGFloat = 0
        
        self.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        
        b -= min(abs(mengde),1)
        
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1)
        
    }
}

struct Action {
    var target: NSObject
    var selector: Selector
    var sender: Any? = nil
    
    func kjøyr() {
        if let sender = sender {
            target.perform(selector, with: sender)
        }else {
            target.perform(selector)
        }
    }
    
}

extension SøkeforslagResultat.SøkeforslagInnhaldskjelde.SøkeforslagInnhald {
    func vare() -> Vare {
        let kategori = Varekategori(rawValue: self.categoryName) ?? .Anna
        print(self.categoryName, kategori.rawValue)
        let vare = Vare(bilde: self.bilde(siz: 200), tittel: self.title, eanKode: Int(self.ean)!, kategori: kategori, antalTilbod: self.promotions.count)
        return vare
    }
}


extension UIDeviceOrientation {
    
    func toVideoOrientation() -> AVCaptureVideoOrientation {
        
        switch self {
            case .landscapeLeft:
                return .landscapeLeft
                
            case .landscapeRight:
                return .landscapeRight
                
            case .portrait:
                return .portrait
                
            case .portraitUpsideDown:
                return .portraitUpsideDown
            default:
                return .portrait
        }
    }
}

extension UIViewController {
    func varsling(tittel: String, melding: String, knapp: String?=nil, handler: @escaping ()->Void) {
        let alert = VarslingController(tittel: tittel, beskrivelse: melding, knapptekst: knapp ?? "Ok", avbrytbar: YES) {_ in
            handler()
        }
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: NO, completion: nil)
    }
    
    func prompt(tittel: String, melding: String, timeout: TimeInterval) {
        let alert = VarslingController(tittel: tittel, beskrivelse: melding, knapptekst: nil, avbrytbar: NO)
        alert.modalPresentationStyle = .overFullScreen
        self.present(alert, animated: NO) {
            Timer.scheduledTimer(withTimeInterval: timeout, repeats: NO) { (_) in
                alert.lukk(skalFullfore: NO)
            }
        }
    }
}
