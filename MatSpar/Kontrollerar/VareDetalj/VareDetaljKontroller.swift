//
//  VareDetaljKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import Verdensrommet
import SkiilVarslingar

class VareDetaljKontroller: UIViewController {
    
    var vare: Vare
    var sender: VarerKontroller
    
    @IBOutlet var imageView: RundImageView!
    
    @IBOutlet var tableView: UITableView!
    
    var spinner: UIActivityIndicatorView!
    var meirKnapp: NavigationKnapp!
    
    
    init(vare: Vare, kontroller: VarerKontroller) {
        self.vare = vare
        self.sender = kontroller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tilbodar: [Tilbod] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func konstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = NO
        tableView.translatesAutoresizingMaskIntoConstraints = NO
        
        imageView.fjernAlleConstraints()
        tableView.fjernAlleConstraints()
        
        imageView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = YES
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = YES
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = YES
        imageView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -0).isActive = YES
        
        tableView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = YES
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = YES
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = YES
        tableView.heightAnchor.constraint(equalToConstant: self.view.bounds.height - imageView.bounds.height).isActive = YES
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //NavBar tittel & Bilde
        self.title = vare.tittel
        imageView.image = vare.presbilde(fallbacsize: imageView.frame.size)
        
        //Table View oppset
        tableView.delegate = self
        tableView.dataSource = self
        
        let celle = UINib(nibName: "TilbodCelle", bundle: nil)
        tableView.register(celle, forCellReuseIdentifier: "celle")
        
        //Constraints
        konstraints()
        
        //Spinner
        spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = YES
        
        //Last ned tilbod
        spinner.startAnimating()
        var antalRespons: Int = 0
        butikkManager.alle { (butikk) in
            butikk.hentVare(fråStrekkode: "\(vare.eanKode)") { (res) in
                print(butikk.butikk.beskrivelse.navn, res)
                antalRespons += 1
                if let resultat = res {
                    DispatchQueue.main.async {
                        let vare = resultat.contentData._source
                        let tilbod = Tilbod(butikk: butikk.butikk, originalpris: vare.pricePerUnitOriginal, tilbodspris: vare.pricePerUnit)
                        self.tilbodar.append(tilbod)
                    }
                }
                if antalRespons == butikkManager.count {
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        konfigNavbar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.fjernView(spinner)
    }
    
    func konfigNavbar() {
        guard let navBar = self.navigationController?.navigationBar else { return }
        
        navBar.prefersLargeTitles = YES
        
        /*let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .celle
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        
        navBar.standardAppearance = appearance*/
        //navBar.scrollEdgeAppearance = appearance
        
        //Timer.scheduledTimer(withTimeInterval: 0.05, repeats: NO) { [self] (_) in
        //UIView.animate(withDuration: 0.5) { [self] in
            let ikon = #imageLiteral(resourceName: "round_more_vert_black_36pt")
            meirKnapp = (self.navigationController?.leggTilKnapp(ikon: ikon, action: Action(target: self, selector: #selector(meir)), layoutHandler: .trailing, synlegFor: [self]))!
            meirKnapp.alpha = 0
            
            self.navigationController?.leggTilView(spinner, layoutHandler: .vedSidanAv(meirKnapp))
        //}
        //}
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
            self.meirKnapp.alpha = 1
        }, completion: nil)
    }
    
    @objc func meir() {
        let picker = ModalActionsheetKontroller()
        let ikon = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        picker.addAction(tittel: "Slett", bilde: ikon, target: self, selector: #selector(slettVare))
        picker.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(picker, animated: NO, completion: nil)
    }
    
    @objc func slettVare() {
        varsling(tittel: "Slette \(vare.tittel)?", melding: "Er du sikker på at du vil slette \(vare.tittel)? Du kan legge den til igjen ved å søke etter, eller scanne den på nytt.", knapp: "Ja") {
            
            Lagring.slett(medNøkkel: self.vare.id)
            self.sender.varer = self.sender.hentVarer()
            self.navigationController?.popViewController(animated: YES)
        }
    }

}
