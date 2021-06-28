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

class LugarViewController: UIViewController {
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
    //Outlets del storyboard
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var mapMK: MKMapView!
    @IBOutlet weak var descripcionLabel: UILabel!
    
    
    // Manager para usar el GPS
    var manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nombre!
        
        
        mapMK.delegate = self
        
        getData()
    }
    
    func getData() {
        let docRef = db.collection("lugares").document(nombre!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.lugar = "\(dataDescription!["nombre"] ?? "Sin nombre")"
                self.descripcionLabel.text = "\(dataDescription!["descripcion"] ?? "No hay descripción disponible")"

                self.latitud = Float(dataDescription!["latitud"] as! Substring)
                self.longitud = Float(dataDescription!["longitud"] as! Substring)
                let urlString = dataDescription!["imagen"] as? String
                let url = URL(string: urlString!)
                self.lat = CLLocationDegrees(self.latitud!)
                self.lon = CLLocationDegrees(self.longitud!)
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
    
}
// Extension del ViewController donde estan los delegados de la ubicacion y de la barra de busqueda
extension LugarViewController: CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    /*// Funcion para obtener las coordenadas del usuario
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Variable segura en caso de no tener permisos no crashe la app
        guard let ubicacion = locations.first else {
            return
        }
    }
    // En caso de error o no tener permisos
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener la ubicacion \(error)")
    }
    // Funcion que se activa cuando se envia el contenido de la SearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       // Convierte coordenadas en algo amigable al usuario, servira para añadir puntos al mapa
       let geocoder = CLGeocoder()
        // En caso de tener algo en la barra de busque
    }
    
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D) {
        guard let coordenadasOrigen = manager.location?.coordinate else {
            return
        }
        // Crear lugar de origen-destino
        let origenPlaceMark = MKPlacemark(coordinate: coordenadasOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)

        // Crear objeto mapkit item
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        // Solicitud de ruta
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = origenItem
        solicitudDestino.destination = destinoItem
        // Definir como se va a viajar
        solicitudDestino.transportType = .automobile
        solicitudDestino.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            // Desenvolver la respuesta
            guard let respuestaSegura = respuesta else {
                if let error = error {
                    print("Error al calcular la ruta \(error.localizedDescription)")
                }
                return
            }
            // Si success
            //Obtenemos las rutas trazadas y las eliminamos
            let overlay = self.mapMK.overlays
            self.mapMK.removeOverlays(overlay)
            //Obtenemos la nueva ruta
            let ruta = respuestaSegura.routes[0]
            // Agregar superposicion
            self.mapMK.addOverlay(ruta.polyline)
            self.mapMK.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
            let distancia = ruta.distance/1000
            // Alerta para mostrar la distancia
            let alerta = UIAlertController(title: "Distancia", message: "La distancia es de \(distancia) KM", preferredStyle: .alert)
            let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            alerta.addAction(accionAceptar)
            self.present(alerta, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .white
        return renderizado
    }*/
}
