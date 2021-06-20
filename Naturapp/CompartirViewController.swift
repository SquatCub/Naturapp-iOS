//
//  CompartirViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 19/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CompartirViewController: UIViewController {
    //Outlets del storyboard
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nombreLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeImage()
    }
    
    
    @IBAction func compartirButtton(_ sender: UIButton) {
        //Checar si hay imagen
        guard let image = image.image, let datosImage = image.jpegData(compressionQuality: 1.0) else {
            print ("Error")
            return
        }
        let nombre = nombreLabel.text!
        let imageReferencia = Storage.storage().reference().child("lugares").child(nombre)
        
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
                let dataReferencia = Firestore.firestore().collection("lugares").document(nombre)
                let urlString = url.absoluteString
                let datosEnviar = ["imagen": urlString, "nombre": nombre]
                
                dataReferencia.setData(datosEnviar) { (error) in
                    if let err = error {
                        print("Error al mandar datos de imagen \(err.localizedDescription)")
                        return
                    } else {
                        let alerta = UIAlertController(title: "Correcto!", message: "Datos guardados correctamente", preferredStyle: .alert)
                        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default)
                        alerta.addAction(accionAceptar)
                        self.present(alerta, animated: true, completion: nil)
                        
                        print("Se guardo correctamente en FS")
                    }
                }
            }
        }
    }
    
    func initializeImage() {
        //Agregar gestura a la imagen
        image.layer.cornerRadius = 30
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        image.addGestureRecognizer(gestura)
        image.isUserInteractionEnabled = true
    }
    
    //Funcion de gestura
    @objc func clickImagen(gestura: UITapGestureRecognizer) {
        print("cambiar imagen")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
}

//Extenciones para la gestura
extension CompartirViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Que se hara cuando el usuario selecciona alguna imagen
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            image.image = imagenSeleccionada
            image.layer.cornerRadius = 50
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
