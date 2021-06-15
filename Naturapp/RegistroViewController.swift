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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //Accion para registrarse
    @IBAction func registrarseBT(_ sender: UIButton) {
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
                        self.performSegue(withIdentifier: "registro", sender: self)
                    }
                }
            }
        } else {
            mensajeAlerta(mensaje: "Las contraseñas no coinciden")
        }
    }
    
    //Funcion para mostrar alertas
    func mensajeAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    

}
