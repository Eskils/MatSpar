//
//  Hjelpefunksjonar.swift
//  SkiilVarslingar
//
//  Created by Eskil Sviggum on 08/08/2020.
//

import UIKit

let YES = true
let NO = false

let rammeverkId = "com.skilbreak.SkiilVarslingar"
let bundle = Bundle(identifier: rammeverkId)

extension UIColor {
    static var celle: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Cell")!
        }else {
            return .white
        }
    }
    
    static var valgtCelle: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "SelectedCell")!
        }else {
            return .lightGray
        }
    }
    
    static var tema: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "AccentColor")!
        }else {
            return .green
        }
    }
    
}

@IBDesignable class rundView: UIView {
    @IBInspectable var hjorneRadius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = hjorneRadius
    }
}


public struct Action {
    public var target: NSObject
    public var selector: Selector
    public var sender: Any? = nil
    
    public func kjøyr() {
        if let sender = sender {
            target.perform(selector, with: sender)
        }else {
            target.perform(selector)
        }
    }
    
}

extension UIView {
    func constrDekkView(topConst: CGFloat = 0) {
        guard let sw = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = NO
        
        self.topAnchor.constraint(equalTo: sw.topAnchor, constant: topConst).isActive =  YES
        self.bottomAnchor.constraint(equalTo: sw.bottomAnchor).isActive =  YES
        self.leadingAnchor.constraint(equalTo: sw.leadingAnchor).isActive =  YES
        self.trailingAnchor.constraint(equalTo: sw.trailingAnchor).isActive =  YES
    }
    
    func fjernConstraints(_ attributt: NSLayoutConstraint.Attribute) {
        var tilFjerning: [NSLayoutConstraint] = []
        for constraint in self.constraints {
            if constraint.firstAttribute == attributt || constraint.secondAttribute == attributt {
                tilFjerning.append(constraint)
            }
        }
        self.removeConstraints(tilFjerning)
    }
    
    func fjernAlleConstraints() {
        self.removeConstraints(self.constraints)
    }
}
