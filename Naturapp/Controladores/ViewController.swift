//
//  ViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 14/06/21.
//

import UIKit
import iCarousel
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    //Inicializacion del carrusel
    let myCarousel: iCarousel = {
        let view = iCarousel()
        view.type = .linear
        return view
    }()
    
    //Outlets del storyboard
    @IBOutlet weak var correoTextField: UITextField!
    @IBOutlet weak var contraseñaTextField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkSession()
        //Se agrega el carrusel a la vista principal
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        view.addSubview(myCarousel)
        myCarousel.dataSource = self
        myCarousel.delegate = self
        myCarousel.autoscroll = -0.2
        myCarousel.frame = CGRect(x: 0, y: 40, width: view.frame.size.width, height: 100)
        
        initialSetup()
    }
    
    //Accion para iniciar sesion
    @IBAction func loginButton(_ sender: UIButton) {
        indicator.startAnimating()
        if let email = correoTextField.text, let password = contraseñaTextField.text  {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    var msj = ""
                    switch e.localizedDescription {
                        case "The password is invalid or the user does not have a password.":
                            msj = "Constraseña incorrecta"
                        break
                        case "There is no user record corresponding to this identifier. The user may have been deleted.":
                            msj = "El correo no está registrado"
                        break
                        case "The email address is badly formatted.":
                            msj = "Correo con formato incorrecto"
                        break
                        default:
                            msj = "Error desconocido"
                            break
                    }
                    self.mensajeAlerta(mensaje: msj)
                    self.indicator.stopAnimating()
                } else {
                    self.performSegue(withIdentifier: "login", sender: self)
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    //Funcion para mostrar alertas
    func mensajeAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
    
    //Metodos para el carrusel
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 5
    }
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 100))
        let imageView = UIImageView(frame: view.bounds)
        view.addSubview(imageView)
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "img\(index+1)")
        return view
    }
    
    func initialSetup() {
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: correoTextField.frame.height - 7, width: correoTextField.frame.width+30, height: 0.6)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: contraseñaTextField.frame.height - 7, width: contraseñaTextField.frame.width+30, height: 0.6)
        bottomLine2.backgroundColor = UIColor.gray.cgColor
        
        correoTextField.borderStyle = UITextField.BorderStyle.none
        contraseñaTextField.borderStyle = UITextField.BorderStyle.none
        
        correoTextField.layer.addSublayer(bottomLine)
        contraseñaTextField.layer.addSublayer(bottomLine2)
    }
    func checkSession() {
        let session = UserDefaults.standard
        if let email = session.value(forKey: "email") as? String {
            performSegue(withIdentifier: "login", sender: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    @IBAction func googleButton(_ sender: UIButton) {
        indicator.startAnimating()
        GIDSignIn.sharedInstance()?.signIn()
    }
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let result = authResult, error == nil {
                    print("Sesion iniciada con gugul")
                    self.performSegue(withIdentifier: "login", sender: self)
                    self.indicator.stopAnimating()
                } else {
                    print("Error")
                }
                
            }
        }
        self.indicator.stopAnimating()
    }
}
