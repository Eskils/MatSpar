//
//  Hjelpefunskjonar.swift
//  Verdensrommet
//
//  Created by Eskil Sviggum on 16/08/2020.
//

import Foundation

fileprivate let enkodar = JSONEncoder()
fileprivate let dekodar = JSONDecoder()

fileprivate func kod<T:Encodable>(_ verdi: T) -> Data {
    return try! enkodar.encode(verdi)
}

fileprivate func dekod<T:Decodable>(_ data: Data) -> T? {
    return try? dekodar.decode(T.self, from: data)
}

func lagre<T:Encodable>(_ verdi: T, nøkkel: String) {
    let data:Data = kod(verdi)
    ud.setValue(data, forKey: nøkkel)
}

func lastInn<T:Decodable>(nøkkel: String) -> T? {
    guard let data = ud.data(forKey: nøkkel) else { return nil }
    return dekod(data)
}
