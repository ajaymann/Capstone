//
//  FavouritesVC.swift
//  Wallmax
//
//  Created by Ajay Mann on 26/02/17.
//  Copyright © 2017 Ajay. All rights reserved.
//

import UIKit
import CoreData


class FavouritesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var favouritesCollectionView: UICollectionView!

    var favouriteImages = [CoredataImage]()
    let cellID = "FavouriteCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavouriteImages()
        configUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("refreshData"), object: nil)
    }
    
    func refreshData(notification: Notification) {
        fetchFavouriteImages()
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
        favouritesCollectionView.collectionViewLayout = layout
    }
    
    func fetchFavouriteImages() {
        let context = appDelegate.coreDataStack.persistentContainer.viewContext
        let imagesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CoredataImage")
        
        do {
            let fetchedImages = try context.fetch(imagesFetch) as! [CoredataImage]
            favouriteImages = fetchedImages
            favouritesCollectionView.reloadData()
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteImages.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCell", for: indexPath) as! FavouriteCell
        cell.image = favouriteImages[indexPath.row]
        return cell
    }
    
}
