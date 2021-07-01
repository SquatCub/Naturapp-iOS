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
import MapKit
import CoreLocation
import DropDown

class CompartirViewController: UIViewController {
    //Base de datos
    let db = Firestore.firestore()
    //Outlets del storyboard
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nombreLabel: UITextField!
    @IBOutlet weak var descripcionLabel: UITextView!
    //Outlets para el Dropdown menu
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var buttonDown: UIButton!
    let dropDown = DropDown()
    var dataDown = [String]()
    
    // Manager para usar el GPS
    var manager = CLLocationManager()
    // Variables a utilizar en la ubicacion
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategorias()
        initializeLocation()
        //Inicializa la gestura de la imagen
        initializeImage()
        //Text field descripcion
        descripcionLabel.layer.borderWidth = 1
        descripcionLabel.layer.borderColor = CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        //
        
    }
    
    
    @IBAction func compartirButtton(_ sender: UIButton) {
        //Checar si hay imagen
        guard let image = image.image, let datosImage = image.jpegData(compressionQuality: 0.2) else {
            print ("Error")
            return
        }
        let nombre = nombreLabel.text!
        let categoria = buttonDown.titleLabel?.text ?? "Otra"
        print(categoria)
        
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
                let datosEnviar = ["imagen": urlString, "nombre": nombre, "categoria": categoria, "descripcion": self.descripcionLabel.text ?? "", "latitud": "\(self.latitud!)", "longitud": "\(self.longitud!)"] as [String : Any]
                
                dataReferencia.setData(datosEnviar) { (error) in
                    if let err = error {
                        print("Error al mandar datos de imagen \(err.localizedDescription)")
                        return
                    } else {
                        let alerta = UIAlertController(title: "Correcto!", message: "El lugar se ha compartido correctamente", preferredStyle: .alert)
                        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default)
                        alerta.addAction(accionAceptar)
                        self.present(alerta, animated: true, completion: nil)
                        self.nombreLabel.text = ""
                        self.descripcionLabel.text = ""
                        self.image.contentMode = .scaleAspectFit
                        self.image.image = #imageLiteral(resourceName: "preview")
                        print("Se guardo correctamente en FS")
                    }
                }
            }
 
        }
    }
    
    func initializeImage() {
        //Agregar gestura a la imagen
        image.layer.cornerRadius = 10
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        image.addGestureRecognizer(gestura)
        image.isUserInteractionEnabled = true
    }
    
    func initializeLocation() {
        //Asignacion de delegado y funciones para la ubicacion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        //Mejorar la presicion de la ubicacion
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //Monitorear ubicacion en todo momento
        manager.startUpdatingLocation()
    }
    
    func loadCategorias() {
        db.collection("categorias").addSnapshotListener() { (querySnapshot, err) in
            //Vaciar arreglo de lugares
            self.dataDown = []
            if let e = err {
                print("Error al obtener datos \(e.localizedDescription)")
            } else {
                if let snapshotDocumentos = querySnapshot?.documents {
                    for document in snapshotDocumentos {
                        print("\(document.data())")
                        //Crear objeto Mensaje
                        let datos = document.data()
                        //Obtener parametros
                        guard let nombreFS = datos["nombre"] as? String else { return }
                        
                        print(datos)
                        //Crear objeto y agregarlo al arreglo
                        self.dataDown.append(nombreFS)
                    }
                    DispatchQueue.main.async {
                        //self.collectionView.reloadData()
                        self.dropDown.anchorView = self.dropView
                        self.dropDown.dataSource = self.dataDown
                        self.dropDown.selectionAction = { [self] (index: Int, item: String) in
                            self.buttonDown.setTitle(" \(item)", for: .normal)
                        }
                    }
                }
            }
        }
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
    @IBAction func showDrop(_ sender: UIButton) {
        dropDown.show()
    }
}

//Extenciones para la gestura
extension CompartirViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Que se hara cuando el usuario selecciona alguna imagen
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            image.image = imagenSeleccionada
            image.contentMode = .scaleAspectFill
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// Extension del ViewController donde estan los delegados de la ubicacion y de la barra de busqueda
extension CompartirViewController: CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    // Funcion para obtener las coordenadas del usuario
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Variable segura en caso de no tener permisos no crashe la app
        guard let ubicacion = locations.first else {
            return
        }
        latitud = ubicacion.coordinate.latitude
        longitud = ubicacion.coordinate.longitude
    }
    // En caso de error o no tener permisos
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener la ubicacion \(error)")
    }
}
