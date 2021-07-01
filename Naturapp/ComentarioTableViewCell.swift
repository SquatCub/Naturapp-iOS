//
//  ComentarioTableViewCell.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 01/07/21.
//

import UIKit

class ComentarioTableViewCell: UITableViewCell {

    @IBOutlet weak var comentarioLabel: UILabel!
    @IBOutlet weak var contactoImagen: UIImageView!
    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = 9
        backView.layer.masksToBounds = false
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowOffset = .zero
        backView.layer.shadowRadius = 5
        contactoImagen.layer.cornerRadius = 25
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
