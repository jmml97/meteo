//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

let weatherIcons: [AEMETDescripcion: String] = [
    .despejado: "sun.max",
    .cubierto: "cloud",
    .nuboso: "smoke",
    .niebla: "cloud.fog",
]

let isoDateFormatString = "yyyy-MM-dd'T'HH:mm:ss"

func getFormattedDateFromString(dateString: String, inFormat: String, outFormat: String) -> String {
    
    let inFormatter = DateFormatter()
    inFormatter.dateFormat = inFormat
    
    let date = inFormatter.date(from:dateString)!
    
    let outFormatter = DateFormatter()
    outFormatter.dateFormat = outFormat
    outFormatter.locale = Locale(identifier: "es_ES")
    
    return outFormatter.string(for: date)!
}

struct PredictionView: View {
    
    @StateObject var loader = PredictionDataLoader()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if let hourlyPredictions = loader.hourlyPredictionsContainer {
            VStack(alignment: .leading) {
                HStack {
                    Text(hourlyPredictions.provincia)
                    Text("Elaborado: \(getFormattedDateFromString(dateString: hourlyPredictions.elaborado, inFormat: isoDateFormatString, outFormat: "MM/dd/yyyy HH:mm"))")
                }
                .padding(10)
                Text("Predicción horaria")
                    .font(.title)
                    .padding(10.0)
                HourlyPredictionView(predictions: hourlyPredictions).navigationTitle(hourlyPredictions.nombre)
                Spacer()
                if let dailyPredictions = loader.dailyPredictionsContainer {
                    Text("Predicción diaria")
                        .font(.title)
                        .padding(10.0)
                    DailyPredictionView(predictions: dailyPredictions)
                }
            }
        } else {
            ProgressView("Cargando").onAppear {
                loader.load(townID)
            }
        }
        
    }
}

struct HourlyPredictionView: View {
    
    let predictions: AEMETHourlyPredictionContainer
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hora")
                    Text("Cielo")
                    Text("Temperatura")
                }
                ForEach(predictions.prediccion.dia, id:\.fecha) { d in
                    Text(getFormattedDateFromString(dateString: d.fecha, inFormat: isoDateFormatString, outFormat: "d MMM"))
                    let datosHorarios = Array(zip(d.temperatura, d.estadoCielo))
                    ForEach(datosHorarios, id:\.0.periodo) { dato in
                        HourlyDataView(periodo: dato.0.periodo, temp: dato.0.value, estadoCielo: dato.1.descripcion)
                    }
                }
            }
        }.padding(.leading, 10.0)
    }
}

struct HourlyDataView: View {
    
    let periodo, temp: String
    let estadoCielo: AEMETDescripcion
    
    var body: some View {
        VStack(spacing: 10) {
            Text(periodo + "h")
            Image(systemName: weatherIcons[estadoCielo, default: "tornado"])
            Text(temp + "º")
        }
    }
}

//struct PredictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PredictionView(townID: "29718")
//    }
//}

struct DailyPredictionView: View {
    
    let predictions: AEMETDailyPredictionContainer
    
    var body: some View {
        List(predictions.prediccion.dia, id:\.fecha) { d in
            HStack {
                Text(getFormattedDateFromString(dateString: d.fecha, inFormat: isoDateFormatString, outFormat: "d MMM"))
                Text("mín: " + String(d.temperatura.minima))
                Text("máx: " + String(d.temperatura.maxima))
            }
        }
    }
}

struct DailyPredictionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyPredictionView(
            predictions: AEMETDailyPredictionContainer(
                elaborado: "AEMET",
                nombre: "Villabajo",
                provincia: "Abajo",
                prediccion: AEMETDailyPrediction(dia: [AEMETDailyDayData(
                    probPrecipitacion: [AEMETProbPrecipitacion(value: 50, periodo: "0-24")],
                    cotaNieveProv: [AEMETCotaNieveProv(value: "700", periodo: "0-24")],
                    estadoCielo: [AEMETEstadoCielo(value: "", periodo: "0-24", descripcion: .despejado)],
                    viento: [AEMETDailyWind(direccion: "S", velocidad: 20, periodo: "0-24")],
                    rachaMax: [AEMETCotaNieveProv(value: "39", periodo: "0-24")],
                    temperatura: AEMETHumedadRelativa(maxima: 30, minima: 10, dato: [AEMETDato(value: 25, hora: 15)]),
                    sensTermica: AEMETHumedadRelativa(maxima: 30, minima: 10, dato: [AEMETDato(value: 25, hora: 15)]),
                    humedadRelativa: AEMETHumedadRelativa(maxima: 30, minima: 10, dato: [AEMETDato(value: 25, hora: 15)]),
                    uvMax: 10,
                    fecha: "2020-07-06T00:00:00"
                ),
                AEMETDailyDayData(
                    probPrecipitacion: [AEMETProbPrecipitacion(value: 50, periodo: "0-24")],
                    cotaNieveProv: [AEMETCotaNieveProv(value: "700", periodo: "0-24")],
                    estadoCielo: [AEMETEstadoCielo(value: "", periodo: "0-24", descripcion: .despejado)],
                    viento: [AEMETDailyWind(direccion: "S", velocidad: 20, periodo: "0-24")],
                    rachaMax: [AEMETCotaNieveProv(value: "39", periodo: "0-24")],
                    temperatura: AEMETHumedadRelativa(maxima: 34, minima: 16, dato: [AEMETDato(value: 25, hora: 15)]),
                    sensTermica: AEMETHumedadRelativa(maxima: 30, minima: 10, dato: [AEMETDato(value: 25, hora: 15)]),
                    humedadRelativa: AEMETHumedadRelativa(maxima: 30, minima: 10, dato: [AEMETDato(value: 25, hora: 15)]),
                    uvMax: 10,
                    fecha: "2020-07-07T00:00:00"
                )
                ]),
                id: 1,
                version: 1,
                origen: AEMETSource(productor: "AEMET",
                                    web: URL(string: "aemet.es")!,
                                    enlace: URL(string: "aemet.es")!,
                                    notaLegal: URL(string: "aemet.es")!,
                                    language: "es",
                                    copyright: "AEMET")
            )
        )
    }
}
