//
//  Lagring.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 06/08/2020.
//

import Foundation
import Verdensrommet

let ud = UserDefaults.standard
fileprivate let filendelse = ".json"
let hamstringsurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("MatSpar")

fileprivate let enkodar = JSONEncoder()
fileprivate let dekodar = JSONDecoder()

fileprivate func kod<T:Encodable>(_ verdi: T) -> Data {
    return try! enkodar.encode(verdi)
}

fileprivate func dekod<T:Decodable>(_ data: Data) -> T? {
    return try? dekodar.decode(T.self, from: data)
}

fileprivate func lagre<T:Encodable>(_ verdi: T, nøkkel: String) {
    let data:Data = kod(verdi)
    var filnavn:String! = ud.string(forKey: nøkkel)
    if filnavn == nil {
        filnavn = UUID().uuidString + filendelse
        ud.setValue(filnavn, forKey: nøkkel)
    }
    let url = hamstringsurl.appendingPathComponent(filnavn)
    try! data.write(to: url, options: .atomic)
}

fileprivate func lastInn<T:Decodable>(nøkkel: String) -> T? {
    let filnavn:String! = ud.string(forKey: nøkkel)
    if filnavn == nil { return nil }
    let url = hamstringsurl.appendingPathComponent(filnavn)
    guard let data = try? Data(contentsOf: url) else { return nil }
    return dekod(data)
}

fileprivate func slett(nøkkel: String) {
    let filnavn:String! = ud.string(forKey: nøkkel)
    if filnavn == nil { return }
    let url = hamstringsurl.appendingPathComponent(filnavn)
    do {
    try FileManager.default.removeItem(at: url)
    }catch { print("Kunne ikkje slette fil \(filnavn): ", error) }
}

enum Lagring: String {
    case varer
    case vare
    case butikkTokens
    
    var type: Any.Type {
        switch self {
            case .varer:
                return [String].self
            case .vare:
                return Vare.self
            case .butikkTokens:
                return [String].self
        }
    }
}

extension Lagring {
    func lagre<T:Encodable>(verdi: T, overstyrNøkkel nøkkel: String?=nil) {
        if T.self != self.type { fatalError("Feil type for nøkkelen, vart sendt til lagring") }
        MatSpar.lagre(verdi, nøkkel: nøkkel ?? self.rawValue)
    }
    
    func hent<T:Decodable>() -> T? {
        return lastInn(nøkkel: self.rawValue)
    }
    
    static func hent<T:Decodable>(medNøkkel nøkkel: String) -> T? {
        return lastInn(nøkkel: nøkkel)
    }
    
    func slett() {
        MatSpar.slett(nøkkel: self.rawValue)
    }
    
    static func slett(medNøkkel nøkkel: String) {
        MatSpar.slett(nøkkel: nøkkel)
    }
}
