//
//  KGPhotoFetcher.swift
//  KGPhotoSharingDemo
//
//  Created by Kevin Guo on 2016-09-01.
//  Copyright © 2016 Kevin Guo. All rights reserved.
//

import Foundation
import Photos

class KGPhotoFetcher : NSObject {
    static func fetchPhotos(parameter: String) -> NSArray{
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [(NSSortDescriptor(key: parameter, ascending: true))]
        let allPhotos = PHAsset.fetchAssetsWithOptions(allPhotoOptions)
        print("There are \(allPhotos.count) photos in total.")
        
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: .AlbumRegular, options: nil)
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        
        return [allPhotos, smartAlbums, topLevelUserCollections]
    }
}

