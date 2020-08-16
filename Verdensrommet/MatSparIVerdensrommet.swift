//
//  MatSparIVerdensrommet.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 05/08/2020.
//

import Foundation

let ud = UserDefaults.standard

struct LagringSessionToken: Codable {
    private var stToken: String
    var exp: TimeInterval
    
    init(token: String, utløpsstamp: TimeInterval) {
        self.stToken = token
        self.exp = utløpsstamp
    }
    
    var token: String? {
        let stamp = Date().timeIntervalSince1970
        if self.exp > stamp {
            return stToken
        }else {
            return nil
        }
    }
}

struct VerdensromMission {
    let url: URL
    let completion: DataCompletionHandler
    var requestConfig: RequestConfigHandler?=nil
    
    init(url: URL, completion: @escaping DataCompletionHandler, requestConfig: RequestConfigHandler?=nil) {
        self.url = url
        self.completion = completion
        self.requestConfig = requestConfig
    }
    
    fileprivate func kjøyr(verdensrom: MatSparIVerdensrommet) {
        verdensrom.faktiskUtførMission(mission: self)
    }
}

public typealias RequestConfigHandler = ((inout URLRequest)->Void)
public typealias DataCompletionHandler = (Data?)->Void

public class MatSparIVerdensrommet {
    
    public var butikk: Butikk
    var sessionToken:String?
    var sessionExpire: TimeInterval?
    
    ///Om det kom ein feil frå ein query vil den bli lagra her, mens metoden returnerar `nil`. Dersom queryen gjekk fint vil denne bli satt til `nil`.
    public var feilmelding: Error?
    
    public init(butikk: Butikk) {
        self.butikk = butikk
        hentLagraToken()
    }
    
    /// Hentar inn lagra token for butikken, om ingen er lagra, eller tokenet er utløpt hender det ingenting.
    private func hentLagraToken() {
        let lagra: LagringSessionToken? = lastInn(nøkkel: self.butikk.rawValue + "Token")
        self.sessionToken = lagra?.token
        print(butikk.rawValue, lagra?.token)
        self.sessionExpire = lagra?.exp
    }
    
    /// Lagrar `self.sessionToken` som `LagringSessionToken` i UD. Kan hentast inn igjen med metoden `hentLagraToken`
    private func lagreToken() {
        guard let token = self.sessionToken,
              let exp = self.sessionExpire
        else { return }
        
        let lagring = LagringSessionToken(token: token, utløpsstamp: exp)
        lagre(lagring, nøkkel: self.butikk.rawValue + "Token")
    }
    
    var missions: [VerdensromMission] = []
    var utførerMission: Bool = false
    
    public func hentSøkeforslag(til søkeord: String, completion: @escaping ([SøkeforslagResultat]?)->Void) {
        let konfig = AutosuggestForespørselkonfigurasjon(søk: søkeord, typar: .varer, antal: 14, sorterEtterPopularitet: true)
        let url = butikk.autosuggestUrl(konfigurasjon: konfig)
        let reqConfig: RequestConfigHandler = { (req) in
            req.addValue(self.sessionToken ?? "0", forHTTPHeaderField: "x-csrf-token")
        }
        let fullføring:DataCompletionHandler = { data in
            guard let data = data
            else { completion(nil); return }
            
            do {
                let søkeforslag = try JSONDecoder().decode(AutosuggestResultat.self, from: data)
                
                let res = søkeforslag.products.hits
                if res == nil { self.feilmelding = dataFeil.ingenTreff }
                completion(res)
            }catch {
                print("hentVare Dekodingsfeil: \(error)")
                self.feilmelding = dataFeil.DekodingsFeil
                completion(nil)
            }
        }
        
        if sessionToken == nil || sessionExpire ?? 0 >= Date().timeIntervalSince1970 { hentToken() }
        let mission = VerdensromMission(url: url, completion: fullføring, requestConfig: reqConfig)
        leggTilMission(mission)
    }
    
    public func hentVare(fråStrekkode søkeord: String, completion: @escaping (SøkeforslagResultat?)->Void) {
        let konfig = AutosuggestForespørselkonfigurasjon(søk: søkeord, typar: .varer, antal: 14, sorterEtterPopularitet: true)
        let url = butikk.autosuggestUrl(konfigurasjon: konfig)
        let reqConfig: RequestConfigHandler = { (req) in
            print("SESSIONToken: ", self.sessionToken)
            req.addValue(self.sessionToken ?? "0", forHTTPHeaderField: "x-csrf-token")
        }
        let fullføring:DataCompletionHandler = { data in
            guard let data = data
            else { completion(nil); return }
            
            do {
                let søkeforslag = try JSONDecoder().decode(AutosuggestResultat.self, from: data)
                    
                let res = søkeforslag.products.hits.first
                if res == nil { self.feilmelding = dataFeil.ingenTreff }
                completion(res)
            }catch {
                print("hentVare Dekodingsfeil: \(error)")
                self.feilmelding = dataFeil.DekodingsFeil
                completion(nil)
            }
        }
        
        if sessionToken == nil || sessionExpire ?? 0 >= Date().timeIntervalSince1970 { hentToken() }
        let mission = VerdensromMission(url: url, completion: fullføring, requestConfig: reqConfig)
        leggTilMission(mission)
    }
    
    private func hentToken(completion: (()->Void)?=nil) {
        let url = butikk.beskrivelse.nettbutikkUrl
        let fullføring: DataCompletionHandler = { (_) in
            let kjeksar = HTTPCookieStorage.shared.cookies(for: url)
            kjeksar?.forEach { kjeks in
                if kjeks.name == "_app_token_" {
                    self.sessionToken = kjeks.value
                    self.sessionExpire = Date().addingTimeInterval((15) * 60).timeIntervalSince1970
                    self.lagreToken()
                }
            }
            
            completion?()
        }
        let mission = VerdensromMission(url: url, completion: fullføring)
        leggTilMission(mission)
    }
    
    fileprivate func leggTilMission(_ mission: VerdensromMission) {
        missions.append(mission)
        if !utførerMission { faktiskUtførMission(mission: mission) }
    }
    
    fileprivate func hentNesteMission() -> VerdensromMission? {
        if missions.isEmpty { utførerMission = false; return nil }
        return missions.removeFirst()
    }
    
    fileprivate func faktiskUtførMission(mission: VerdensromMission) {
        utførerMission = true
        JSON.hentJSONDekodbar(frå: mission.url, requestkonfig: mission.requestConfig) { [self] (resultat) in
            switch resultat {
                case .success(let data):
                    feilmelding = nil
                    mission.completion(data)
                case .failure(let error):
                    feilmelding = error
                    mission.completion(nil)
            }
            hentNesteMission()?.kjøyr(verdensrom: self)
        }
    }
}


