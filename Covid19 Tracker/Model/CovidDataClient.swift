//
//  CovidDataClient.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import Foundation

struct CovidData: Codable {
    let country: String
    let cases: Int
    let todayCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let active: Int
    let critical: Int
    
    init(json: [String: Any]) {
        let country = json["country"] as? String ?? ""
        let cases = json["cases"] as? Int ?? 0
        let todayCases = json["todayCases"] as? Int ?? 0
        let deaths = json["deaths"] as? Int ?? 0
        let todayDeaths = json["todayDeaths"] as? Int ?? 0
        let recovered = json["recovered"] as? Int ?? 0
        let active = json["active"] as? Int ?? 0
        let critical = json["critical"] as? Int ?? 0
        
        self.country = country
        self.cases = cases
        self.todayCases = todayCases
        self.deaths = deaths
        self.todayDeaths = todayDeaths
        self.recovered = recovered
        self.active = active
        self.critical = critical
    }
}

struct WorldwideData {
    let cases: Int
    let deaths: Int
    let recovered: Int
    
    init(json: [String: Any]) {
        let cases = json["cases"] as? Int ?? 0
        let deaths = json["deaths"] as? Int ?? 0
        let recovered = json["recovered"] as? Int ?? 0
        
        self.cases = cases
        self.deaths = deaths
        self.recovered = recovered
    }
}

struct GraphData {
    let date: String
    let confirmed: Int
    
    init(json: [String: Any]) {
        let date = json["date"] as? String ?? ""
        let confirmed = json["confirmed"] as? Int ?? 0
        
        self.date = date
        self.confirmed = confirmed
    }
}

class CovidDataClient {
    static let shared = CovidDataClient()
    private let watchlistDataKey = "watch_list_key"
    
    var watchlistData: [CovidData] {
        get {
            if let userData = UserDefaults.standard.data(forKey: watchlistDataKey),
                let watchlistData = try? JSONDecoder().decode([CovidData].self, from: userData) {
                return watchlistData
            }
            
            return []
        }
        
        set(newWatchlistData) {
            if let encoded = try? JSONEncoder().encode(newWatchlistData) {
                UserDefaults.standard.setValue(encoded, forKey: watchlistDataKey)
//                let inspectionStateDict: [String: [CovidData]] = ["updatedWatchlist": inspectionStatus]
                NotificationCenter.default.post(name: Notification.Name("WatchlistUpdated"), object: nil)
            }
        }
    }
    
    func getFiveDayData(country: String, completion: @escaping (Result<[GraphData], Error>) -> Void ) {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            return completion(.failure(error))
        }
        
        let request = setupRequest(method: "GET", url: url, bodyData: nil)
        fetchFiveDayData(country: country, request: request, completion: completion)
    }
 
    func getCovidData(completion: @escaping (Result<[CovidData], Error>) -> Void ) {
        let urlString = "https://coronavirus-19-api.herokuapp.com/countries"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            return completion(.failure(error))
        }
        
        let request = setupRequest(method: "GET", url: url, bodyData: nil)
        getData(request: request, completion: completion)
    }
    
    func getWorldwideData(completion: @escaping (Result<WorldwideData, Error>) -> Void ) {
        let urlString = "https://coronavirus-19-api.herokuapp.com/all"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            return completion(.failure(error))
        }
        
        let request = setupRequest(method: "GET", url: url, bodyData: nil)
        getWorldwideData(request: request, completion: completion)
    }
    
    func getSelectedCountryData(country: String, completion: @escaping (Result<CovidData, Error>) -> Void ) {
        let urlString = "https://coronavirus-19-api.herokuapp.com/countries/\(country)"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            return completion(.failure(error))
        }
        
        let request = setupRequest(method: "GET", url: url, bodyData: nil)
        getSelectedCountryInfo(request: request, completion: completion)
    }
    
    fileprivate func setupRequest(method: String, url: URL, bodyData: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        request.httpBody = bodyData
        return request
    }
    
    fileprivate func fetchFiveDayData(country: String, request: URLRequest, completion: @escaping (Result<[GraphData], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var fiveDayDataArray: [GraphData] = []
            let error = NSError(domain: "", code: -1, userInfo: nil)
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard (200 ..< 300) ~= response.statusCode else {
                    switch response.statusCode {
                    case 400:
                        return completion(.failure(error))
                    case 401:
                        return completion(.failure(error))
                    default:
                        return completion(.failure(error))
                    }
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    var formattedCountry: String
                    if country == "S. Korea" {
                        formattedCountry = "Korea, South"
                    } else if country == "USA" {
                        formattedCountry = "US"
                    } else if country == "UAE" {
                        formattedCountry = "United Arab Emirates"
                    } else if country == "UK" {
                        formattedCountry = "United Kingdom"
                    } else if country == "Taiwan" {
                        formattedCountry = "Taiwan*"
                    } else {
                        formattedCountry = country
                    }
                    if let jsonArray = json[formattedCountry] as? [[String: Any]] {
                        let range = jsonArray.index(jsonArray.endIndex, offsetBy: -5) ..< jsonArray.endIndex
                        let slicedJsonArray = jsonArray[range]
                        for dict in slicedJsonArray {
                            fiveDayDataArray.append(GraphData(json: dict))
                        }
                    }
                }
                
                completion(.success(fiveDayDataArray))
                
            } catch let error {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    fileprivate func getData(request: URLRequest, completion: @escaping (Result<[CovidData], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var covidDataArray: [CovidData] = []
            let error = NSError(domain: "", code: -1, userInfo: nil)
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard (200 ..< 300) ~= response.statusCode else {
                    switch response.statusCode {
                    case 400:
                        return completion(.failure(error))
                    case 401:
                        return completion(.failure(error))
                    default:
                        return completion(.failure(error))
                    }
                }
                
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for dict in jsonArray {
                        covidDataArray.append(CovidData(json: dict))
                    }
                }
                
                completion(.success(covidDataArray))
                
            } catch let error {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    fileprivate func getWorldwideData(request: URLRequest, completion: @escaping (Result<WorldwideData, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let error = NSError(domain: "", code: -1, userInfo: nil)
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard (200 ..< 300) ~= response.statusCode else {
                    switch response.statusCode {
                    case 400:
                        return completion(.failure(error))
                    case 401:
                        return completion(.failure(error))
                    default:
                        return completion(.failure(error))
                    }
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let worldWideData = WorldwideData(json: json)
                    completion(.success(worldWideData))
                }
                
            } catch let error {
                print(error)
                return
            }
        }
        task.resume()
    }
    
    fileprivate func getSelectedCountryInfo(request: URLRequest, completion: @escaping (Result<CovidData, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let error = NSError(domain: "", code: -1, userInfo: nil)
            guard let response = response as? HTTPURLResponse else {
                return completion(.failure(error))
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard (200 ..< 300) ~= response.statusCode else {
                    switch response.statusCode {
                    case 400:
                        return completion(.failure(error))
                    case 401:
                        return completion(.failure(error))
                    default:
                        return completion(.failure(error))
                    }
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let selectedCountryData = CovidData(json: json)
                    completion(.success(selectedCountryData))
                }
                
            } catch let error {
                print(error)
                return
            }
        }
        task.resume()
    }
}
