//
//  ModalActionsheet.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 05/04/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

public protocol ActionsheetDelegat {
    func actionSheet(celleVartVald indeks: Int)
    func actionSheet(menyVartVald indeks: Int, iMeny menyIndeks: Int)
}

public class ModalActionsheet: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let antalCeller = celler.count
        
        self.view.fjernConstraints(.height)
        let høgd = cellehøgd * antalCeller + 20
        self.view.heightAnchor.constraint(equalToConstant: CGFloat(høgd)).isActive = YES
        
        return antalCeller
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let celle = tableView.cellForRow(at: indexPath) as? ActionCelle else { return }
        celle.Cellemembran.backgroundColor = .valgtCelle
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let celle = tableView.cellForRow(at: indexPath) as? ActionCelle else { return }
        celle.Cellemembran.backgroundColor = .celle
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celle = tableView.dequeueReusableCell(withIdentifier: "actionCelle") as! ActionCelle
        
        let celledata = celler[indexPath.row]
        celle.tekst = celledata.tekst
        celle.ikon = celledata.bilde
        celle.chevronTekst = celledata.menytekst
        
        return celle
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellehøgd)
    }
    
    var cellehøgd = 50
    
    var valdMeny = 0
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let celle = celler[indexPath.row]
        
        if celle.action != nil {
            delegat?.actionSheet(celleVartVald: indexPath.row)
        }else if celle.erMeny {
            valdMeny = indexPath.row
            let celler = celle.menyceller!.compactMap { ($0.0, $0.1, $0.2) }
            let menydetalj = ModalActionsheetMeny(celler: celler)
            menydetalj.title = celle.tekst
            self.navigationController?.pushViewController(menydetalj, animated: YES)
        }
        
    }
    
    
    var tableView: UITableView!
    public var celler: [ActionsheetAction]
    public var delegat: ActionsheetDelegat?
    
    init(celler: [ActionsheetAction]) {
        self.celler = celler
        super.init(nibName: nil, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: .zero, style: .plain)
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = NO
        tableView.constrDekkView(topConst: 8)
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = NO
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let actionCelleNib = UINib(nibName: "ActionCelle", bundle: bundle)
        tableView.register(actionCelleNib, forCellReuseIdentifier: "actionCelle")
        
        self.view.backgroundColor = .clear
        tableView.backgroundColor = .clear
    }
    
    public func menycelleVald(idx: Int) {
        endreVal(i: valdMeny, til: idx)
        delegat?.actionSheet(menyVartVald: valdMeny, iMeny: idx)
    }
    
    public func endreVal(i meny: Int, til vald: Int) {
        let celle = tableView.cellForRow(at: IndexPath(row: meny, section: 0)) as! ActionCelle
        var menydata = celler[meny].menyceller!
        
        celle.chevronLabel.text = menydata[vald].0
        for (i,data) in menydata.enumerated() {
            var data = data
            if i == vald {data.1 = YES} else { data.1 = NO }
            menydata[i] = data
        }
        celler[meny].menyceller = menydata
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(YES, animated: YES)
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "    ", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        navigationController?.setNavigationBarHidden(NO, animated: YES)
    }
}
