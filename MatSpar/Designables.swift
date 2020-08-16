//
//  Designables.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

@IBDesignable class RundView: UIView {
    @IBInspectable var radius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = radius
    }
}

@IBDesignable class RundImageView: UIImageView {
    @IBInspectable var radius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = radius
    }
}

@IBDesignable class IconifisertTextField: UITextField {
    
    @IBInspectable var ikon: UIImage = UIImage() {
        didSet {
            iconView.image = ikon
        }
    }
    @IBInspectable var ibHeight: CGFloat = 46
    
    let inset: CGFloat = 10
    
    private var iconView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.translatesAutoresizingMaskIntoConstraints = NO
        self.heightAnchor.constraint(equalToConstant: ibHeight).isActive = YES
        
        self.borderStyle = .none
        self.layer.cornerRadius = 12
        
        iconView = UIImageView()
        iconView.tag = 128
        self.viewWithTag(128)?.removeFromSuperview()
        self.addSubview(iconView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset).isActive = true
        iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset).isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        
        iconView.image = ikon
        iconView.tintColor = .placeholderText
    }
    
    private var textInsets: UIEdgeInsets {
        let leadingAnchor = inset + self.frame.height - (inset * 2)
        return UIEdgeInsets(top: 2, left: leadingAnchor + 4, bottom: 2, right: 4)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
}

@IBDesignable class IconKnapp: UIView, UIPointerInteractionDelegate {
    @IBInspectable var icon: UIImage = UIImage() {
        didSet {
            imageView.image = icon
        }
    }
    var action: Action?
    var skalRendreBakgrunn: Bool = YES {
        didSet {
            imageView.tintColor = .app
            self.backgroundColor = .clear
            self.bakgrunn = .clear
        }
    }
    
    private let siz: CGFloat = 36
    
    init(icon: UIImage, action: Action) {
        self.icon = icon
        self.action = action
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: siz, height: siz)))
        self.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var imageView: UIImageView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.backgroundColor = .app
        
        imageView = UIImageView()
        imageView.image = icon
        imageView.tintColor = self.tintColor
        imageView.tag = 128
        
        self.viewWithTag(128)?.removeFromSuperview()
        
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO
        
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -8).isActive = YES
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -8).isActive = YES
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = YES
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = YES
        
        if #available(iOS 13.4, *) {
            let interaction = UIPointerInteraction(delegate: self)
            self.interactions.append(interaction)
        }
        
        if !skalRendreBakgrunn {
            imageView.tintColor = .app
            self.backgroundColor = .clear
            self.bakgrunn = .clear
        }
        
        self.translatesAutoresizingMaskIntoConstraints = NO
        
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = YES
        self.widthAnchor.constraint(equalToConstant: siz).isActive = YES
        
    }
    
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return UIPointerStyle(shape: .roundedRect(self.bounds, radius: self.frame.height/2))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    
    private var bakgrunn: UIColor?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        if !skalRendreBakgrunn {
            bakgrunn = imageView.tintColor
            imageView.tintColor = imageView.tintColor.darker(0.15)
            return
        }
        bakgrunn = self.backgroundColor
        self.backgroundColor = self.backgroundColor?.darker(0.15)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if !skalRendreBakgrunn {
            imageView.tintColor = bakgrunn
            return
        }
        self.backgroundColor = bakgrunn
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if !skalRendreBakgrunn {
            imageView.tintColor = bakgrunn
        }else {
            self.backgroundColor = bakgrunn
        }
        
        if !self.point(inside: touches.first!.location(in: self), with: event) { return }
        
        action?.kjøyr()
        
    }
}

class NavigationKnapp: IconKnapp, UINavigationControllerDelegate {
    private var synlegeKontrollerar: [String] = []
    var navBar: UINavigationController!
    var delegatKontroller: NavBarKnappDelegateController?
    
    var setupHandler: ((NavigationKnapp)->Void)?
    
    func leggTilSynlegKontroller(_ kontroller: UIViewController) {
        synlegeKontrollerar.append(kontroller.restorationIdentifier ?? kontroller.title ?? "--")
    }
    
