//
//  RandomCell.swift
//  Wallmax
//
//  Created by Ajay Mann on 18/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import GreedoLayout
import Kingfisher

class RandomCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resolutionLabel: UILabel!
    
    var image : WallhavenImage? {
        didSet {
            guard let image = image else { return }
            configUI(forImage: image)
        }
    }
    
    func configUI(forImage image: WallhavenImage) {
        if let url = URL(string: image.thumbURL!) {
            imageView.kf.setImage(with: url)
        }
        resolutionLabel.text = image.resolution
    }
}
