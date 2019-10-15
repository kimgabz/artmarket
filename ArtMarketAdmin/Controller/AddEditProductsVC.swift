//
//  AddEditProductsVC.swift
//  ArtMarketAdmin
//
//  Created by Kim Harold Gabiana on 10/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditProductsVC: UIViewController {

    @IBOutlet weak var productNameTx: UITextField!
    @IBOutlet weak var productPriceTx: UITextField!
    @IBOutlet weak var productDesc: UITextView!
    @IBOutlet weak var productImgView: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: RoundedButton!
    
    
    var selectedCategory : Category!
    var productToEdit : Product?
    var name = ""
    var price = 0.0
    var productDescription = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped))
        tap.numberOfTapsRequired = 1
        productImgView.isUserInteractionEnabled = true
        productImgView.clipsToBounds = true
        productImgView.addGestureRecognizer(tap)
        
        if let product = productToEdit {
            productNameTx.text = product.name
            productDesc.text = product.productDescription
            productPriceTx.text = String(product.price)
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: product.imageUrl) {
                productImgView.contentMode = .scaleAspectFill
                productImgView.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imgTapped() {
        launchImagePicker()
    }

    @IBAction func addBt(_ sender: Any) {
        uploadImageThenDocument()
    }
    
    func uploadImageThenDocument() {
        guard let image = productImgView.image,
        let name = productNameTx.text, name.isNotEmpty,
        let description = productDesc.text, description.isNotEmpty,
        let priceString = productPriceTx.text, priceString.isNotEmpty,
            let price = Double(priceString) else {
                simpleAlert(title: "Missing fields", msg: "Please fill out all required fields")
                return
        }
        
        self.name = name
        self.productDescription = description
        self.price = price
        
        activityIndicator.startAnimating()
        
        // Turn the image into data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        // create a storage image reference
        let imageRef = Storage.storage().reference().child("/productImages/\(name).jpg")
        
        // set the meta data
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // upload data
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload image")
            }
            
            // retrieve the download URL
            imageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    self.handleError(error: error, msg: "Unable to download URL")
                    return
                }
                
                guard let url = url else { return }
//                print(url)
                // Upload the new product document to the Firestore products collection
                self.uploadDocument(url: url.absoluteString)
                
            })
        }
        
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var product = Product.init(name: name,
                                   id: "",
                                   category: selectedCategory.id,
                                   price: price,
                                   productDescription: productDescription,
                                   imageUrl: url)
        if let productToEdit = productToEdit {
            // editing the product
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
            product.id = productToEdit.id
        }
        else {
            // adding new product
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }
        
        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "Unable to upload firestore document")
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
        activityIndicator.stopAnimating()
    }
}

extension AddEditProductsVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        productImgView.contentMode = .scaleAspectFill
        productImgView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
