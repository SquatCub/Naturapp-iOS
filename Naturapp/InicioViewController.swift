//
//  InicioViewController.swift
//  Naturapp
//
//  Created by Brandon Rodriguez Molina on 19/06/21.
//

import UIKit
import Firebase
import GoogleSignIn

class InicioViewController: UIViewController {
    //Base de datos
    let db = Firestore.firestore()
    //Objeto personalizado de lugar
    var lugares = [Lugar]()
    //Outlets del storyboard
    @IBOutlet weak var collectionView: UICollectionView!
    //Variable a mandar en el segue
    var lugarActual: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: view.frame.size.width/2 - 20, height: 160)
        collectionView.collectionViewLayout = collectionLayout
        collectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "col")
        collectionView.delegate = self
        collectionView.dataSource = self
        initialSetup()
        // Do any additional setup after loading the view.
    }

    @IBAction func cerrarSesion(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Sesion cerrada")
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error al salir ", signOutError)
        }
    }
    
    func initialSetup() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        cargarLugares()
    }
    
    func cargarLugares() {
        db.collection("lugares").addSnapshotListener() { (querySnapshot, err) in
            //Vaciar arreglo de chats
            self.lugares = []
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
                        self.lugares.append(nuevoLugar)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
}

//Saber donde hago click en el dash
extension InicioViewController: UICollectionViewDelegate {
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
extension InicioViewController: UICollectionViewDataSource {
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

extension InicioViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 160)
    }
}
