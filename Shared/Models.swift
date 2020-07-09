//
//  Models.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

// MARK: - AEMETPredictionContainer
struct AEMETHourlyPredictionContainer: Codable {
    let elaborado, nombre, provincia: String
    let prediccion: AEMETHourlyPrediction
    let id, version: String
    let origen: AEMETSource
}

// MARK: - AEMETDailyPredictionContainer
struct AEMETDailyPredictionContainer: Codable {
    let elaborado, nombre, provincia: String
    let prediccion: AEMETDailyPrediction
    let id, version: Int
    let origen: AEMETSource
}

// MARK: - AEMETSource
struct AEMETSource: Codable {
    let productor: String
    let web, enlace, notaLegal: URL
    let language, copyright: String
}

// MARK: - AEMETHourlyPrediction
// A prediction with hourly values.
struct AEMETHourlyPrediction: Codable {
    let dia: [AEMETHourlyDayData]
}

// MARK: - AEMETHourlyDayData
/// Contais information for a day on the hourly prediction
struct AEMETHourlyDayData: Codable {
    let estadoCielo: [AEMETEstadoCielo]
    let precipitacion, probPrecipitacion, probTormenta, nieve: [AEMETHourlyGenericData]
    let probNieve, temperatura, sensTermica, humedadRelativa: [AEMETHourlyGenericData]
    let vientoAndRachaMax: [AEMETWind]
    let fecha, orto, ocaso: String
}

// MARK: - AEMETHourlyGenericData
/// A generic contanier `value` - `periodo` that stores information of a parameter for a certain period of time
struct AEMETHourlyGenericData: Codable {
    let value, periodo: String
}

// ---------------------

// MARK: - AEMETDailyPrediction
struct AEMETDailyPrediction: Codable {
    let dia: [AEMETDailyDayData]
}

// MARK: - AEMETDailyDayData
struct AEMETDailyDayData: Codable {
    let probPrecipitacion: [AEMETProbPrecipitacion]
    let cotaNieveProv: [AEMETCotaNieveProv]
    let estadoCielo: [AEMETEstadoCielo]
    let viento: [AEMETDailyWind]
    let rachaMax: [AEMETCotaNieveProv]
    let temperatura, sensTermica, humedadRelativa: AEMETHumedadRelativa
    let uvMax: Int?
    let fecha: String
}

// MARK: - AEMETCotaNieveProv
struct AEMETCotaNieveProv: Codable {
    let value: String
    let periodo: String?
}

// MARK: - AEMETHumedadRelativa
struct AEMETHumedadRelativa: Codable {
    let maxima, minima: Int
    let dato: [AEMETDato]
}

// MARK: - AEMETDato
struct AEMETDato: Codable {
    let value, hora: Int
}

// MARK: - AEMETProbPrecipitacion
struct AEMETProbPrecipitacion: Codable {
    let value: Int
    let periodo: String?
}

// MARK: - AEMETViento
struct AEMETDailyWind: Codable {
    let direccion: String
    let velocidad: Int
    let periodo: String?
}

// ---------------------

// MARK: - AEMETEstadoCielo
struct AEMETEstadoCielo: Codable {
    let value:String
    let periodo: String?
    let descripcion: AEMETDescripcion
}

enum AEMETDescripcion: String, Codable {
    case despejado = "Despejado"
    case cubierto = "Cubierto"
    case cubiertoLluviaEscasa = "Cubierto con lluvia escasa"
    case pocoNuboso = "Poco nuboso"
    case intervalosNubosos = "Intervalos nubosos"
    case intervalosNubososLluviaEscasa = "Intervalos nubosos con lluvia escasa"
    case intervalosNubososLluvia = "Intervalos nubosos con lluvia"
    case intervalosNubososTormenta = "Intervalos nubosos con tormenta"
    case nuboso = "Nuboso"
    case nubosoLluviaEscasa = "Nuboso con lluvia escasa"
    case nubosoLluvia = "Nuboso con lluvia"
    case nubosoTormenta = "Nuboso con tormenta"
    case muyNuboso = "Muy nuboso"
    case muyNubosoLluviaEscasa = "Muy nuboso con lluvia escasa"
    case muyNubosoLluvia = "Muy nuboso con lluvia"
    case muyNubosoTormenta = "Muy nuboso con tormenta"
    case niebla = "Niebla"
    case bruma = "Bruma"
    case nubesAltas = "Nubes altas"
    case error = ""
}

// MARK: - AEMETWind
/// - Parameter value: fastest wind speed
struct AEMETWind: Codable {
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

typealias AEMETRoot = [AEMETHourlyPredictionContainer]

struct GenericAEMETResponse: Codable {
    
    let descripcion: String
    let estado: Int
    let datos: String
    let metadatos: String
    
}


// MARK: - Towns

struct AEMETTown: Codable, Hashable {
    let nombre, id: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
