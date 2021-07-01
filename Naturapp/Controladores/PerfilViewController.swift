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
    @IBOutlet weak var cerrarButton: UIButton!
    @IBOutlet weak var nombreField: UITextField!
    @IBOutlet weak var guardarButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var edButton: UIBarButtonItem!
    @IBOutlet weak var cancButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        inicializarOutlets()
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
                self.nombreField.text = self.nombreLabel.text
                let urlString = dataDescription!["imagen"] as? String
                if (urlString != "noimage") {
                    let url = URL(string: urlString!)
                    DispatchQueue.main.async { [weak self] in
                        if let data = try? Data(contentsOf: url!) {
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.imageView.image = image
                                    self?.imageView.layer.cornerRadius = 75
                                }
                            }
                        }
                    }
                }
                
            } else {
                self.nombreLabel.text = "Sin nombre"
                self.correoLabel.text = email!
            }
        }
    }
    func inicializarOutlets() {
        nombreLabel.isHidden = false
        cerrarButton.isHidden = false
        cancButton.isEnabled = false
        edButton.isEnabled = true
        descLabel.isHidden = true
        nombreField.isHidden = true
        guardarButton.isHidden = true
        imageView.layer.cornerRadius = 75
        imageView.isUserInteractionEnabled = false
    }
    @IBAction func editarButton(_ sender: UIBarButtonItem) {
        descLabel.isHidden = false
        nombreLabel.isHidden = true
        cerrarButton.isHidden = true
        nombreField.isHidden = false
        guardarButton.isHidden = false
        cancButton.isEnabled = true
        edButton.isEnabled = false
        //MARK.-Agregar gestura a la imagen
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        
        //Agregar gestura a la imagen
        imageView.addGestureRecognizer(gestura)
        imageView.isUserInteractionEnabled = true
    }
    @IBAction func saveData(_ sender: UIButton) {
        //Checar si hay imagen
        guard let image = imageView.image, let datosImage = image.jpegData(compressionQuality: 0.2) else {
            print ("Error")
            return
        }
        let nombre = nombreField.text!
        let session = UserDefaults.standard
        let correo = session.value(forKey: "email") as? String
        let imageReferencia = Storage.storage().reference().child("perfiles").child(correo!)
        
        //Subir datos a Firestorage
        imageReferencia.putData(datosImage, metadata: nil) { (metadata, error) in
            if let err = error {
                print("Error al subir la imagen \(err.localizedDescription)")
            }
            imageReferencia.downloadURL { (url, error) in
                if let err = error {
                    print("Error al subir la imagen \(err.localizedDescription)")
                    return
                }
                guard let url = url else {
                    print("Error al crear url de la imagen")
                    return
                }
                //Subir a Firestore
                let dataReferencia = Firestore.firestore().collection("perfiles").document(correo!)
                let urlString = url.absoluteString
                let datosEnviar = ["imagen": urlString, "nombre": nombre, "usuario": correo!] as [String : Any]
                
                dataReferencia.setData(datosEnviar) { (error) in
                    if let err = error {
                        print("Error al mandar datos de imagen \(err.localizedDescription)")
                        return
                    } else {
                        let alerta = UIAlertController(title: "Correcto!", message: "Se actualizaron los datos", preferredStyle: .alert)
                        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default)
                        alerta.addAction(accionAceptar)
                        self.present(alerta, animated: true, completion: nil)
                        self.nombreLabel.text = nombre
                        print("Se guardo correctamente en FS")
                    }
                }
            }
        }
        inicializarOutlets()
        fillData()
    }
    
    @objc func clickImagen(gestura: UITapGestureRecognizer) {
        print("cambiar imagen")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    @IBAction func cancelEdit(_ sender: UIBarButtonItem) {
        inicializarOutlets()
        fillData()
    }
}
//MARK.- Protocolo para la gestura de la imagen y seleccion de imagen
extension PerfilViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Que se hara cuando el usuario selecciona alguna imagen
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = imagenSeleccionada
            imageView.layer.cornerRadius = 75
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

