//
//  MyCollectionViewCell.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 19/06/21.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
    }

}
