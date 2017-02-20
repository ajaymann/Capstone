//
//  RandomCollectionVC.swift
//  Wallmax
//
//  Created by Ajay Mann on 18/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

private let reuseIdentifier = "RandomCell"
let imagePath = "//figure"

var wallhavenImages = [WallhavenImage]()
var currentPage = 1
var phoneType = Display.typeIsLike

class RandomCollectionVC: UICollectionViewController {

    @IBOutlet var randomCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadNewData(pageNum: currentPage)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadNewData(pageNum: Int) {
        WallhavenHelper.loadNewData(ofType: "random", withPageNum: currentPage) { (success, images, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if success {
                if let images = images {
                    wallhavenImages.append(contentsOf: images)
                    DispatchQueue.main.async {
                        self.randomCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func configUI() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: (self.tabBarController?.tabBar.frame.height)!, right: 0)
        if phoneType == .iphone5 {
            layout.itemSize = CGSize(width: width/2 - 2 , height: width / 3)
        } else if phoneType == .iphone7 || phoneType == .iphone7plus {
            layout.itemSize = CGSize(width: width/2 - 2 , height: width / 3)
        }
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        randomCollectionView.collectionViewLayout = layout
    }
    
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallhavenImages.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RandomCell
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.image = wallhavenImages[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("Selected item : \(indexPath.row)")
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (wallhavenImages.count - 5) {
            currentPage += 1
            loadNewData(pageNum: currentPage)
        }
    }
    
    
   
}
