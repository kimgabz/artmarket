//
//  ProductsVC.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 7/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProductsVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var products = [Product]()
    var category: Category!
    var listener : ListenerRegistration!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let product = Product.init(name: "Landscape", id: "asdfadfa", category: "Nature", price: 24.99, productDescription: "Swiss alps", imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Parque_Eagle_River%2C_Anchorage%2C_Alaska%2C_Estados_Unidos%2C_2017-09-01%2C_DD_02.jpg/440px-Parque_Eagle_River%2C_Anchorage%2C_Alaska%2C_Estados_Unidos%2C_2017-09-01%2C_DD_02.jpg", timeStamp: Timestamp(), stock: 0, favorite: false)
//        products.append(product)
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.ProductCell, bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
        
        setupQuery()
    }
    
    func setupQuery() {
        listener = db.products(category: category.id).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (documentChange) in
                let data = documentChange.document.data()
                let product = Product.init(data: data)
                
                switch documentChange.type {
                case .added:
                    self.onDocumentAdded(document: documentChange, product: product)
                case .modified:
                    self.onDocumentModified(document: documentChange, product: product)
                case .removed:
                    self.onDocumentRemoved(document: documentChange)
                @unknown default:
                    fatalError()
                }
            })
        })
    }
}

extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    func onDocumentAdded(document: DocumentChange, product: Product) {
        let newIndex = Int(document.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.fade )
    }
    
    func onDocumentModified(document: DocumentChange, product: Product) {
        if document.oldIndex == document.newIndex {
            let index = Int(document.newIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.none)
        }
        else {
            let oldIndex = Int(document.oldIndex)
            let newIndex = Int(document.newIndex)
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(document: DocumentChange) {
        let oldIndex = Int(document.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ProductCell, for: indexPath) as? ProductCell {
            
            cell.configureCell(product: products[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let selectedProduct = products[indexPath.row]
        vc.product = selectedProduct
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
