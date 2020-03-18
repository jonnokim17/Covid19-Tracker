//
//  WorldwideDataViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit
import CoreLocation

class WorldwideDataViewController: UIViewController {

    @IBOutlet weak var totalCasesLabel: UILabel!
    @IBOutlet weak var totalDeathsLabel: UILabel!
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var countryContainerView: UIView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryTotalCasesLabel: UILabel!
    @IBOutlet weak var countryTotalDeathsLabel: UILabel!
    @IBOutlet weak var countryTotalRecoveredLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var currentCountry = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataAndUpdateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                countryContainerView.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse:
                countryContainerView.isHidden = UIDevice.current.screenType == .iPhone5 ? true : false
            @unknown default:
                break
            }
        } else {
            countryContainerView.isHidden = true
        }
    }
    
    private func getDataAndUpdateUI() {
        activityIndicator.startAnimating()
        CovidDataClient.shared.getWorldwideData { [weak self] (result) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            switch result {
            case .success(let worldWideData):
                DispatchQueue.main.async {
                    self?.totalCasesLabel.text = worldWideData.cases.withCommas()
                    self?.totalDeathsLabel.text = worldWideData.deaths.withCommas()
                    self?.totalRecoveredLabel.text = worldWideData.recovered.withCommas()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateCountryDataLabels(country: String) {
        CovidDataClient.shared.getSelectedCountryData(country: country) { (result) in
            switch result {
            case .success(let currentCountryData):
                DispatchQueue.main.async {
                    self.countryTotalCasesLabel.text = currentCountryData.cases.withCommas()
                    self.countryTotalDeathsLabel.text = currentCountryData.deaths.withCommas()
                    self.countryTotalRecoveredLabel.text = currentCountryData.recovered.withCommas()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //TODO: move these functions into extension
    private func locale(for fullCountryName : String) -> String {
        let locales : String = ""
        for localeCode in NSLocale.isoCountryCodes {
            let identifier = NSLocale(localeIdentifier: localeCode)
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
            if fullCountryName.lowercased() == countryName?.lowercased() {
                return localeCode
            }
        }
        return locales
    }
    
    private func flag(country:String) -> String {
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in country.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
    
    @IBAction func onRefreshData(_ sender: UIBarButtonItem) {
        getDataAndUpdateUI()
        updateCountryDataLabels(country: currentCountry)
    }
}

extension WorldwideDataViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        countryContainerView.isHidden = UIDevice.current.screenType == .iPhone5 ? true : false
        guard let userLocation :CLLocation = locations.first else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if (error != nil) {
                print("error in reverseGeocode")
            }
            guard let placemark = placemarks else { return }
            if !placemark.isEmpty{
                guard let placemark = placemarks?.first else { return }
                guard let country = placemark.country else { return }
                
                let countryCode = self.locale(for: country)
                DispatchQueue.main.async {
                    if country == "United States" {
                        self.currentCountry = "US"
                    } else {
                        self.currentCountry = country
                    }
                    
                    self.countryLabel.text = "\(self.currentCountry) \(self.flag(country: countryCode))"
                    self.updateCountryDataLabels(country: self.currentCountry)
                }
            }
        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
