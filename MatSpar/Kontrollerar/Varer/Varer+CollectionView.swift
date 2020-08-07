//
//  Varer+CollectionView.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit

extension VarerKontroller: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return varer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let celle = collectionView.dequeueReusableCell(withReuseIdentifier: "vareCelle", for: indexPath) as? CollectionVareCelle else { fatalError() }
        
        celle.vare = varer[indexPath.row]
        
        return celle
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let celle = collectionView.cellForItem(at: indexPath) as? CollectionVareCelle else { return }
        let vare = celle.vare!
        
        let detalj = VareDetaljKontroller(vare: vare, kontroller: self)
        self.navigationController?.pushViewController(detalj, animated: YES)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let celle = collectionView.cellForItem(at: indexPath) as? CollectionVareCelle else { return }
        celle.Cellemembran.backgroundColor = .valgtCelle
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let celle = collectionView.cellForItem(at: indexPath) as? CollectionVareCelle else { return }
        celle.Cellemembran.backgroundColor = .celle
    }
}

@IBDesignable class CollectionViewFixedSpacingLayout: UICollectionViewFlowLayout {
    @IBInspectable var cellSpacing: CGFloat = 10
    @IBInspectable var minAntalCellerPerRad: Int = 3
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.map { $0.representedElementKind == nil ? layoutAttributesForItem(at: $0.indexPath)! : $0 }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let width = collectionView?.frame.width ?? 1
        let minCellebreidde = min((width / CGFloat(minAntalCellerPerRad)) - cellSpacing, itemSize.width)
        
        let antalCellerPerRad = Int((width / minCellebreidde).rounded())
        let cellebreidde = (width / CGFloat(antalCellerPerRad)) - cellSpacing
        
        let kolonne = indexPath.row % antalCellerPerRad
        let rad = Int(floor(CGFloat(indexPath.row) / CGFloat(antalCellerPerRad)))
        
        let x = (CGFloat(kolonne) * cellebreidde)
        attribs.frame.origin.x = x + (cellSpacing * CGFloat(kolonne))
        
        let y = (CGFloat(rad) * itemSize.height)
        attribs.frame.origin.y = y + (cellSpacing * CGFloat(rad))
        
        attribs.frame.size = CGSize(width: cellebreidde, height: itemSize.height)
        
        collectionView!.contentSize = CGSize(width: collectionView!.frame.width, height: itemSize.height * CGFloat(rad))
        collectionView!.contentInset.top = 0
        collectionView!.contentInset.bottom = 50
        
        return attribs
    }
}
