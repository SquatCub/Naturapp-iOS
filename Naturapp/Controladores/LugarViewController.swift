//
//  LugarViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 23/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import MapKit

class LugarViewController: UIViewController, ClimaManagerDelegado {
    
    //Base de datos
    let db = Firestore.firestore()
    //Variable del segue
    var nombre: String?
    //Variables para el lugar
    var lugar: String?
    var latitud: Float?
    var longitud: Float?
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    var comentarios = [Comentario]()
    //Outlets del storyboard
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mapMK: MKMapView!
    @IBOutlet weak var descTitulo: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var climaTitulo: UILabel!
    @IBOutlet weak var ubicacionTitulo: UILabel!
    @IBOutlet weak var comentarioField: UITextField!
    @IBOutlet weak var comentariosTable: UITableView!
    @IBOutlet weak var categoriaLabel: UILabel!
    
    //Outlets para api clima
    @IBOutlet weak var climaImage: UIImageView!
    @IBOutlet weak var descClima: UILabel!
    @IBOutlet weak var gradosClima: UILabel!
    @IBOutlet weak var vistaContent: UIView!
    @IBOutlet weak var climaStack: UIStackView!
    
    
    // Manager para usar el GPS
    var manager = CLLocationManager()
    //Manager Clima
    var climaManager = ClimaManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nombre!
        
        //Registro de la celda custom
        comentariosTable.register(UINib(nibName: "ComentarioTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        mapMK.delegate = self
        //Establecer esta clase como el delegado del ClimaManager
        climaManager.delegado = self

        
        getData()
        cargarComentarios()
    }
    
    func getData() {
        let docRef = db.collection("lugares").document(nombre!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.lugar = "\(dataDescription!["nombre"] ?? "Sin nombre")"
                self.descripcionLabel.text = "\(dataDescription!["descripcion"] ?? "No hay descripción disponible")"
                self.categoriaLabel.text = "\(dataDescription!["categoria"] ?? "Sin categoria")"
                self.latitud = Float(dataDescription!["latitud"] as! Substring)
                self.longitud = Float(dataDescription!["longitud"] as! Substring)
                let urlString = dataDescription!["imagen"] as? String
                let url = URL(string: urlString!)
                self.lat = CLLocationDegrees(self.latitud!)
                self.lon = CLLocationDegrees(self.longitud!)
                self.climaManager.buscarClimaGps(lat: self.lat!, lon: self.lon!)
                DispatchQueue.main.async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.image.image = image
                                self?.image.contentMode = .scaleAspectFill
                                self?.image.layer.cornerRadius = 5
                            }
                        }
                    }
                }
                self.showLocation()
            } else {
                print("Document does not exist")
            }
        }
    }
    func showLocation() {
        // Variable localizacion para castear nuestras coordenadas
        let localizacion = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        // Que tan separada estara nuestra camara de la ubicacion en el mapa
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // Region que determina a donde se movera el mapa
        let region = MKCoordinateRegion(center: localizacion, span: spanMapa)
        // Se establecen los parametros para agregat la region y para mostrarla
        mapMK.setRegion(region, animated: true)
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = region.center
        anotacion.title = lugar
        self.mapMK.addAnnotation(anotacion)
        mapMK.showsUserLocation = true
    }
    @IBAction func openMap(_ sender: UIButton) {
        let url = URL(string:"http://maps.apple.com/?daddr=\(latitud!),\(longitud!)")
            UIApplication.shared.open(url!)

    }
    // Recibo de datos desde el manager
    func actualizarClima(clima: ClimaModelo) {
        DispatchQueue.main.async {
            self.gradosClima.text = clima.tempString+"º C"
            self.descClima.text = clima.desc.capitalizingFirstLetter()
            let imgURL = "https://openweathermap.org/img/wn/\(clima.icon)@4x.png"
            self.cargarImagen(urlString: imgURL)
            if clima.time == "n" {
                self.climaStack.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.climaTitulo.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.gradosClima.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.descClima.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                self.climaStack.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                self.climaTitulo.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.gradosClima.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.descClima.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    //Imagenes del clima dinamicas
    func cargarImagen(urlString: String) {
            //1.- Obtener los datos
            guard let url = URL(string: urlString) else {
                return
            }
            let tareaObtenerDatos = URLSession.shared.dataTask(with: url) { (datos, _, error) in
                guard let datosSeguros = datos, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    //2.- Convertir los datos en imagen
                    let imagen = UIImage(data: datosSeguros)
                    //3.- Asignar la imagen a la imagen previamente creada
                    self.climaImage.image = imagen
                }
            }
            tareaObtenerDatos.resume()
    }
    // En caso de error
    func errorClima() {
        DispatchQueue.main.async {
            self.descClima.text = "No se encontro la ciudad"
        }
    }
    
    func cargarComentarios() {
        db.collection("lugares").document(nombre!).collection("comentarios").addSnapshotListener() { (querySnapshot, err) in
            //Vaciar arreglo de chats
            self.comentarios = []
            if let e = err {
                print("Error al obtener datos \(e.localizedDescription)")
            } else {
                if let snapshotDocumentos = querySnapshot?.documents {
                    for document in snapshotDocumentos {
                        print("\(document.data())")
                        //Crear objeto Mensaje
                        let datos = document.data()
                        //Obtener parametros
                        guard let contenido = datos["comentario"] as? String else { return }
                        guard let usuario = datos["usuario"] as? String else { return }
                        
                        
                        //Crear objeto y agregarlo al arreglo
                        let nuevoComentario = Comentario(comentario: contenido, usuario: usuario)
                        self.comentarios.append(nuevoComentario)
                        
                        DispatchQueue.main.async {
                            self.comentariosTable.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func comentarButton(_ sender: UIButton) {
        let id = UUID().uuidString
        let session = UserDefaults.standard
        let email = session.value(forKey: "email") as? String
        db.collection("lugares").document(nombre!).collection("comentarios").document(id).setData(["usuario": email!, "comentario": comentarioField.text!]) { (error) in
            //En caso de error
            if let e = error {
                print("Error al guardar en Firestore \(e.localizedDescription)")
            } else {
                //En caso de enviar
                print("Se guardo la info en firestore")
                let alerta = UIAlertController(title: "Perfecto!", message: "Haz compartido tu experiencia del lugar", preferredStyle: .alert)
                let accionAceptar = UIAlertAction(title: "Aceptar", style: .default)
                alerta.addAction(accionAceptar)
                self.present(alerta, animated: true, completion: nil)
                self.comentarioField.text = ""
            }
        }

    }
    

    
}
// Extension del ViewController donde estan los delegados de la ubicacion y de la barra de busqueda
extension LugarViewController: CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

//Extension para delegado y datasource de la tabla de comentarios
extension LugarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comentarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = comentariosTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ComentarioTableViewCell
        celda.comentarioLabel.text = comentarios[indexPath.row].comentario
        let perfil = self.db.collection("perfiles").document(comentarios[indexPath.row].usuario)
        perfil.getDocument{ (document, error) in
            if let document = document, document.exists {
                celda.usuarioLabel.text = "De: \(document.data()!["nombre"]!)"
                let urlString = document.data()!["imagen"] as? String
                let url = URL(string: urlString!)

                DispatchQueue.main.async { [weak self] in
                    if let data = try? Data(contentsOf: url!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                celda.contactoImagen.image = image
                            }
                        }
                    }
                }
                } else {
                    print("Document does not exist")
                }
        }
        return celda
    }
    
    
}

