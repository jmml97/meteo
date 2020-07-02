//
//  Models.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

struct GenericAEMETResponse: Codable {
    
    let descripcion: String
    let estado: Int
    let datos: String
    let metadatos: String
    
}

struct AEMETPredictionsResponse: Codable {
    let predictions: [AEMETPrediction]
}

struct AEMETPrediction: Codable, Identifiable {

    let nombre: String?
    let provincia: String?
    let elaborado: String?
    let id: String?
    
    init() {
        nombre = nil
        provincia = nil
        elaborado = nil
        id = nil
    }
    
}
