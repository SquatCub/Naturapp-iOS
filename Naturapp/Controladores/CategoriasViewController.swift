//
//  CategoriasViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 30/06/21.
//

import UIKit
import Firebase

class CategoriasViewController: UIViewController {
    //Base de datos
    let db = Firestore.firestore()
    //Objeto personalizado de lugar
    var categorias = [Lugar]()
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    //Variable a mandar en el segue
    var categoriaActual: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationItem.hidesBackButton = true
        cargarCategorias()
    }
    
    func cargarCategorias()  {
        db.collection("categorias").addSnapshotListener() { (querySnapshot, err) in
            //Vaciar arreglo de chats
            self.categorias = []
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
                        guard let imagenFS = datos["imagen"] as? String else { return }
                        
                        
                        //Crear objeto y agregarlo al arreglo
                        let nuevoLugar = Lugar(nombre: nombreFS, imagen: imagenFS)
                        self.categorias.append(nuevoLugar)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

//Saber donde hago click en el dash
extension CategoriasViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        categoriaActual = categorias[indexPath.row].nombre
        performSegue(withIdentifier: "filtrado", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filtrado" {
            let destino = segue.destination as! FiltradoViewController
            destino.categoria = categoriaActual
        }
    }
}
//Datasource del carrusel
extension CategoriasViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorias.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "col", for: indexPath) as! MyCollectionViewCell
        cell.tituloLabel.text = categorias[indexPath.row].nombre
        
        let url = URL(string: categorias[indexPath.row].imagen)

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

extension CategoriasViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 160)
    }
}

