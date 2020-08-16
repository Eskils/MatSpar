//
//  HandlelisteKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 10/08/2020.
//

import UIKit
import OrderedDictionary
import Verdensrommet

class HandlelisteKontroller: UIViewController, LeggTilVareDelegat {
    
    var barItem: UITabBarItem! {
        return UITabBarItem(title: "Handleliste", image: UIImage(systemName: "cart"), tag: 1)
    }
    
    var ikon: UIImage {
        UIImage(systemName: "cart")!
    }
    
    
    @IBOutlet var tableView: UITableView!
    var leggTilVareKnapp: NavigationKnapp!
    
    var spinner: UIActivityIndicatorView!
    
    var celler: [HandlelisteVare] = [] {
        didSet {
            sorterteCeller.fjernAlle()
            for (i, celle) in celler.enumerated() {
                let butNavn = celle.butikk.beskrivelse.navn
                var arr = sorterteCeller[butNavn] ?? []
                arr.append(i)
                sorterteCeller[butNavn] = arr
            }
            tableView.reloadData()
        }
    }
    
    var sorterteCeller: OrderedDictionary<String, [Int]> = OrderedDictionary() {
        didSet {
            tableView.reloadData()
        }
    }
    
    func skalForfriskeTilbod() -> Bool {
        //Finn lagra sist oppdatert, dersom den ikkje eksisterer må me forfriske.
        guard let sistForfriska: TimeInterval = Lagring.handlelisteSistOppdatert.hent() else { return YES }
        
        let dagKonvertConst: Double = (60 * 60 * 24)
        
        let dato = Date(timeIntervalSince1970: sistForfriska)
        let idagTimestamp = (floor(Date().timeIntervalSince1970 / dagKonvertConst) * dagKonvertConst) + dagKonvertConst
        let idagDiff = dato.distance(to: Date(timeIntervalSince1970: idagTimestamp))
        let dagar = idagDiff / dagKonvertConst
        
        //Returner om antal dagar mellom midnatt neste dag og sist oppdatert er meirennlik 1.
        return dagar >= 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Handleliste"
        
        self.view.backgroundColor = .systemGroupedBackground
        
        tableView.layer.cornerRadius = 12
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let celle = UINib(nibName: "HandlelisteCelle", bundle: nil)
        tableView.register(celle, forCellReuseIdentifier: "celle")
        
        konfigNavbar()
    }
    
    func lastInnCeller() -> [HandlelisteVare] {
        let idAr:[String] = Lagring.handleliste.hent() ?? []
        var arr: [HandlelisteVare?] = idAr.compactMap { Lagring.hent(medNøkkel: $0) }
        arr = arr.filter { $0 != nil }
        return arr as! [HandlelisteVare]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let lagraVarer = lastInnCeller()
        if lagraVarer.isEmpty { return }
        
        if skalForfriskeTilbod() {
            spinner.startAnimating()
            let varer = lagraVarer.compactMap { $0.vare() }
            forfriskTilbodPåVarer(varer) { (nyeTilbod) in
                DispatchQueue.main.async {
                    Lagring.handlelisteSistOppdatert.lagre(verdi: Date().timeIntervalSince1970)
                    self.spinner.stopAnimating()
                    self.celler = nyeTilbod
                }
            }
        }else {
            celler = lagraVarer
        }
    }
    
    func konfigNavbar() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        
        navBar.prefersLargeTitles = YES
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.configureWithDefaultBackground()
        scrollAppearance.backgroundColor = .celle
        scrollAppearance.shadowImage = UIImage()
        scrollAppearance.shadowColor = .clear
        
        navBar.standardAppearance = scrollAppearance
        navBar.scrollEdgeAppearance = scrollAppearance
        
        let icon = UIImage(systemName: "plus")!
        leggTilVareKnapp = navigationController?.leggTilKnapp(ikon: icon, action: Action(target: self, selector: #selector(leggTilVarer)), layoutHandler: .trailing)
        
        spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = YES
        navigationController?.leggTilView(spinner, layoutHandler: .vedSidanAv(leggTilVareKnapp))
    }
    
    @objc func leggTilVarer() {
        let vc = LeggTilVareKontroller()
        vc.delegat = self
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: YES, completion: nil)
    }
    
    func laTilVarer(_ kontroller: LeggTilVareKontroller, varer: [Vare]) {
        kontroller.dismiss(animated: YES, completion: nil)
        
        var nyeVarer: [Vare] = []
        for vare in varer {
            if celler.contains(vare) { continue }
            nyeVarer.append(vare)
        }
        
        spinner.startAnimating()
        forfriskTilbodPåVarer(nyeVarer) { (nyeTilbod) in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.celler += nyeTilbod
            }
        }

    }
    
    func forfriskTilbodPåVarer(_ nyeVarer: [Vare], completion: @escaping ([HandlelisteVare])->Void) {
        var nyeTilbod: [HandlelisteVare] = []
        var antalSjekkaVarer: Int = 0
        for vare in nyeVarer {
            var antalRespons: Int = 0
            var tilbodar: [Tilbod] = []
            
            butikkManager.alle { (butikk) in
                butikk.hentVare(fråStrekkode: "\(vare.eanKode)") { (res) in
                    antalRespons += 1
                    if let resultat = res {
                        let vare = resultat.contentData._source
                        let tilbod = Tilbod(butikk: butikk.butikk, originalpris: vare.pricePerUnitOriginal, tilbodspris: vare.pricePerUnit)
                        tilbodar.append(tilbod)
                    }
                    if antalRespons == butikkManager.count {
                        //Har fått tilboda frå alle butikkane!
                        if let billegast = tilbodar.min(by: { $0.faktiskPris() < $1.faktiskPris() }) {
                            antalSjekkaVarer += 1
                            let hVare = HandlelisteVare(vare: vare, tilbod: billegast)
                            
                            Lagring.handlelisteVare.lagre(verdi: hVare, overstyrNøkkel: hVare.id)
                            Lagring.handleliste.leggTilIListe(verdi: hVare.id)
                            
                            nyeTilbod.append(hVare)
                        }
                        if antalSjekkaVarer == nyeVarer.count {
                            completion(nyeTilbod)
                        }
                    }
                }
            }
        }
    }
    
    func avbrøytLeggTilVarer(_ kontroller: LeggTilVareKontroller) {
        kontroller.dismiss(animated: YES, completion: nil)
    }

}
