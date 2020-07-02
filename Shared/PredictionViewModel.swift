//
//  PredictionViewModel.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

class PredictionViewModel: ObservableObject {
    
    init() {
        fetchPrediction()
    }
    
    @Published var predictions = [AEMETPrediction]()
    
    private func fetchPrediction() {
        let url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/29082/?api_key=***REMOVED***")!
        
        WebService().loadDataRequest(url: url) { response in
            
            guard let predictionURLString = response?.datos else {
                fatalError("Could not unwrap string of data URL")
            }
            
            guard let predictionURL = URL(string: predictionURLString) else {
                        fatalError("URL is not correct!")
            }
                    
            WebService().loadPredictionRequest(url: predictionURL) { predictions in
                
                if let predictions = predictions {
                    print(predictions)
                    self.predictions = predictions
                    print(self.predictions)
                }
            }
                    
        }
    }
}
