//
//  FavouriteCell.swift
//  Wallmax
//
//  Created by Ajay Mann on 26/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import CoreData

class FavouriteCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var image : CoredataImage? {
        didSet {
            guard let image = image else { return }
            configUI(forImage: image)
        }
    }
    
    func configUI(forImage image: CoredataImage) {
        imageView.image = UIImage(data: image.image as! Data)
    }
    
    @IBAction func removeTapped(_ sender: UIButton) {
    }
    @IBAction func imageTapped(_ sender: UIButton) {
    }
    
}
