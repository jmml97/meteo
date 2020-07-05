//
//  TownListViewModel.swift
//  Meteo
//
//  Created by José María Martín Luque on 03/07/2020.
//

import Foundation

class TownListViewModel: ObservableObject {
    
    init() {
        fetchPrediction()
    }
    
    @Published var towns: [AEMETTown]?
    
    private func fetchPrediction() {
        
        do {
            let url = Bundle.main.url(forResource: "municipios", withExtension: "json")
            if let url = url {
                let data = try Data(contentsOf: url)
                self.towns = try JSONDecoder().decode([AEMETTown].self, from: data)
            }
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
    }
}
