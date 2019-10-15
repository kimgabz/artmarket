//
//  AdminProductsVC.swift
//  ArtMarketAdmin
//
//  Created by Kim Harold Gabiana on 10/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit

class AdminProductsVC: ProductsVC {

    var selectedProduct : Product?

    override func viewDidLoad() {
        super.viewDidLoad()

        let editCategoryBt = UIBarButtonItem(title: "Edit Category", style: .plain, target: self, action: #selector(editCategory))
        let newProductBtn = UIBarButtonItem(title: "+ Product", style: .plain, target: self, action: #selector(newProduct))
        
        navigationItem.setRightBarButtonItems([editCategoryBt, newProductBtn], animated: false)
    }

    @objc func editCategory() {
        performSegue(withIdentifier: Segues.toEditCategory, sender: self)
    }
    
    @objc func newProduct() {
        performSegue(withIdentifier: Segues.toAddEditProduct, sender: self)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: Segues.toAddEditProduct, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toAddEditProduct {
            if let destination = segue.destination as? AddEditProductsVC {
                destination.selectedCategory = category
                destination.productToEdit = selectedProduct
            }
        }
        else if segue.identifier == Segues.toEditCategory {
            if let destination = segue.destination as? AddEditCategoryVC {
                destination.categoryToEdit = category
            }
        }
    }
    
    // We dont need to star products at admin side
    override func productFavorited(product: Product) {
        return
    }
    
    override func productAddTOCart(product: Product) {
        return
    }
}
