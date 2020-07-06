//
//  FavouriteTownManager.swift
//  Meteo
//
//  Created by José María Martín Luque on 05/07/2020.
//

import Foundation

class TownStore: ObservableObject {
    
    @Published var favouriteTowns: [AEMETTown] = []
    
    init() {
        
    }
}
