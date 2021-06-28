//
//  SlideCollectionViewCell.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 24/06/21.
//

import UIKit

class SlideCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imagenDiapositivaIV: UIImageView!
    @IBOutlet weak var tituloDiapositivaLbl: UILabel!
    @IBOutlet weak var descripcionDiapositivaLbl: UILabel!
    
    func configurar(slide: OnBoardingSlide) {
        imagenDiapositivaIV.image = slide.imagen
        tituloDiapositivaLbl.text = slide.titulo
        descripcionDiapositivaLbl.text = slide.descripcion
    }
}
