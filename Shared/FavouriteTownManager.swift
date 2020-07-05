//
//  FavouriteTownManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 05/07/2020.
//

import Foundation

class FavouriteTownManager: ObservableObject {
    
    @Published var favouriteTowns: [AEMETTown] = []
    
    init() {
        
    }
}
