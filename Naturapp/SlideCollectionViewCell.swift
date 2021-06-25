//
//  SlideCollectionViewCell.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 24/06/21.
//

import UIKit

class SlideCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var descripcion: UILabel!
    
    func configurar(slide: OnBoardingSlide) {
        imagen.image = slide.imagen
        titulo.text = slide.titulo
        descripcion.text = slide.descripcion
    }
}
