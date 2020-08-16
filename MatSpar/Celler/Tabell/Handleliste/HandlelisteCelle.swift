//
//  HandlelisteCelle.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 10/08/2020.
//

import UIKit

class HandlelisteCelle: UITableViewCell {
    
    @IBOutlet var bildeView: RundImageView!
    
    @IBOutlet var tittelLabel: UILabel!
    
    @IBOutlet var prisLabel: UILabel!
    
    @IBOutlet var checkKnapp: IconKnapp!
    
    var celledata: HandlelisteVare?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        konfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        konfig()
    }
    
    
    func konfig() {
        guard let data = celledata else { return }
        
        self.bildeView.image = data.bilde?.uiImage
        self.tittelLabel.text = data.tittel
        self.prisLabel.text = "kr \(data.faktiskPris())"
        self.checkKnapp.isHidden = YES
        
    }
}
