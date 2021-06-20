//
//  InicioViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 19/06/21.
//

import UIKit
import Firebase

class InicioViewController: UIViewController {
    //Outlets del storyboard
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: view.frame.size.width/2 - 20, height: 160)
        collectionView.collectionViewLayout = collectionLayout
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "col")
        collectionView.delegate = self
        collectionView.dataSource = self
        initialSetup()
        // Do any additional setup after loading the view.
    }

    @IBAction func cerrarSesion(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Sesion cerrada")
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error al salir ", signOutError)
        }
    }
    
    func initialSetup() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
    }
}

extension InicioViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("Clicked here!")
    }
}

extension InicioViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "col", for: indexPath) as! MyCollectionViewCell
        cell.imageView.image = UIImage(named: "img1")
        cell.tituloLabel.text = "Hola"
        return cell
    }
}

extension InicioViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 160)
    }
}
