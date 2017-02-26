//
//  RandomCollectionVC.swift
//  Wallmax
//
//  Created by Ajay Mann on 18/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher
import Kanna

private let reuseIdentifier = "RandomCell"
let imagePath = "//figure"


var phoneType = Display.typeIsLike

class RandomCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RandomCellDelegate {
    
    @IBOutlet weak var buttonHoldingBlurView: UIVisualEffectView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scrollableImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet var randomCollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    var wallhavenRandomImages = [WallhavenImage]()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(showNetworkAlert), name: NSNotification.Name("NoInternet"), object: nil)
        if isInternetAvailable() {
            loadNewData(pageNum: currentPage)
        } else {
            self.alertify("Internet not available. Please try agin later.")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showNetworkAlert(notification: Notification) {
        self.alertify("Internet not available. Please try agin later.")
    }
    
    func loadNewData(pageNum: Int) {
        if isInternetAvailable() {
            WallhavenHelper.loadNewData(ofType: "random", withPageNum: currentPage) { (success, images, error) in
                if let error = error {
                }
                
                if success {
                    if let images = images {
                        self.wallhavenRandomImages.append(contentsOf: images)
                        DispatchQueue.main.async {
                            self.randomCollectionView.reloadData()
                        }
                    }
                }
            }
        } else {
            self.alertify("Internet not available. Please try agin later.")
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
        return wallhavenRandomImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RandomCell
        cell.delegate = self
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.likeButton.backgroundColor = UIColor.clear
        cell.likeButton.isEnabled = true
        cell.likeButton.setTitle("Like", for: .normal)
        cell.image = wallhavenRandomImages[indexPath.row]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (wallhavenRandomImages.count - 5) {
            currentPage += 1
            loadNewData(pageNum: currentPage)
        }
    }
    
    func downloadButtonTappedFor(cell: RandomCell) {
        if isInternetAvailable() {
            guard let id = cell.image?.id else { return }
            let url = URL(string: "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-\(id).jpg")
            
            ImageDownloader.default.downloadImage(with: url!, options: [], progressBlock: {
                receivedSize, totalSize in
                let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                self.progressView.isHidden = false
                self.progressView.setProgress(percentage, animated: true)
            }
            ) {
                (image, error, url, data) in
                if let _ = error {
                    let url = URL(string: "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-\(id).png")
                    ImageDownloader.default.downloadImage(with: url!, options: [], progressBlock: {
                        receivedSize, totalSize in
                        let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                        self.progressView.isHidden = false
                        self.progressView.setProgress(percentage, animated: true)
                    }
                    ) {
                        (image, error, url, data) in
                        if let image = image {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.progressView.setProgress(0.0, animated: false)
                            })
                        }
                    }
                    return
                }
                if let image = image {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.progressView.setProgress(0.0, animated: false)
                    })
                }
            }
        } else {
            self.alertify("Internet not available. Please try agin later.")
        }
    }
    
    @IBAction func dismissPreview(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        self.imageScrollView.alpha = 0
        self.buttonHoldingBlurView.isHidden = true
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
        if isInternetAvailable() {
            buttonHoldingBlurView.isHidden = false
            self.imageView.image = nil
            self.imageView.kf.indicatorType = .activity
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
        } else {
            self.alertify("Internet not available. Please try agin later.")
        }
    }
    
    func likeButtonTappedFor(cell: RandomCell) {
        cell.likeButton.isSelected = !cell.likeButton.isSelected
        if cell.likeButton.isSelected {
            cell.likeButton.backgroundColor = UIColor(red: 255, green: 0, blue: 83, alpha: 1)
            cell.likeButton.isEnabled = false
            cell.likeButton.setTitle("Liked", for: .selected)
        } else {
            cell.likeButton.backgroundColor = UIColor.clear
            cell.likeButton.isEnabled = true
            cell.likeButton.setTitle("Like", for: .normal)
        }
        let likedImageID = cell.image?.id
        let likedImageThumbURL = cell.image?.thumbURL
        let coreDataImage = CoredataImage(context: appDelegate.coreDataStack.persistentContainer.viewContext)
        coreDataImage.id = likedImageID
        coreDataImage.thumbURL = likedImageThumbURL
        coreDataImage.image = NSData(data: UIImagePNGRepresentation(cell.imageView.image!)!)
        appDelegate.coreDataStack.saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name("refreshData"), object: nil)
    }
}
