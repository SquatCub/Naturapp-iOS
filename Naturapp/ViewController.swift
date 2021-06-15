//
//  ViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 14/06/21.
//

import UIKit
import iCarousel

class ViewController: UIViewController, iCarouselDataSource {
    
    //Inicializacion del carrusel
    let myCarousel: iCarousel = {
        let view = iCarousel()
        view.type = .coverFlow
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Se agrega el carrusel a la vista principal
        view.addSubview(myCarousel)
        myCarousel.dataSource = self
        myCarousel.frame = CGRect(x: 0, y: 20, width: view.frame.size.width, height: 100)
    }
    
    //Metodos para el carrusel
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        view.backgroundColor = .blue
        return view
    }


}

