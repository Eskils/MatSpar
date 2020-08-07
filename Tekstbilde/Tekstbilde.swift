//
//  Tekstbilde.swift
//  Tekstbilde
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

struct PixData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8 = 255
    
    var uiColor: UIColor {
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

func hueToPix(hue: Int) -> PixData {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    
    let h = hue % 61
    
    // A = hSiz / kanalSiz * antalKanalar
    let auke: Double = 3 / 180 * 255
    let hauk = UInt8((Double(h) * auke).rounded())
    
    if hue <= 60 {
        r = 255
        g = hauk
    }else
    if hue <= 120 {
        g = 255
        r = 255 - hauk
    }else
    if hue <= 180 {
        g = 255
        b = hauk
    }else
    if hue <= 240 {
        b = 255
        g = 255 - hauk
    }else
    if hue <= 300 {
        b = 255
        r = hauk
    }else
    if hue <= 360 {
        r = 255
        b = 255 - hauk
    }
    
    return PixData(r: r, g: g, b: b)
}

func lagGradView(med hue1: Int,og hue2:Int, size: CGSize) -> gradView {
    let ramme = CGRect(origin: .zero, size: size)
    let view = gradView(frame: ramme)
    
    let pix = hueToPix(hue: hue1).uiColor
    let pix2 = hueToPix(hue: hue2).uiColor
    
    view.fargeFrå = pix
    view.fargeTil = pix2
    
    return view
}

extension UIImage {
    
    ///Lagar eit bilete med ein gradering som bakgrunn og initialar av teksten i front. `hue` parameteret bestemmer start-kuløren på graderingen.
    public static func tekstBilde(med tekst: String?, initialar: String? = nil, font: UIFont = .monospacedDigitSystemFont(ofSize: 16, weight: UIFont.Weight.semibold), size: CGSize, hue: Int) -> UIImage {
        let chars = initialar ?? tekst!.initialar()
        
        let h1 = hue % 360
        let h2 = (h1 + 36) % 360
        let view = lagGradView(med: h1, og: h2, size: size)
        
        let label = UILabel(frame: view.bounds)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        label.textColor = .white
        label.textAlignment = .center
        label.font = font.withSize(size.height * 0.8)
        label.text = chars
        
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 20
        label.layer.shadowOpacity = 1
        
        let shadowView = UIView(frame: CGRect(origin: .zero, size: size))
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        label.addSubview(shadowView)
        
        let lh1 = h2
        let lh2 = (h2 + 30) % 360
        let labelGrad = lagGradView(med: lh1, og: lh2, size: size)
        labelGrad.mask = label
        view.addSubview(labelGrad)
        
        label.layer.shadowRadius = 0.2
        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = 0
        
        
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let bilde = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return bilde
    }
    
}

@IBDesignable class gradView: UIView {
    @IBInspectable var fargeFrå: UIColor = UIColor.white
    @IBInspectable var fargeTil: UIColor = UIColor.black
    @IBInspectable var reverserFargar : Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = false
        
        var fargar = [self.fargeFrå.cgColor, self.fargeTil.cgColor]
        
        fargar = reverserFargar ? fargar.reversed() : fargar
        
        (layer as! CAGradientLayer).colors = fargar
        //(layer as! CAGradientLayer).startPoint = CGPoint(x: 0, y: 0.0)
        //(layer as! CAGradientLayer).endPoint = CGPoint(x: 0.85, y: 1)
    }
    
    
}

extension String {
    public func initialar() -> String {
        var out: String = ""
        
        if self.count <= 1 { return self }
        
        if self.contains(" ") {
            let strengar = self.components(separatedBy: " ")
            let kakaoStrengar = strengar.compactMap { NSString(string: "\($0) ") }
            out += kakaoStrengar.first?.substring(to: 1) ?? ""
            out += kakaoStrengar.last?.substring(to: 1) ?? ""
        }else {
            let kakaoStreng = NSString(string: self)
            out = kakaoStreng.substring(with: NSRange(location: 0, length: 2))
        }
        
        return out
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
