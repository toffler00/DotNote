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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            photosViewControllerDelegate.imageSelected(phAsset: cell.phAsset)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            if let changes = changeInstance.changeDetails(for: self.fetchResult) {
                
                self.fetchResult = changes.fetchResultAfterChanges
                
                if changes.hasIncrementalChanges {
                    self.photoCollectionView.performBatchUpdates({
                        
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            self.photoCollectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                        }
                        
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            self.photoCollectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                        }
                        
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            self.photoCollectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                        }
                        
                        changes.enumerateMoves { fromIndex, toIndex in
                            self.photoCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                              to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                } else {
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
}
