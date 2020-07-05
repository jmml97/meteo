//
//  PredictionViewModel.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

class PredictionDataLoader: ObservableObject {
    
    @Published var predictions: AEMETRootElement? = nil
    
    func load(_ id: String) {
        
        var keys: NSDictionary?

        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let apiKey = dict["apiKey"] as? String
            
            let url = URL(string: "https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/\(id)/?api_key=\(apiKey!)")!
            
            WebService().loadDataRequest(url: url) { response in
                
                guard let predictionURLString = response?.datos else {
                    fatalError("Could not unwrap string of data URL")
                }
                
                guard let predictionURL = URL(string: predictionURLString) else {
                            fatalError("URL is not correct!")
                }
                        
                WebService().loadPredictionRequest(url: predictionURL) { predictions in
                    
                    if let predictions = predictions {
                        self.predictions = predictions
                    }
                }
                        
            }
        }
        
        
    }
}
