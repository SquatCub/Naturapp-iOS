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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetuo()
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
    
    func initialSetuo() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
    }
}
