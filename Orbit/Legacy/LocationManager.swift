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
        let message : String = "접근을 허용하면 Dot Note 가 사용자의 위치정보를 사용하여 날씨정보를 나타낼 수 있습니다. 허용하지 않는다면 일부 기능이 동작하지 않습니다."
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
