//
//  ViewController.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 3/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {

    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loginBt: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // variables
    var categories = [Category]()
    var selectedCategory: Category!
    var db : Firestore!
    var listener : ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupCollection()
        setupAnonymousUser()
        
//        fetchDocument()
//        fetchCollection()
//        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        setCategoriesListener()
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            // We are Logged in
            loginBt.title = "Logout"
            if userService.userListener == nil {
                userService.getCurrentUser()
            }
        }
        else {
            loginBt.title = "Login"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()
    }

    @IBAction func loginOutClicked(_ sender: Any) {
    
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        }
        else {
            do {
                try Auth.auth().signOut()
                userService.logoutUser()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                    }
                    self.presentLoginController()
                }
            }
            catch {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        }

    }
    
    fileprivate func setupCollection() {
        //        let category = Category.init(name: "Nature", id: "lkdnfadfglka", imgUrl: "https://static.scientificamerican.com/sciam/cache/file/EAF12335-B807-4021-9AC95BBA8BEE7C8D_source.jpg?w=590&h=800&74A94564-944F-4349-96BD18788411EAA6", isActive: true, timeStamp: Timestamp())
        //        categories.append(category)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Identifiers.CategoryCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
    }
    
    fileprivate func setupAnonymousUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (authDataResult, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                }
            }
        }
    }
    
    fileprivate func setCategoriesListener() {
        listener = db.categories.addSnapshotListener({ (snap, error) in
            //        listener = db.collection("categories").addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (body) in
                let data = body.document.data()
                let category = Category.init(data: data)
                
                switch body.type {
                case .added:
                    self.onDocumentAdded(document: body, category: category)
                case .modified:
                    self.onDocumentModified(document: body, category: category)
                case .removed:
                    self.onDocumentRemoved(document: body)
                @unknown default:
                    fatalError()
                }
            })
        })
    }

    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        // Change the font programmatically
        guard let font = UIFont(name: "futura", size: 26) else {return}
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func onDocumentAdded(document: DocumentChange, category: Category) {
        let newIndex = Int(document.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    
    func onDocumentModified(document: DocumentChange, category: Category) {
        if document.newIndex == document.oldIndex {
            let index = Int(document.newIndex)
            categories[index] = category
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
        else {
            let oldIndex = Int(document.oldIndex)
            let newIndex = Int(document.newIndex)
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(document: DocumentChange) {
        let oldIndex = Int(document.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CategoryCell, for: indexPath) as? CategoryCell {
            
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let cellWidth = (width - 50) / 2
        let cellHeight = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.item]
        performSegue(withIdentifier: Segues.ToProducts, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToProducts {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
            }
        }
    }
}







// old code

//func fetchDocument() {
//    let docRef = db.collection("categories").document("UIXNKfktXLCzXBIxDOgl")
//    //        docRef.getDocument { (snap, error) in
//    //            guard let data = snap?.data() else {return}
//    //            let newCategory = Category.init(data: data)
//    //            self.categories.append(newCategory)
//    //            self.collectionView.reloadData()
//    //        }
//    docRef.addSnapshotListener { (snap, error) in
//        self.categories.removeAll()
//        guard let data = snap?.data() else {return}
//        let newCategory = Category.init(data: data)
//        self.categories.append(newCategory)
//        self.collectionView.reloadData()
//    }
//}
//
//func fetchCollection() {
//    let collectionRef = db.collection("categories")
//    //        collectionRef.getDocuments { (snap, error) in
//    //            guard let documents = snap?.documents else {return}
//    //            for document in documents {
//    //                let data = document.data()
//    //                let newCategory = Category.init(data: data)
//    //                self.categories.append(newCategory)
//    //            }
//    //            self.collectionView.reloadData()
//    //        }
//    listener = collectionRef.addSnapshotListener { (snap, error) in
//        self.categories.removeAll()
//        guard let documents = snap?.documents else {return}
//
//
//        for document in documents {
//            let data = document.data()
//            let newCategory = Category.init(data: data)
//            self.categories.append(newCategory)
//        }
//        self.collectionView.reloadData()
//    }
//}
