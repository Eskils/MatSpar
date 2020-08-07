//
//  JSON.swift
//  Verdensrommet
//
//  Created by Eskil Sviggum on 05/08/2020.
//

import Foundation

public enum dataFeil: String, Error {
    case UgyldigResopns
    case UgyldigData
    case DekodingsFeil
    case TjenarFeil
    case UrlFeil
    case DataformatFeil = "Fann ingen data."
    case HttpDatafeil
    case ingenTreff
}

class JSON: NSObject, URLSessionDelegate {
    
    typealias Fullføring = (Result<Dictionary<AnyHashable, Any>, Error>) -> Void
    typealias DekodbarFullføring = (Result<Data, Error>) -> Void
    
    static func hentJSON(frå url: URL, metode: String? = "GET", requestkonfig: ((inout URLRequest)->Void)?=nil, completion: @escaping Fullføring) {
        var forespørsel = URLRequest(url: url)
        
        forespørsel.httpMethod = metode
        requestkonfig?(&forespørsel)
        
        let økt = URLSession(configuration: URLSessionConfiguration.default)
        økt.dataTask(with: forespørsel) { (data, respons, feil) in
            JSON.handterSvar(data, respons, feil, completion: completion)
        }.resume()
    }
    
    static func hentJSONDekodbar(frå url: URL, metode: String? = "GET", requestkonfig: ((inout URLRequest)->Void)?=nil, completion: @escaping DekodbarFullføring) {
        var forespørsel = URLRequest(url: url)
        
        forespørsel.httpMethod = metode
        requestkonfig?(&forespørsel)
        
        let økt = URLSession(configuration: URLSessionConfiguration.default)
        økt.dataTask(with: forespørsel) { (data, respons, feil) in
            JSON.handterSvarDekodbar(data, respons, feil, completion: completion)
        }.resume()
    }
    
    static func hentArrayJSON(frå url: URL, completion: @escaping (Result<[[String:AnyHashable]], Error>) -> Void) {
        let forespørsel = URLRequest(url: url)
        
        let økt = URLSession(configuration: URLSessionConfiguration.default)
        økt.dataTask(with: forespørsel) { (data, respons, feil) in
            if feil != nil {
                completion(.failure(feil!))
            }
            
            guard let httpRespons = respons as? HTTPURLResponse else {
                completion(.failure(dataFeil.UgyldigResopns))
                return
            }
            if 200 ... 299 ~= httpRespons.statusCode {
                if let data = data {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String:AnyHashable]] {
                            completion(.success(dict))
                        } else {
                            print("Feilmeldingskode: \(httpRespons.statusCode)")
                            completion(.failure(dataFeil.DataformatFeil))
                        }
                    } catch {
                        print("Feilmeldingskode: \(httpRespons.statusCode)")
                        completion(.failure(dataFeil.DekodingsFeil))
                    }
                    
                } else {
                    print("Feilmeldingskode: \(httpRespons.statusCode)")
                    completion(.failure(dataFeil.UgyldigData))
                }
            }else {
                print("Feilmeldingskode: \(httpRespons.statusCode)")
                completion(.failure(dataFeil.TjenarFeil))
            }
        }.resume()
    }
    
    func hentJSON(med data: Data, frå url: URL, completion: @escaping (Result<[[String:AnyHashable]], Error>) -> Void) {
        var forespørsel = URLRequest(url: url)
        
        forespørsel.httpMethod = "POST"
        forespørsel.httpBody = data
        
        let config = URLSessionConfiguration.default
        
        let økt = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        økt.dataTask(with: forespørsel) { (data, respons, feil) in
            if feil != nil {
                completion(.failure(feil!))
            }
            
            guard let httpRespons = respons as? HTTPURLResponse else {
                completion(.failure(dataFeil.UgyldigResopns))
                return
            }
            if 200 ... 299 ~= httpRespons.statusCode {
                if let data = data {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String:AnyHashable]] {
                            completion(.success(dict))
                        } else {
                            print("Feilmeldingskode: \(httpRespons.statusCode)")
                            completion(.failure(dataFeil.DataformatFeil))
                        }
                    } catch {
                        print("Feilmeldingskode: \(httpRespons.statusCode)")
                        completion(.failure(dataFeil.DekodingsFeil))
                    }
                    
                } else {
                    print("Feilmeldingskode: \(httpRespons.statusCode)")
                    completion(.failure(dataFeil.UgyldigData))
                }
            }else {
                print("Feilmeldingskode: \(httpRespons.statusCode)")
                completion(.failure(dataFeil.TjenarFeil))
            }
        }.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        print(challenge.protectionSpace.authenticationMethod)
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let kred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, kred)
        }
    }
    
    static private func handterSvar(_ data : Data?,_ respons: URLResponse?,_ feil: Error?, completion: @escaping Fullføring) {
        if feil != nil {
            completion(.failure(feil!))
        }
        
        guard let httpRespons = respons as? HTTPURLResponse else {
            completion(.failure(feil ?? dataFeil.UgyldigResopns))
            return
        }
        if 200 ... 299 ~= httpRespons.statusCode {
            if let data = data {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? Dictionary<AnyHashable, Any> {
                        completion(.success(dict))
                    } else {
                        print("Feilmeldingskode: \(httpRespons.statusCode)")
                        completion(.failure(dataFeil.DataformatFeil))
                    }
                } catch {
                    print(String(data: data, encoding: .utf8))
                    completion(.failure(dataFeil.DekodingsFeil))
                }
                
            } else {
                completion(.failure(dataFeil.UgyldigData))
            }
        }else {
            completion(.failure(dataFeil.TjenarFeil))
        }
    }
    
    static private func handterSvarDekodbar(_ data : Data?,_ respons: URLResponse?,_ feil: Error?, completion: @escaping DekodbarFullføring) {
        if feil != nil {
            print("Handter svar, Feil: ", feil)
            completion(.failure(feil!))
        }
        
        guard let httpRespons = respons as? HTTPURLResponse else {
            print("Handter svar, UgyldigResopns: ", feil, respons)
            completion(.failure(feil ?? dataFeil.UgyldigResopns))
            return
        }
        if 200 ... 299 ~= httpRespons.statusCode {
            if let data = data {
                    completion(.success(data))
            } else {
                print("Handter svar, UgyldigData: ", feil, respons)
                completion(.failure(dataFeil.UgyldigData))
            }
        }else {
            print("Handter svar, TjenarFeil: ", feil, respons)
            completion(.failure(dataFeil.TjenarFeil))
        }
    }
}
