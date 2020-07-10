//
//  Models.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import Foundation

// MARK: - AEMETPredictionContainer
struct AEMETHourlyPredictionContainer: Codable {
    let created, name, province: String
    let prediction: AEMETHourlyPrediction
    let id, version: String
    let origin: AEMETSource
    
    enum CodingKeys: String, CodingKey {
        case created = "elaborado"
        case name = "nombre"
        case province = "provincia"
        case prediction = "prediccion"
        
        case id
        case version
        
        case origin = "origen"
    }
}

// MARK: - AEMETDailyPredictionContainer
struct AEMETDailyPredictionContainer: Codable {
    let created, name, province: String
    let prediction: AEMETDailyPrediction
    let id, version: Int
    let origin: AEMETSource
    
    enum CodingKeys: String, CodingKey {
        case created = "elaborado"
        case name = "nombre"
        case province = "provincia"
        case prediction = "prediccion"
        
        case id
        case version
        
        case origin = "origen"
    }
}

// MARK: - AEMETSource
struct AEMETSource: Codable {
    let creator: String
    let web, link, legalNote: URL
    let language, copyright: String
    
    enum CodingKeys: String, CodingKey {
        case creator = "productor"
        case web
        case link = "enlace"
        case legalNote = "notaLegal"
        
        case language
        case copyright
    }
}

// MARK: - AEMETHourlyPrediction
/// A prediction with hourly values.
struct AEMETHourlyPrediction: Codable {
    let day: [AEMETHourlyDayData]
    
    enum CodingKeys: String, CodingKey {
        case day = "dia"
    }
}

// MARK: - AEMETHourlyDayData
/// Contais information for a day on the hourly prediction
struct AEMETHourlyDayData: Codable {
    let sky: [AEMETSky]
    let rain, rainProbability, stormProbability, snow: [AEMETPeriodicData]
    let snowProbability, temperature, sensation, humidity: [AEMETPeriodicData]
    let wind: [AEMETWind]
    let date, sunrise, sunset: String
    
    enum CodingKeys: String, CodingKey {
        case sky = "estadoCielo"
        case rain = "precipitacion"
        case rainProbability = "probPrecipitacion"
        case stormProbability = "probTormenta"
        case snow = "nieve"
        case snowProbability = "probNieve"
        case temperature = "temperatura"
        case sensation = "sensTermica"
        case humidity = "humedadRelativa"
        
        case wind = "vientoAndRachaMax"
        case date = "fecha"
        case sunrise = "orto"
        case sunset = "ocaso"
    }
}

// MARK: - AEMETHourlyGenericData
/// A generic contanier `value` - `periodo` that stores information of a parameter for a certain period of time
struct AEMETPeriodicData: Codable {
    let value: String
    let period: String?
    
    enum CodingKeys: String, CodingKey {
        case value
        case period = "periodo"
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            period = try? container.decode(String.self, forKey: .period)
            do {
                value = try String(container.decode(Int.self, forKey: .value))
            } catch DecodingError.typeMismatch {
                value = try container.decode(String.self, forKey: .value)
            }
        }
}

// ---------------------

// MARK: - AEMETDailyPrediction
struct AEMETDailyPrediction: Codable {
    let day: [AEMETDailyDayData]
    
    enum CodingKeys: String, CodingKey {
        case day = "dia"
    }
}

// MARK: - AEMETDailyDayData
struct AEMETDailyDayData: Codable {
    let rainProbability: [AEMETPeriodicData]
    let snowLevel: [AEMETPeriodicData]
    let sky: [AEMETSky]
    let wind: [AEMETDailyWind]
    let maxWindGust: [AEMETPeriodicData]
    let temperature, sensation, humidity: AEMETPeriodicDataWithMaxMin
    let maxUV: Int?
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case rainProbability = "probPrecipitacion"
        case snowLevel = "cotaNieveProv"
        case sky = "estadoCielo"
        case wind = "viento"
        case maxWindGust = "rachaMax"
        case temperature = "temperatura"
        case sensation = "sensTermica"
        case humidity = "humedadRelativa"
        
        case maxUV = "uvMax"
        case date = "fecha"
    }
}

// MARK: - AEMETHumedadRelativa
struct AEMETPeriodicDataWithMaxMin: Codable {
    let max, min: Int
    let periodicData: [AEMETData]
    
    enum CodingKeys: String, CodingKey {
        case max = "maxima"
        case min = "minima"
        case periodicData = "dato"
    }
    
}

// MARK: - AEMETDato
struct AEMETData: Codable {
    let value, hour: Int
    
    enum CodingKeys: String, CodingKey {
        case value
        case hour = "hora"
    }
}

// MARK: - AEMETViento
struct AEMETDailyWind: Codable {
    let direction: String
    let speed: Int
    let period: String?
    
    enum CodingKeys: String, CodingKey {
        case direction = "direccion"
        case speed = "velocidad"
        case period = "periodo"
    }
}

// ---------------------

// MARK: - AEMETEstadoCielo
struct AEMETSky: Codable {
    let value:String
    let period: String?
    let description: AEMETSkyDescription
    
    enum CodingKeys: String, CodingKey {
        case value
        case period = "periodo"
        case description = "descripcion"
    }
}

enum AEMETSkyDescription: String, Codable {
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
    let direction: [AEMETDireccion]?
    let speed: [String]?
    let period: String
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case direction = "direccion"
        case speed = "velocidad"
        case period = "periodo"
        case value
    }
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
    
    let description: String
    let status: Int
    let data: String
    let metadata: String
    
    enum CodingKeys: String, CodingKey {
        case description = "descripcion"
        case status = "estado"
        case data = "datos"
        case metadata = "metadatos"
    }
    
}


// MARK: - Towns

struct AEMETTown: Codable, Hashable {
    let name, id: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
