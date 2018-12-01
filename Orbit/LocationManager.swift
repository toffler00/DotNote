//
//  LocationManager.swift
//  Orbit
//
//  Created by ilhan won on 01/12/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension ListViewController : CLLocationManagerDelegate {
   
    func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(locations.first!) {[weak self] (placeMark, error) in
            if let error = error {
                log.error(error)
            } else {
                //                self?.currentPlace = placeMark?.first?.administrativeArea
                self?.coordinate = placeMark?.first?.location?.coordinate
                //                log.debug(placeMark?.first?.name)
                //                log.debug(placeMark?.first?.locality)
                //                log.debug(placeMark?.first!.subLocality)
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
}
