//
//  FiltradoViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 30/06/21.
//

import UIKit
import Firebase

class FiltradoViewController: UIViewController {
    //Variable del segue
    var categoria: String?
    //Base de datos
    let db = Firestore.firestore()
    //Objeto personalizado de lugar
    var lugares = [Lugar]()
    //Variable a mandar en el segue
    var lugarActual: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = categoria!
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: view.frame.size.width/2 - 20, height: 160)
        collectionView.collectionViewLayout = collectionLayout
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "col")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initialSetup()
    }
    
    func initialSetup() {
        navigationController?.isNavigationBarHidden = false
        cargarLugares()
    }
    
    func cargarLugares() {
        db.collection("lugares").whereField("categoria", isEqualTo: " \(categoria!)")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshotDocumentos = querySnapshot?.documents {
                        for document in snapshotDocumentos {
                            //Obtener data
                            let datos = document.data()
                            //Obtener parametros
                            guard let nombreFS = datos["nombre"] as? String else { return }
                            guard let imagenFS = datos["imagen"] as? String else { return }
                            //Crear objeto y agregarlo al arreglo
                            let nuevoLugar = Lugar(nombre: nombreFS, imagen: imagenFS)
                            self.lugares.append(nuevoLugar)
                            print("aah")
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
        }

    }
}

//Saber donde hago click en el dash
extension FiltradoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        lugarActual = lugares[indexPath.row].nombre
        performSegue(withIdentifier: "lugar", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lugar" {
            let destino = segue.destination as! LugarViewController
            destino.nombre = lugarActual
        }
    }
}
//Datasource del carrusel
extension FiltradoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lugares.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "col", for: indexPath) as! MyCollectionViewCell
        cell.tituloLabel.text = lugares[indexPath.row].nombre
        
        let url = URL(string: lugares[indexPath.row].imagen)

        DispatchQueue.main.async { [weak self] in
            if let data = try? Data(contentsOf: url!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
}

extension FiltradoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 160)
    }
}


