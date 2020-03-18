//
//  CountryDetailViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit

class CountryDetailViewController: UIViewController {
    
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var todaysCasesLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var todaysDeathLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var criticalCasesLabel: UILabel!
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var graphTitleLabel: UILabel!
    
    var covidData: CovidData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        activityIndicator.startAnimating()
        CovidDataClient.shared.getFiveDayData(country: covidData.country) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            switch result {
            case .success(let graphDataArray):
                DispatchQueue.main.async {
                    MacawChartView.lastFiveData = graphDataArray
                    let maxValue = graphDataArray.map { $0.confirmed }.max() ?? 200
                    MacawChartView.maxValue = maxValue < 190 ? 200 : maxValue
                    MacawChartView.dataDivisor = Double(MacawChartView.maxValue/MacawChartView.maxValueLineHeight)
                    MacawChartView.adjustedData = MacawChartView.lastFiveData.map({ Double($0.confirmed) / MacawChartView.dataDivisor })
                    
                    let chartView = MacawChartView.init(frame: .zero)
                    chartView.contentMode = .scaleAspectFit
                    chartView.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(chartView)
                    
                    NSLayoutConstraint.activate([
                        chartView.topAnchor.constraint(equalTo: self.graphTitleLabel.bottomAnchor, constant: 20),
                        chartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20),
                        chartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                        chartView.heightAnchor.constraint(equalTo: chartView.widthAnchor, multiplier: 1)
                    ])
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        MacawChartView.playAnimations()
    }
    
    private func setupUI() {
        title = covidData.country        
        casesLabel.text = "Total Cases: \(covidData.cases.withCommas())"
        todaysCasesLabel.text = "Today's Cases: \(covidData.todayCases.withCommas())"
        deathsLabel.text = "Deaths: \(covidData.deaths.withCommas())"
        todaysDeathLabel.text = "Today's Death: \(covidData.todayDeaths.withCommas())"
        recoveredLabel.text = "Recovered: \(covidData.recovered.withCommas())"
        activeLabel.text = "Active: \(covidData.active.withCommas())"
        criticalCasesLabel.text = "Confirmed Cases: \(covidData.critical.withCommas())"
        
        if CovidDataClient.shared.watchlistData.contains(where: { $0.country == covidData.country }) {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func onAddToWatchlist(_ sender: UIBarButtonItem) {
        if CovidDataClient.shared.watchlistData.isEmpty {
            CovidDataClient.shared.watchlistData = [covidData]
        } else {
            var currentWatchlist = CovidDataClient.shared.watchlistData
            currentWatchlist.append(covidData)
            CovidDataClient.shared.watchlistData = currentWatchlist
        }
        
        let alertController = UIAlertController(title: "Added to Watchlist", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
