//
//  OnBoardingViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 24/06/21.
//

import UIKit

class OnBoardingViewController: UIViewController {
    //Outlets del storyboard
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var botonSiguiente: UIButton!
    
    //Slides
    var slides: [OnBoardingSlide] = []
    var paginaActual = 0 {
        didSet{
            pageControl.currentPage = paginaActual
            if paginaActual == slides.count-1 {
                botonSiguiente.setTitle("Adelante", for: .normal )
            } else {
                botonSiguiente.setTitle("Siguiente", for: .normal )
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setSlides()
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    @IBAction func siguienteClick(_ sender: UIButton) {
        if paginaActual == slides.count - 1 {
            let vc = storyboard?.instantiateViewController(identifier: "HOME") as! UIViewController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            present(vc, animated: true, completion: nil)
        } else {
            paginaActual += 1
            let indexPath = IndexPath(item: paginaActual+1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
    func setSlides() {
        slides = [
            OnBoardingSlide(titulo: "Titulo", descripcion: "Esta es una descripcion demostrativa para el ejemplo", imagen: #imageLiteral(resourceName: "img3")),
            OnBoardingSlide(titulo: "Titulo 2", descripcion: "Esta es una descripcion demostrativa para el ejemplo", imagen: #imageLiteral(resourceName: "img3")),
            OnBoardingSlide(titulo: "Titulo 3", descripcion: "Esta es una descripcion demostrativa para el ejemplo", imagen: #imageLiteral(resourceName: "img3"))

        ]
    }
}

extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCollectionViewCell", for: indexPath) as! SlideCollectionViewCell
        celda.configurar(slide: slides[indexPath.row])
        return celda
    }
}

extension OnBoardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let ancho = scrollView.frame.width
        paginaActual = Int(scrollView.contentOffset.x/ancho)
    }
}
