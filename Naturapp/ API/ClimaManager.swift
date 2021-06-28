//
//  ClimaManager.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 27/06/21.
//

import Foundation
import CoreLocation

protocol ClimaManagerDelegado {
    func actualizarClima(clima: ClimaModelo)
    func errorClima()
}

struct ClimaManager {
    let climaURL = "https://api.openweathermap.org/data/2.5/weather?appid=76deb8d9c821504200426f99196a94ed&units=metric&lang=es"
    //Quien sea el delegado debera implementar este protocolo
    var delegado: ClimaManagerDelegado?
    
    //Para buscar por latitud, longitud
    func buscarClimaGps(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(climaURL)&lat=\(lat)&lon=\(lon)"
        realizarSolicitud(urlString: urlString)
    }
    
    //Solicitud a la API
    func realizarSolicitud(urlString:String) {
        // 1. Crear url
        if let url = URL(string: urlString) {
            // 2. Crear url sesion
            let session = URLSession(configuration: .default)
            // 3. Asignarle una tarea a la url session
            let tarea = session.dataTask(with: url) { (datos, respuesta, error) in
                if error != nil {
                    print("Error al obtener datos: \(error! )")
                    return
                }
                if let datosSeguros = datos {
                    if let objClima = self.parsearJSON(datosClima: datosSeguros) {
                        // Mandar objeto al VC
                        //let ClimaVC = ViewController()
                        //ClimaVC.actualizarClima(objClima: objClima)
                        
                        //Designar un delegado
                        self.delegado?.actualizarClima(clima: objClima)
                    } else {
                        self.delegado?.errorClima()
                    }
                }
            }
            // 4. Iniciar la tarea
            tarea.resume()
        }
    }
    
    //Decodificador JSON
    func parsearJSON(datosClima: Data) -> ClimaModelo? {
        let decodificador = JSONDecoder()
        do {
            let datosDecodificados = try decodificador.decode(ClimaDatos.self, from: datosClima)
            
            // Nos ayuda a saber que imagen colocar
            let id = datosDecodificados.weather[0].id
            let icon = datosDecodificados.weather[0].icon
            let temp = datosDecodificados.main.temp
            let desc = datosDecodificados.weather[0].description
            let time = Array(icon)[2]
                        
            // Modelo clima que contiene toda la informacion que sera usada en VC
            let objClima = ClimaModelo(temp: temp, id: id, icon: icon, desc: desc, time: time)
            return objClima
            
        } catch {
                print("Error al decodificar datos: \(error.localizedDescription)")
            return nil
        }
    }
}
