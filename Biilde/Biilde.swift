//
//  Biilde.swift
//  Biilde
//
//  Created by Eskil Sviggum on 05/08/2020.
//

import UIKit

@objc public protocol BildeDelegat {
    @objc func bilde(avsluttaNedlastingAv bilde: UIImage)
}

public class Bilde : Codable {
    private var data : Data
    private var url: String? = nil
    public var delegat: BildeDelegat?
    
    public func setUrl(url: String) {
        if let fakUrl = URL(string: url) {
            self.url = url
            lastNed(url: fakUrl, comp: nil)
        }
    }
    
    public func getUrl() -> String? {
        return self.url
    }
    
    public init(_ bilde: UIImage) {
        data = bilde.pngData()!
    }
    ///Lastar inn som eit tomt bilete, men lastar ned bildet i bakgrunnen.
    public init(_ url: URL?, skalLasteNed: Bool = true, fullføring: ((Bilde)->Void)? = nil) {
        self.data = Data()
        if let url = url {
            self.url = url.absoluteString
            if skalLasteNed {
                last(fullføring: fullføring)
            }
        }
    }
    
    public func last(fullføring: ((Bilde)->Void)?=nil) {
        if  let str = url,
            let url = URL(string: str) {
            lastNed(url: url) { (img) in
                let bilde = Bilde(img)
                bilde.url = self.url
                
                //Delagaten har allereie blitt kallt
                
                if let fullf = fullføring {
                    fullf(bilde)
                }
            }
        }
    }
    
    private func lastNed(url: URL, comp: ((UIImage)->Void)?) {
        DispatchQueue.global().async {
            do {
                self.data = try Data(contentsOf: url)
                
                let image = UIImage(data: self.data)
                if let comp = comp {
                    comp(image ?? UIImage())
                }
                DispatchQueue.main.async {
                    self.delegat?.bilde(avsluttaNedlastingAv: image!)
                }
            }catch { print(error) }
        }
    }
    
    public var uiImage: UIImage? {
        guard let bilde = UIImage(data: self.data) else { return nil }
        return bilde
    }
    
    private enum CodingKeys: String, CodingKey {
        case data, url
    }
}
