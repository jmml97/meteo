//
//  PredictionViewModel.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

class PredictionDataLoader: ObservableObject {
    
    @Published var hourlyPredictionsContainer: AEMETHourlyPredictionContainer? = nil
    @Published var dailyPredictionsContainer: AEMETDailyPredictionContainer? = nil
    
    func load(_ id: String) {
        
        var keys: NSDictionary?

        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let apiKey = dict["apiKey"] as? String
            
            var url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/\(id)/?api_key=\(apiKey!)")!
            
            WebService().loadDataRequest(url: url) { response in
                
                guard let predictionURLString = response?.data else {
                    fatalError("Could not unwrap string of data URL")
                }
                
                guard let predictionURL = URL(string: predictionURLString) else {
                            fatalError("URL is not correct!")
                }
                        
                WebService().loadHourlyPredictionRequest(url: predictionURL) { predictions in
                    
                    guard let predictions = predictions else {
                        fatalError("Could not load prediction")
                    }
                    
                    self.hourlyPredictionsContainer = predictions
                    
                }
                        
            }
            
            url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/diaria/\(id)/?api_key=\(apiKey!)")!
            
            WebService().loadDataRequest(url: url) { response in
                
                guard let predictionURLString = response?.data else {
                    fatalError("Could not unwrap string of data URL")
                }
                
                guard let predictionURL = URL(string: predictionURLString) else {
                            fatalError("URL is not correct!")
                }
                        
                WebService().loadDailyPredictionRequest(url: predictionURL) { predictions in
                    
                    guard let predictions = predictions else {
                        fatalError("Could not load prediction")
                    }
                    
                    self.dailyPredictionsContainer = predictions
                    
                }
                        
            }
        }
        
        
    }
}
