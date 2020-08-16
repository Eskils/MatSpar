//
//  DCVerdi.swift
//  OrderedDictionary
//
//  Created by Eskil Sviggum on 15/08/2020.
//

struct DCVerdi<T, U: Hashable> {
    let verdi: T
    let key: U
    let indeks: Int
}