    func leggTilSynlegeKontrollerar(_ kontrollerar: [UIViewController]) {
        for kontroller in kontrollerar {
            leggTilSynlegKontroller(kontroller)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        delegatKontroller?.leggTilKnapp(self)
        setupHandler?(self)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if synlegeKontrollerar.isEmpty { return }
        
        sjekkKnapp(vc: viewController)
        
        navigationController.transitionCoordinator?.notifyWhenInteractionChanges({ (context) in
            if context.isCancelled {
                self.sjekkKnapp(vc: context.viewController(forKey: .from)!)
            }
        })
            
    }
    
    func sjekkKnapp(vc: UIViewController) {
        if !(synlegeKontrollerar.contains(vc.restorationIdentifier ?? "") || synlegeKontrollerar.contains(vc.title ?? "")) && !synlegeKontrollerar.isEmpty {
            UIView.animate(withDuration: 0.1) {
                self.alpha = 0
            } completion: { (f) in
                self.isHidden = true
            }
        }else {
            self.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.alpha = 1
            }
        }
    }
}

enum NavKnappLayout {
    case leading, trailing, vedSidanAv(UIView), over(UIView)
    
    func horisontalLayout(_ navBar: UINavigationBar, view: UIView) {
        switch self {
            case .leading:
                view.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 8).isActive = YES
            case .trailing:
                view.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -8).isActive = YES
            case .vedSidanAv(let view2):
                if view2.superview != navBar { return }
                view.trailingAnchor.constraint(equalTo: view2.leadingAnchor, constant: -8).isActive = YES
            case .over(let view2):
                view.centerXAnchor.constraint(equalTo: view2.centerXAnchor).isActive = YES
        }
    }
    
    func vertikalLayout(_ navBar: UINavigationBar, view: UIView) {
        if navBar.prefersLargeTitles {
            switch self {
                case .vedSidanAv(let view2):
                    view.centerYAnchor.constraint(equalTo: view2.centerYAnchor).isActive = YES
                case .over(let view2):
                    view.bottomAnchor.constraint(equalTo: view2.topAnchor, constant: -8).isActive = YES
                default:
                    view.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8).isActive = YES
            }
        }else {
            switch self {
                case .vedSidanAv(let view2):
                    view.centerYAnchor.constraint(equalTo: view2.centerYAnchor).isActive = YES
                default:
                    view.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = YES
            }
        }
    }
}

class NavBarKnappDelegateController: NSObject, UINavigationControllerDelegate {
    
    var delegatar: [NavigationKnapp] = []
    var navBarController: UINavigationController
    
    init(navBar: UINavigationController) {
        self.navBarController = navBar
        super.init()
        navBar.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        delegatar.forEach { $0.navigationController(navigationController, willShow: viewController, animated: animated) }
    }
    
    func leggTilKnapp(_ knapp: NavigationKnapp) {
        delegatar.append(knapp)
    }
    
}

extension UINavigationController {
    
    func leggTilKnapp(ikon: UIImage, action: Action, layoutHandler: NavKnappLayout, synlegFor kontrollerar: [UIViewController]=[], delegatKontroller: NavBarKnappDelegateController? = nil) -> NavigationKnapp {
        let navBar = self.navigationBar
        
        let knapp = NavigationKnapp(icon: ikon, action: action)
        knapp.navBar = self
        knapp.delegatKontroller = delegatKontroller ?? NavBarKnappDelegateController(navBar: self)
        knapp.leggTilSynlegeKontrollerar(kontrollerar)
        knapp.tintColor = .white
        knapp.backgroundColor = .app
        
        leggTilView(knapp, layoutHandler: layoutHandler)
        
        return knapp
    }
    
    func leggTilKnapp(tekst: String, action: Action, layoutHandler: NavKnappLayout) -> UIButton {
        let navBar = self.navigationBar
        
        let knapp = UIButton()
        knapp.setTitle(tekst, for: .normal)
        knapp.titleLabel!.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        knapp.tintColor = .app
        knapp.setTitleColor(.app, for: .normal)
        knapp.setTitleColor(UIColor.app.darker(0.15), for: .highlighted)
        knapp.addTarget(action.target, action: action.selector, for: .touchUpInside)
        
        leggTilView(knapp, layoutHandler: layoutHandler)
        
        return knapp
    }
    
    func leggTilView(_ view: UIView, layoutHandler: NavKnappLayout) {
        let navBar = self.navigationBar
        
        navBar.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = NO
        
        layoutHandler.horisontalLayout(navBar, view: view)
        layoutHandler.vertikalLayout(navBar, view: view)
    }
    
    func fjernView(_ view: UIView) {
        let navBar = self.navigationBar
        
        if navBar.subviews.contains(view) {
            view.removeFromSuperview()
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
