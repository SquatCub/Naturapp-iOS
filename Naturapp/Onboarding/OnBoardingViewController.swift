//
//  OnBoardingViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 24/06/21.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    

    @IBOutlet weak var botonSiguiente: UIButton!
    @IBOutlet weak var CollectionViewOn: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var diapositivas: [OnBoardingSlide] = []
    
    var paginaActual = 0 {
        didSet {
            pageControl.currentPage = paginaActual
            if paginaActual == diapositivas.count - 1 {
                botonSiguiente.setTitle("Empezar", for: .normal)
            } else {
                botonSiguiente.setTitle("Siguiente", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        diapositivas = [
            OnBoardingSlide(titulo: "Bienvenido a Naturapp", descripcion: "Aquí podrás encontrar y compartir lugares increíbles", imagen: #imageLiteral(resourceName: "title")),
            OnBoardingSlide(titulo: "Descubre", descripcion: "Encuentra lugares cerca o lejos de ti", imagen: #imageLiteral(resourceName: "img2")),
            OnBoardingSlide(titulo: "Comparte", descripcion: "Comparte ese lago, bosque o sendero para que todos puedan descubrirlo", imagen: #imageLiteral(resourceName: "img3")),
            OnBoardingSlide(titulo: "Conoce", descripcion: "Puedes ver la ubicación de cualquier lugar, así como el clima actual", imagen: #imageLiteral(resourceName: "img5")),
            OnBoardingSlide(titulo: "Empieza a explorar", descripcion: "Necesitarás estar registrado y permitir acceso a tu ubicación para compartir lugares", imagen: #imageLiteral(resourceName: "title"))
        ]
        CollectionViewOn.delegate = self
        CollectionViewOn.dataSource = self
        
    }
    
    @IBAction func botonSiguienteClick(_ sender: UIButton) {
        //Si estamos en la última diapositiva ir a HOME
        if paginaActual == diapositivas.count - 1 {
            let vc = storyboard?.instantiateViewController(identifier: "HOME") as! UIViewController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            
            present(vc, animated: true, completion: nil)

        } else {
            paginaActual += 1
            let indexPath = IndexPath(item: paginaActual, section: 0)
            CollectionViewOn.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diapositivas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = CollectionViewOn.dequeueReusableCell(withReuseIdentifier: "SlideCollectionViewCell", for: indexPath) as! SlideCollectionViewCell
        celda.configurar(slide: diapositivas[indexPath.row])
        return celda
    }
 
    
}

extension OnBoardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CollectionViewOn.frame.width, height: CollectionViewOn.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let ancho = scrollView.frame.width
        paginaActual = Int(scrollView.contentOffset.x/ancho)
        
    }
}
