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

protocol RandomCellDelegate {
    func downloadButtonTappedFor(cell: RandomCell)
    func imageTappedFor(cell: RandomCell)
}

class RandomCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resolutionLabel: UILabel!
    
    @IBOutlet weak var downloadButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    var image : WallhavenImage? {
        didSet {
            guard let image = image else { return }
            configUI(forImage: image)
        }
    }
    
    var delegate : RandomCellDelegate?
    
    func configUI(forImage image: WallhavenImage) {
        if phoneType == .iphone7 || phoneType == .iphone7plus {
            downloadButtonWidthConstraint.constant = 20
            downloadButtonHeightConstraint.constant = 20
            downloadButton.layer.cornerRadius = 10
        } else {
            downloadButtonWidthConstraint.constant = 30
            downloadButtonHeightConstraint.constant = 30
            downloadButton.layer.cornerRadius = 15
        }
        if let url = URL(string: image.thumbURL!) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)
        }
        resolutionLabel.text = image.resolution
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        delegate?.downloadButtonTappedFor(cell: self)
    }
    
    @IBAction func cellTapped(_ sender: UIButton) {
        delegate?.imageTappedFor(cell: self)
    }
    
}
