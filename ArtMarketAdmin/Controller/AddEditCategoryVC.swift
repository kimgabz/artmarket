//
//  AddEditCategoryVC.swift
//  ArtMarketAdmin
//
//  Created by Kim Harold Gabiana on 9/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditCategoryVC: UIViewController {
    
    @IBOutlet weak var nameTx: UITextField!
    @IBOutlet weak var categoryImg: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    
    var categoryToEdit : Category?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        categoryImg.isUserInteractionEnabled = true
        categoryImg.clipsToBounds = true
        categoryImg.addGestureRecognizer(tap)
        
        if let category = categoryToEdit {
            nameTx.text = category.name
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: category.imgUrl) {
                categoryImg.contentMode = .scaleToFill
                categoryImg.kf.setImage(with: url)
                
            }
        }
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }

    @IBAction func addCategoryBt(_ sender: Any) {
        activityIndicator.startAnimating()
        uploadImageThenDocument()
    }
    
    func uploadImageThenDocument() {
        guard let image = categoryImg.image,
            let categoryName = nameTx.text, categoryName.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Must add category image and name")
                return
        }
        
        // Turn the image into data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        // Create an storage image reference -> location in Firestorage for it to be stored
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName).jpg")
        
        // Set meta data
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Upload the data
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            // Once the image is uploaded, retrieve the download URL
            imageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                guard let url = url else {return}
                //  print(url)
                
                // Upload new category document to the Firestore categories collection
                self.uploadDocument(url: url.absoluteString)
                
            })
        }
    }
    
    fileprivate func handleError(_ error: Error) {
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: "Unable to upload image")
        self.activityIndicator.stopAnimating()
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var category = Category.init(name: nameTx.text!, id: "", imgUrl: url, timeStamp: Timestamp())
        
        if let categoryToEdit_ = categoryToEdit {
            // editing existing category
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit_.id)
            category.id = categoryToEdit_.id
        }
        else {
            // new Category
            docRef = Firestore.firestore().collection("categories").document()
            category.id = docRef.documentID
        }

        let data = Category.modelToData(category: category)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        categoryImg.contentMode = .scaleAspectFill
        categoryImg.image = image
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
