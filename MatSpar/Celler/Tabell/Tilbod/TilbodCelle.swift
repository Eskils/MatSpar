//
//  TilbodCelle.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 07/08/2020.
//

import UIKit

class TilbodCelle: UITableViewCell {
    
    @IBOutlet var cellemembran: RundView!
    
    @IBOutlet var prisLabel: UILabel!
    
    @IBOutlet var butikkLabel: UILabel!
    
    @IBOutlet var chevronBildeView: UIImageView!
    
    @IBOutlet var tilbodBanner: UIView!
    
    @IBOutlet var tilbodLabel: UILabel!
    
    var celledata: Tilbod?
    private var synerTilbodsprosent: Bool = NO
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func didMoveToSuperview() {
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        konfig()
    }
    
    func konfig() {
        guard let tilbod = self.celledata else { return }
        
        prisLabel.text = "kr \(tilbod.faktiskPris())"
        butikkLabel.text = tilbod.butikknavn()
        
        tilbodBanner.layer.masksToBounds = YES
        tilbodBanner.clipsToBounds = YES
        //tilbodBanner.mask = UIView(frame: CGRect(x: 0, y: -8, width: self.cellemembran.bounds.width, height: 8))
        tilbodBanner.isHidden = !tilbod.erTilbod()
        tilbodBanner.transform = CGAffineTransform(rotationAngle: rad(-25))
        tilbodBanner.subviews.first!.transform = CGAffineTransform(rotationAngle: .pi/2)
        
        if synerTilbodsprosent {
            let prosent = Int(100 - floor((tilbod.tilbodspris / tilbod.originalpris) * 100))
            tilbodLabel.text = "-\(prosent)%"
        }else {
            tilbodLabel.text = "TILBOD"
        }
        
        //Me tek den vekk for no...
        chevronBildeView.isHidden = YES
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        synerTilbodsprosent = !synerTilbodsprosent
        konfig()
    }
    
}
