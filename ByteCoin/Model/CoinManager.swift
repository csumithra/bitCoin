//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateWithCoinRate(coinResponse: CoinStruct)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "C0DE184F-35B8-4331-A9E8-EF79200DE2DB"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(currency: String) {
        let url = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        performRequest(urlString: url)
        
    }
    
    func performRequest(urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URL session
            let session = URLSession(configuration: .default)
            //3. Create a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                } else {
                    if let safeData = data {
                        if let coinValue = parseJson(coinData: safeData) {
                            delegate?.didUpdateWithCoinRate(coinResponse: coinValue)
                        }
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJson(coinData: Data) -> CoinStruct? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinModel.self, from: coinData)       
            let coinObj = CoinStruct(coinRate: decodedData.rate, currencyStr: decodedData.asset_id_quote)
            return coinObj
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
    
}
