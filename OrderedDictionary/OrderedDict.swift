//
//  OrderedDict.swift
//  OrderedDictionary
//
//  Created by Eskil Sviggum on 15/08/2020.
//

import Foundation

public class OrderedDictionary<K: Hashable, T> {
    var array: [[DCVerdi<T, K>]]
    var size: Int
    public var count: Int = 0 {
        didSet{
            maxCount = max(count, maxCount)
        }
    }
    var maxCount: Int = 0
    
    public init(size: Int = 100) {
        self.array = []
        self.size = size
        for i in 0...size { array.append([]) }
    }
    
    public init(nøklar: [K], for verdiar:[T]) {
        self.array = []
        self.size = 100
        for i in 0...size { array.append([]) }
        
        leggTil(nøkklar: nøklar, for: verdiar)
    }
    
    public func leggTil(nøkklar: [K], for verdiar: [T]) {
        if nøkklar.count != verdiar.count { return }
        
        for i in 0..<nøkklar.count {
            let nøkkel = nøkklar[i]
            let verdi = verdiar[i]
            
            leggTil(key: nøkkel, value: verdi)
        }
    }
    
    public func leggTil(key: K, value:T) {
        let h = hash(value: key, grense: size)
        
        let nyVal = DCVerdi(verdi: value, key: key, indeks: count)
        
        var dcArr = array[h]
        for (i, el) in dcArr.enumerated() {
            if el.key == key {
                dcArr[i] = nyVal
                count += 1
                array[h] = dcArr
                return
            }
        }
        dcArr.append(nyVal)
        count += 1
        array[h] = dcArr
    }
    
    public func hent(_ key: K) -> T? {
        let h = hash(value: key, grense: size)
        
        var dcArr = array[h]
        for val in dcArr { if val.key == key { return val.verdi } }
        
        return nil
    }
    
    public func fjern(_ key: K) -> Any? {
        let h = hash(value: key, grense: size)
        
        var dcArr = array[h]
        for (i,val) in dcArr.enumerated() { if val.key == key { dcArr.remove(at: i); count -= 1; return val.verdi } }
        
        return nil
    }
    
    public func fjernAlle() {
        array.removeAll()
        for i in 0...size { array.append([]) }
    }
    
    public var nøklarOgVerdiar : [(key: K,value: T)] {
        var res: [(key: AnyHashable,value: T)?] = []
        for i in 0...maxCount { res.append(nil) }
        
        for arr in array {
            for val in arr {
                res[val.indeks] = (key: val.key,value: val.verdi)
            }
        }
        let cnt = res.count-1
        for (i, val) in res.reversed().enumerated() {
            if val == nil { res.remove(at: cnt - i) }
        }
        return res as! [(key: K,value: T)]
    }
    
    public var nøklar: [K] {
        var res : [K] = []
        for val in nøklarOgVerdiar {
            res.append(val.key)
        }
        return res
    }
    
    public var verdiar : [T] {
        var res : [T] = []
        for val in nøklarOgVerdiar {
            res.append(val.value)
        }
        return res
    }
    
    private func hash(value: K, grense: Int) -> Int {
        return abs(value.hashValue) % grense
    }
    
    public subscript(key: K) -> T? {
        get {
            return hent(key)
        }
        set(nyVerdi) {
            leggTil(key: key, value: nyVerdi!)
        }
    }
    
    public subscript(indeks: Int) -> (key: K, value: T) {
        get {
            let dct = nøklarOgVerdiar
            return dct[indeks]
        }
    }
}

