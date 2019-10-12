//
//  TableViewCell.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 7/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductCellDelegate : class {
    func prodcutFavorited(product: Product)
}

class ProductCell: UITableViewCell {

    // Outlet
    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBt: UIButton!

    weak var delegate : ProductCellDelegate?
    private var product : Product!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    func configureCell(product: Product, delegate: ProductCellDelegate) {
        self.product = product
        self.delegate = delegate

        productTitle.text = product.name

        if let url = URL(string: product.imageUrl) {
            let placeholder = UIImage(named: AppImages.placeHolder)
            productImg.kf.indicatorType = .activity
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            productImg.kf.setImage(with: url, placeholder: placeholder, options: options)
//            productImg.kf.setImage(with: url)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }
        
        if userService.favorites.contains(product) {
            favoriteBt.setImage(UIImage(named: AppImages.filledStar), for: .normal)
        }
        else {
            favoriteBt.setImage(UIImage(named: AppImages.emptyStar), for: .normal)
        }
    }

    @IBAction func addToCartBt(_ sender: Any) {

    }

    @IBAction func favoriteBt(_ sender: Any) {
        delegate?.prodcutFavorited(product: self.product)
    }

}
