//
//  WorldwideDataViewController.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import UIKit

class WorldwideDataViewController: UIViewController {

    @IBOutlet weak var totalCasesLabel: UILabel!
    @IBOutlet weak var totalDeathsLabel: UILabel!
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        CovidDataClient.shared.getWorldwideData { [weak self] (result) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            switch result {
            case .success(let worldWideData):
                DispatchQueue.main.async {
                    self?.totalCasesLabel.text = "\(worldWideData.cases.withCommas())"
                    self?.totalDeathsLabel.text = "\(worldWideData.deaths.withCommas())"
                    self?.totalRecoveredLabel.text = "\(worldWideData.recovered.withCommas())"
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
