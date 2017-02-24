//
//  LatestCollectionVC.swift
//  Wallmax
//
//  Created by Ajay Mann on 22/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import Alamofire


private let reuseIdentifier = "RandomCell"



class LatestCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RandomCellDelegate {
    var wallhavenLatestImages = [WallhavenImage]()
    var currentPage = 1
    var phoneType = Display.typeIsLike
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        loadNewData(pageNum: currentPage)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadNewData(pageNum: Int) {
        WallhavenHelper.loadNewData(ofType: "latest", withPageNum: currentPage) { (success, images, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if success {
                if let images = images {
                    self.wallhavenLatestImages.append(contentsOf: images)
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
            layout.itemSize = CGSize(width: width , height: width / 1.5)
        } else if phoneType == .iphone7 || phoneType == .iphone7plus {
            layout.itemSize = CGSize(width: width/2 - 1 , height: width / 2 - 1)
        }
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        randomCollectionView.collectionViewLayout = layout
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallhavenLatestImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RandomCell
        cell.delegate = self
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.image = wallhavenLatestImages[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (wallhavenLatestImages.count - 5) {
            currentPage += 1
            loadNewData(pageNum: currentPage)
        }
    }
    
    func downloadButtonTappedFor(cell: RandomCell) {
        guard let id = cell.image?.id else { return }
        let url = URL(string: "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-\(id).jpg")
        ImageDownloader.default.downloadImage(with: url!, options: [], progressBlock: nil) {
            (image, error, url, data) in
            if error != nil {
                print(error?.description)
                return
            }
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    @IBAction func dismissPreview(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.imageScrollView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.blurView.alpha = 0
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func imageTappedFor(cell: RandomCell) {
        
        self.scrollableImageWidthConstraint.constant = self.view.frame.width
        
        if let url = URL(string: (cell.image?.fullSizePageURL)!) {
            Alamofire.request(url).responseString(completionHandler: { (response) in
                guard let html = response.result.value else { return }
                WallhavenHelper.parsePageForSinglePhoto(inHtml: html, completion: { (success, wallhavenImages, error) in
                    
                    if let error = error {
                        print(error)
                    }
                    
                    if success {
                        if let url = URL(string: (wallhavenImages?.first?.fullSizeURL)!) {
                            
                            
                            self.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                                
                                let relativeImageWidth = ((image?.size.width)! / (image?.size.height)!) * self.imageView.frame.height
                                
                                self.scrollableImageWidthConstraint.constant = relativeImageWidth
                                
                            })
                            
                            ImageCache.default.calculateDiskCacheSize { size in
                                print("Used disk size by bytes: \(size / 1024 / 1024)")
                            }
                            
                        }
                    }
                })
            })
        }
        
        
        self.tabBarController?.tabBar.isHidden = true
        blurView.alpha = 1
        UIView.animate(withDuration: 0.8, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            
            self.imageScrollView.alpha = 1
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

}
