//
//  PhotoCollectionView.swift
//  Orbit
//
//  Created by David Koo on 01/09/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import Photos

extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let changes = changeInstance.changeDetails(for: fetchResult) {
            
            fetchResult = changes.fetchResultAfterChanges
            
            if changes.hasIncrementalChanges {
                photoCollectionView.performBatchUpdates({
                    
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        photoCollectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                    }
                    
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        photoCollectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                    }
                    
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        photoCollectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                    }
                    
                    changes.enumerateMoves {[weak self] fromIndex, toIndex in
                        self?.photoCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                     to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                photoCollectionView.reloadData()
            }
        }
    }
}
