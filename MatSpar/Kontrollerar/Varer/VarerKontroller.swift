//
//  VarerKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

var harKonfigurertNavBar: Bool = false
class VarerKontroller: UIViewController {
    
    var barItem: UITabBarItem! {
        UITabBarItem(title: "Varer", image: UIImage(systemName: "rectangle.stack")!, tag: 0)
    }
    
    var ikon: UIImage {
        UIImage(systemName: "rectangle.stack")!
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    var varer: [Vare] = [] {
        didSet {
            varer.sort { $0.tittel < $1.tittel }
            if !varer.isEmpty { statusLabel.isHidden = YES }
            collectionView.reloadData()
        }
    }
    
    func lagreVarer() {
        Lagring.varer.lagre(verdi: self.varer.compactMap { $0.id })
        for vare in varer {
            Lagring.vare.lagre(verdi: vare, overstyrNøkkel: vare.id)
        }
    }
    
    func hentVarer() -> [Vare] {
        let idar: [String] = Lagring.varer.hent() ?? []
        if idar.isEmpty { return [] }
        var varer:[Vare] = []
        for id in idar {
            guard let vare: Vare = Lagring.hent(medNøkkel: id) else { continue }
            varer.append(vare)
        }
        return varer
    }
    
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Varer"
        self.tabBarItem = UITabBarItem(title: "Varer", image: UIImage(), tag: 0)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let celle = UINib(nibName: "CollectionVareCelle", bundle: nil)
        collectionView.register(celle, forCellWithReuseIdentifier: "vareCelle")
        
        konfigNavbar()
        varer = hentVarer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !harKonfigurertNavBar {
            harKonfigurertNavBar = true
            if !varer.isEmpty {
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: NO)
            }else {
                statusLabel.isHidden = NO
                statusLabel.text = "Trykk på pluss-en for å legge til varer som du kjøper ofte!"
            }
        
            let ikon = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            let _ = self.navigationController?.leggTilKnapp(ikon: ikon, action: Action(target: self, selector: #selector(leggTilVare)), layoutHandler: .trailing, synlegFor: [self])
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
    }
    
    @objc func leggTilVare() {
        let leggTilvareKontroller = LeggTilVareKontroller()
        leggTilvareKontroller.delegat = self
        
        let nav = UINavigationController(rootViewController: leggTilvareKontroller)
        nav.modalPresentationStyle = .formSheet
        self.navigationController?.present(nav, animated: YES, completion: nil)
    }

}
