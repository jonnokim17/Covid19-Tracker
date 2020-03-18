//
//  WatchlistViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit

class WatchlistTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistUpdated), name: Notification.Name("WatchlistUpdated"), object: nil)
        tableView.reloadData()
    }
    
    @objc private func watchlistUpdated() {
        tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "watchlistDetailSegue" {
            guard let detailVC = segue.destination as? CountryDetailViewController else { return }
            
            if let data = sender as? [String: Any] {
                if let covidData = data["selectedCountry"] as? CovidData {
                    detailVC.covidData = covidData
                }
            }
        }
    }
}

extension WatchlistTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchlistCell", for: indexPath)
        let watchlistData = CovidDataClient.shared.watchlistData[indexPath.row]
                
        let countryCode = locale(for: watchlistData.country)
        cell.textLabel?.text = "\(watchlistData.country) \(flag(country: countryCode))"
        cell.detailTextLabel?.text = "Confirmed Cases: \(watchlistData.cases.withCommas()) | Deaths: \(watchlistData.deaths.withCommas())"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CovidDataClient.shared.watchlistData.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            var currentWatchList = CovidDataClient.shared.watchlistData
            currentWatchList.remove(at: indexPath.row)
            CovidDataClient.shared.watchlistData = currentWatchList
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderData: [String : Any] = ["selectedCountry": CovidDataClient.shared.watchlistData[indexPath.row]]
        performSegue(withIdentifier: "watchlistDetailSegue", sender: senderData)
    }
}
