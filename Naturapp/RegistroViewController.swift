//
//  RegistroViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 15/06/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistroViewController: UIViewController {
    //Inicializacion de la db
    let db = Firestore.firestore()
    //Outlets del storyboard
    @IBOutlet weak var nombreTF: UITextField!
    @IBOutlet weak var correoTF: UITextField!
    @IBOutlet weak var contraseña1TF: UITextField!
    @IBOutlet weak var contraseña2TF: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
    
    //Accion para registrarse
    @IBAction func registrarseBT(_ sender: UIButton) {
        indicator.startAnimating()
        if(contraseña1TF.text == contraseña2TF.text) {
            if let email = correoTF.text, let nombre = nombreTF.text,  let password = contraseña1TF.text  {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        print("Error al crear usuario \(e.localizedDescription)")
                        var msj = ""
                        switch e.localizedDescription {
                            case "The email address is already in use by another account.":
                                msj = "Correo ya en uso por otro usuario"
                            break
                            case "The email address is badly formatted.":
                                msj = "Correo con formato incorrecto"
                            break
                            case "The password must be 6 characters long or more.":
                                msj = "La contraseña debe tener mas de 6 caracteres "
                            break
                            default:
                                msj = "Error desconocido"
                                break
                        }
                        self.mensajeAlerta(mensaje: msj)
                        self.indicator.stopAnimating()
                    } else {
                        let documentoNombre = email
                        self.db.collection("perfiles").document(documentoNombre).setData(["usuario": email, "nombre": nombre, "imagen": "noimage"]) { (error) in
                            //En caso de error
                            if let e = error {
                                print("Error al guardar en Firestore \(e.localizedDescription)")
                            } else {
                                //En caso de enviar
                                print("Se guardo la info en firestore")
                            }
                        }
                        self.indicator.stopAnimating()
                        self.performSegue(withIdentifier: "registro", sender: self)
                    }
                }
            }
        } else {
            self.indicator.stopAnimating()
            mensajeAlerta(mensaje: "Las contraseñas no coinciden")
        }
    }
    
    //Funcion para mostrar alertas
    func mensajeAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    func initialSetup() {
        navigationController?.isNavigationBarHidden = false
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: nombreTF.frame.height - 7, width: nombreTF.frame.width, height: 0.6)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: correoTF.frame.height - 7, width: correoTF.frame.width, height: 0.6)
        bottomLine2.backgroundColor = UIColor.gray.cgColor
        let bottomLine3 = CALayer()
        bottomLine3.frame = CGRect(x: 0.0, y: contraseña1TF.frame.height - 7, width: contraseña1TF.frame.width, height: 0.6)
        bottomLine3.backgroundColor = UIColor.gray.cgColor
        let bottomLine4 = CALayer()
        bottomLine4.frame = CGRect(x: 0.0, y: contraseña2TF.frame.height - 7, width: contraseña2TF.frame.width, height: 0.6)
        bottomLine4.backgroundColor = UIColor.gray.cgColor
        
        nombreTF.borderStyle = UITextField.BorderStyle.none
        correoTF.borderStyle = UITextField.BorderStyle.none
        contraseña1TF.borderStyle = UITextField.BorderStyle.none
        contraseña2TF.borderStyle = UITextField.BorderStyle.none
        
        contraseña1TF.disableAutoFill()
        contraseña2TF.disableAutoFill()
        
        
        nombreTF.layer.addSublayer(bottomLine)
        correoTF.layer.addSublayer(bottomLine2)
        contraseña1TF.layer.addSublayer(bottomLine3)
        contraseña2TF.layer.addSublayer(bottomLine4)
        
    }

}

extension UITextField {
    func disableAutoFill() {
        if #available(iOS 14, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
