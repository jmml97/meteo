//
//  Models.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

// MARK: - AEMETRootElement
struct AEMETRootElement: Codable {
    let elaborado, nombre, provincia: String
    let prediccion: AEMETPrediccion
    let id, version: String
    let origen: AEMETOrigen
}

// MARK: - AEMETOrigen
struct AEMETOrigen: Codable {
    let productor: String
    let web, enlace, notaLegal: URL
    let language, copyright: String
}

// MARK: - AEMETPrediccion
struct AEMETPrediccion: Codable {
    let dia: [AEMETDia]
}

// MARK: - AEMETDia
struct AEMETDia: Codable {
    let estadoCielo: [AEMETEstadoCielo]
    let precipitacion, probPrecipitacion, probTormenta, nieve: [AEMETHumedadRelativa]
    let probNieve, temperatura, sensTermica, humedadRelativa: [AEMETHumedadRelativa]
    let vientoAndRachaMax: [AEMETVientoAndRachaMax]
    let fecha, orto, ocaso: String
}

// MARK: - AEMETEstadoCielo
struct AEMETEstadoCielo: Codable {
    let value, periodo: String
    let descripcion: AEMETDescripcion
}

enum AEMETDescripcion: String, Codable {
    case bruma = "Bruma"
    case cubierto = "Cubierto"
    case cubiertoLluviaEscasa = "Cubierto con lluvia escasa"
    case despejado = "Despejado"
    case nuboso = "Nuboso"
    case intervalosNubosos = "Intervalos nubosos"
    case muyNuboso = "Muy nuboso"
    case muyNubosoLluviaEscasa = "Muy nuboso con lluvia escasa"
    case niebla = "Niebla"
    case pocoNuboso = "Poco nuboso"
    case nubesAltas = "Nubes altas"
}

// MARK: - AEMETHumedadRelativa
struct AEMETHumedadRelativa: Codable {
    let value, periodo: String
}

// MARK: - AEMETVientoAndRachaMax
struct AEMETVientoAndRachaMax: Codable {
    let direccion: [AEMETDireccion]?
    let velocidad: [String]?
    let periodo: String
    let value: String?
}

enum AEMETDireccion: String, Codable {
    case n = "N"
    case no = "NO"
    case o = "O"
    case e = "E"
    case s = "S"
    case se = "SE"
    case so = "SO"
    case ne = "NE"
    case c = "C"
}

typealias AEMETRoot = [AEMETRootElement]

struct GenericAEMETResponse: Codable {
    
    let descripcion: String
    let estado: Int
    let datos: String
    let metadatos: String
    
}

struct AEMETPredictionResponse: Codable, Identifiable {

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

// MARK: - Towns

struct AEMETTown: Codable {
    let nombre, id: String
}
