//
//  CategoryCell.swift
//  ArtMarket
//
//  Created by Kim Harold Gabiana on 7/10/19.
//  Copyright © 2019 Kim Harold Gabiana. All rights reserved.
//

import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {

    // Outlet
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImg.layer.cornerRadius = 5
    }

    func configureCell(category: Category) {
        categoryLbl.text = category.name
        if let url = URL(string: category.imgUrl) {
            let placeholder = UIImage(named: AppImages.placeHolder)
            categoryImg.kf.indicatorType = .activity
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            categoryImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
    }
}
