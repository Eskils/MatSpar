//
//  CollectionVareCelle.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import Biilde

class CollectionVareCelle: UICollectionViewCell, BildeDelegat {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var tittelLabel: UILabel!
    
    @IBOutlet var undertittelLabel: UILabel!
    @IBOutlet var Cellemembran: RundView!
    
    var vare: Vare?
    var bilde: UIImage? {
        didSet {
            imageView.image = bilde
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        konfig()
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        konfig()
    }
    
    func konfig() {
        guard let data = vare else { return }
        
        let siz = self.imageView.frame.size
        imageView.image = data.bilde?.uiImage ?? data.presbilde(fallbacsize: siz)
        if data.bilde?.uiImage == nil && data.bilde?.getUrl() != nil {
            data.bilde?.delegat = self
            data.bilde?.last()
        }
        tittelLabel.text = data.tittel
        undertittelLabel.text = data.kategori.rawValue
    }
    
    func bilde(avsluttaNedlastingAv bilde: UIImage) {
        self.bilde = bilde
        Lagring.vare.lagre(verdi: vare!, overstyrNøkkel: vare!.id)
    }

}
