//
//  ViewController.swift
//  KGGCDWebServerDemo
//
//  Created by Kevin Guo on 2016-09-12.
//  Copyright © 2016 Kevin Guo. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    @IBOutlet weak var sampleImageView: UIImageView!
    
    let queryParamStr = "creationDate"
    
    var sectionFetchResults : NSArray!
    var imageIdList : [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageIdList = [String]()
        initFetchResults()
        populateImageIdList()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initFetchResults() {
        self.sectionFetchResults = KGPhotoFetcher.fetchPhotos(queryParamStr)
    }
    
    func populateImageIdList() {
        self.sectionFetchResults[0].enumerateObjectsUsingBlock { (obj : AnyObject, index : Int, bool :UnsafeMutablePointer<ObjCBool>) in
            let photoAsset = obj as! PHAsset
            self.imageIdList?.append(photoAsset.localIdentifier)
        }
        
        print(self.imageIdList!)
        
        let str = (self.imageIdList![(imageIdList?.count)!-1])
        
        
        let options = PHFetchOptions()
        
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        let set = PHAsset.fetchAssetsWithLocalIdentifiers([str], options: options)
        
        PHImageManager.defaultManager().requestImageForAsset(set.firstObject as! PHAsset, targetSize: CGSizeMake(300, 300), contentMode: .AspectFit, options: nil) { (result, info) in
            //print(result)
            //self.sampleImageView.image = result
        }
        
    }
}

