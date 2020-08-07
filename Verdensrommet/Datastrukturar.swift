//
//  Datastrukturar.swift
//  Verdensrommet
//
//  Created by Eskil Sviggum on 05/08/2020.
//

import Foundation
import Biilde

public struct Butikkbeskrivelse {
    public let navn: String
    let butikkId: Int
    let parameterId: Int
    public let nettbutikkUrl: URL
}

enum AutosuggestType: String {
    case forslag = "suggest"
    case varer = "products"
    case oppskrifter = "recipes"
    case butikkar = "stores"
    case artikklar = "articles"
}

struct AutosuggestForespørselkonfigurasjon {
    private let types: [AutosuggestType]
    private var searchVerdi : String
    private var pageSize: Int = 14
    private var popularity: Bool = true
    
    init(søk: String, typar: AutosuggestType..., antal: Int, sorterEtterPopularitet: Bool=true) {
        self.types = typar
        self.pageSize = antal
        self.popularity = sorterEtterPopularitet
        self.searchVerdi = søk
    }
    
    var search: String {
        set(value) {
            searchVerdi = value
        }
        get {
            return searchVerdi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
    }
    
    func somQueryparameter() -> String {
        var typesParam = ""
        types.forEach { typesParam += "\($0.rawValue)," }
        typesParam.removeLast()
        let res = "types=\(typesParam)&page_size=\(pageSize)&popularity=\(popularity ? "true":"false")&search=\(search)"
        return res
    }
    
}

public enum Butikk {
    case spar, joker, meny
    
    public var beskrivelse: Butikkbeskrivelse {
        switch self {
            case .spar:
                return Butikkbeskrivelse(navn: "Spar", butikkId: 1210, parameterId: 7080001266110, nettbutikkUrl: URL(string: "https://spar.no")!)
            case .joker:
                return Butikkbeskrivelse(navn: "Joker", butikkId: 1220, parameterId: 7080001420567, nettbutikkUrl: URL(string: "https://joker.no")!)
            case . meny:
                return Butikkbeskrivelse(navn: "Meny", butikkId: 1300, parameterId: 7080000886050, nettbutikkUrl: URL(string: "https://meny.no")!)
        }
    }
    
    var baseUrl: URL {
        let url = "https://platform-rest-prod.ngdata.no/api/episearch/\(beskrivelse.butikkId)/"
        return URL(string: url)!
    }
    
    private var autosugestUrl: URL {
        let url = baseUrl.absoluteString + "autosuggest?store_id=\(beskrivelse.parameterId)"
        return URL(string: url)!
    }
    
    func autosuggestUrl(konfigurasjon: AutosuggestForespørselkonfigurasjon) -> URL {
        let url = autosugestUrl.absoluteString + "&" + konfigurasjon.somQueryparameter()
        return URL(string: url)!
    }
}

public struct AutosuggestResultat: Codable {
    var products: ProductsTreff
    
    struct ProductsTreff:Codable {
        var hits: [SøkeforslagResultat]
    }
}

public struct SøkeforslagResultat: Codable {
    ///Navnet på resultatet/vara
    public var title: String
    ///Ein kort beskrivelse av resultatet t.d. „av svin“, eller „300g eldorado“
    public var description: String
    ///URL-del til eit bilete av vara/resultatet
    var imageId: String
    ///Kjelda til Meir om resultatet/vara
    public var contentData: SøkeforslagInnhaldskjelde
    
    public struct SøkeforslagInnhaldskjelde: Codable {
        ///Meir om vara
        public var _source:SøkeforslagInnhald
        
        public struct SøkeforslagInnhald:Codable {
            ///Navnet på vara
            public var title: String
            ///Kva kategori vara har t.d. „Frukt & grønt“, eller „Bakeri“
            public var categoryName: String
            ///Pris etter tilbod. Om det ikkje er noko tilbod vil denne vere lik `pricePerUnitOriginal`
            public var pricePerUnit: Float
            ///Kva eining prisen svarar til t.d „Stykk“
            public var unitType:String
            ///Strekkode — EuropeanArticleNumber
            public var ean: String
            ///Levrandør av vara t.d. „Bama dagligvare as“
            public var vendor: String
            ///URL-del til bildet av vara.
            public var imageName: String
            ///Om vara er på tilbod
            public var isOffer: Bool
            ///Om vara er utsolgt
            public var isOutOfStock: Bool
            ///Diverse tilbod/kupongar på vara
            public var promotions: [Tilbod]
            ///Pris før tilbod Om det ikkje er noko tilbod vil denne vere lik `pricePerUnit`
            public var pricePerUnitOriginal:Float
            ///Undertittel/beskrivelse
            public var subtitle: String
            ///Kva NG vil fortelle deg kort om tilbodet t.d. „tom. 31/08“
            public var promotionDisplayName: String
            
            public func bilde(siz: Int, kvalitet: Float = 0.5) -> Bilde {
                let qlt = Int(floor(kvalitet * 100))
                let prefiks = "https://res.cloudinary.com/norgesgruppen/image/upload/c_pad,b_white,f_auto,h_\(siz),q_\(qlt),w_\(siz)/"
                let url = prefiks + imageName
                
                let bilde = Bilde(URL(string: url)!)
                return bilde
            }
            
            public struct Tilbod: Codable {
                ///Beskrivelse av tilbodet/kupongen
                public var promoMarketText: String
                ///Tittelen på tilbodet
                public var promoName: String
                ///Om NG promoterar/reklamerar tilbodet
                public var isMarketed:Bool
                ///Startdato — må formaterast før bruk :)
                public var to: String
                ///Sluttdato — må formaterast før bruk :)
                public var from: String
                ///Beskrivelse av tilbodet igjen
                public var marketText: String
                ///Om tilbodet er del av trumf.
                public var trumfCampaign: Bool
            }
        }
    }
}

