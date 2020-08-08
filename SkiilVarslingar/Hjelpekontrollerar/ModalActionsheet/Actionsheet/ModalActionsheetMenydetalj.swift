//
//  ModalActionsheetMenydetalj.swift
//  Vekeplan1_5
//
//  Created by Eskil Sviggum on 05/04/2020.
//  Copyright © 2020 SIGABRT. All rights reserved.
//

import UIKit

class ModalActionsheetMeny: UIViewController, PickerViewDelegat {
    
    var celler: [(String, Bool, UIImage?)]
    var pickerView: PickerView!
    
    init(celler: [(String, Bool, UIImage?)]) {
        self.celler = celler
        super.init(nibName: nil, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemGroupedBackground
        } else {
            // Fallback on earlier versions
            self.view.backgroundColor = .groupTableViewBackground
        }
        
        pickerView = PickerView()
        pickerView.celler = celler.compactMap { $0.0 }
        pickerView.delegat = self
        
        self.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = NO
        pickerView.constrDekkView()
        
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = .tema
        
    }
    
    func pickerView(_ pickerView: Int, valdeCelle celle: String) {
        let idx = (celler.compactMap { $0.0 }).firstIndex(of: celle)!
        (self.navigationController?.viewControllers.first as? ModalActionsheet)!.menycelleVald(idx: idx)
        self.navigationController?.popViewController(animated: YES)
    }
    
    func pickerViewCelleVald(_ pickerView: Int, erCelleVald index: Int) -> ObjCBool {
        let celledata = celler[index]
        return ObjCBool(celledata.1)
    }
    
    func pickerView(_ pickerView: Int, bildeForCelle index: Int) -> UIImage? {
        let celledata = celler[index]
        return celledata.2
    }
}
