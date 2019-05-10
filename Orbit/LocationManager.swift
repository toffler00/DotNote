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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        case .denied, .notDetermined, .restricted :
            showAlertForLocationPermission()
        }
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
    
    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func showAlertForLocationPermission() {
        let title : String = "앱을 사용하는 동안 사용자의 위치에 접근하도록 허용하시겠습니까?"
        let message : String = "사용자의 위치정보를 통해 \n 현재 날씨정보를 불러오는데 사용됩니다."
        showAlert(title: title,
                  message: message,
                  actionStyle: .default,
                  cancelBtn: true,
                  buttonTitle: "승인",
                  onView: self) { (action) in
                    self.openSettings()
        }
    }
}
