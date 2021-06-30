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
    //Base de datos
    let db = Firestore.firestore()
    //Outlets del SB
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var correoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillData()
        
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
    func fillData() {
        let session = UserDefaults.standard
        let email = session.value(forKey: "email") as? String
        
        let docRef = db.collection("perfiles").document(email!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.nombreLabel.text = "\(dataDescription!["nombre"] ?? "Sin nombre")"
                self.correoLabel.text = "\(dataDescription!["usuario"] ?? "No hay correo disponible")"
                let urlString = dataDescription!["imagen"] as? String
                if (urlString != "noimage") {
                    let url = URL(string: urlString!)
                    DispatchQueue.main.async { [weak self] in
                        if let data = try? Data(contentsOf: url!) {
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.imageView.image = image
                                    self?.imageView.contentMode = .scaleAspectFill
                                    self?.imageView.layer.cornerRadius = 5
                                }
                            }
                        }
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
}
