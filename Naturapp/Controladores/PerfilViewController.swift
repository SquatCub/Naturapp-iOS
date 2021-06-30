//
//  PerfilViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 28/06/21.
//

import UIKit
import Firebase
import GoogleSignIn

class PerfilViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @IBAction func cerrarSesion(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Sesion cerrada")
            //navigationController?.popToRootViewController(animated: true)
            let session = UserDefaults.standard
            session.removeObject(forKey: "email")
            session.synchronize()
            
            let vc = storyboard?.instantiateViewController(identifier: "HOME") as! UIViewController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)

        } catch let signOutError as NSError {
            print("Error al salir ", signOutError)
        }
    }
    
}
