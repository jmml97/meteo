//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

// MARK: Constants

let weatherIcons: [AEMETDescripcion: String] = [
    .despejado: "sun.max",
    .cubierto: "cloud",
    .nuboso: "smoke",
    .niebla: "cloud.fog",
]

let isoDateFormatString = "yyyy-MM-dd'T'HH:mm:ss"


// MARK: - Helper functions

/// Returns a string in the desired format from a string in another format
func getFormattedDateFromString(dateString: String, inFormat: String, outFormat: String) -> String {
    
    let inFormatter = DateFormatter()
    inFormatter.dateFormat = inFormat
    
    let date = inFormatter.date(from:dateString)!
    
    let outFormatter = DateFormatter()
    outFormatter.dateFormat = outFormat
    outFormatter.locale = Locale(identifier: "es_ES")
    
    return outFormatter.string(for: date)!
}

// MARK: - Views

/// Main prediction view
/// - Parameter townID: id of the town this view represents, needed to pull data
struct PredictionView: View {
    
    @ObservedObject var loader = PredictionDataLoader()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if let hourlyPredictions = loader.hourlyPredictionsContainer {
            VStack(alignment: .leading) {
                MetadataView(province: hourlyPredictions.provincia, predictionDate: hourlyPredictions.elaborado)
                .padding(10)
                HourlyPredictionView(predictions: hourlyPredictions).navigationTitle(hourlyPredictions.nombre)
                Spacer()
                if let dailyPredictions = loader.dailyPredictionsContainer {
                    DailyPredictionListView(predictions: dailyPredictions)
                }
            }
        } else {
            ProgressView("Cargando").onAppear {
                loader.load(townID)
            }
        }
        
    }
}

struct MetadataView: View {
    
    let province, predictionDate: String
    
    var body: some View {
        HStack {
            Text(province).font(Font.system(.body).smallCaps())
            Divider().frame(height: 20)
            Text("Elaboración: \(getFormattedDateFromString(dateString: predictionDate, inFormat: isoDateFormatString, outFormat: "MM/dd/yyyy HH:mm"))")
        }
    }
}

struct HourlyPredictionView: View {
    
    let predictions: AEMETHourlyPredictionContainer
    
    var body: some View {
        VStack {
            Text("Predicción horaria")
                .font(.title)
                .padding(10.0)
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
                            HourlyDataView(period: dato.0.periodo, temp: dato.0.value, sky: dato.1.descripcion)
                        }
                    }
                }
            }.padding(.leading, 10.0)
        }
    }
}

struct HourlyDataView: View {
    
    let period, temp: String
    let sky: AEMETDescripcion
    
    var body: some View {
        VStack(spacing: 10) {
            Text(period + "h")
            Image(systemName: weatherIcons[sky, default: "tornado"])
            Text(temp + "º")
        }
    }
}

/// List of each one of the daily predictions
struct DailyPredictionListView: View {
    
    let predictions: AEMETDailyPredictionContainer
    
    var body: some View {
        VStack {
            Text("Predicción diaria")
                .font(.title)
                .padding(10.0)
            List {
                ForEach(predictions.prediccion.dia, id:\.fecha) { d in
                    DailyPredictionView(date: d.fecha, min: String(d.temperatura.minima), max: String(d.temperatura.maxima))
                }
            }
        }
    }
}

struct DailyPredictionView: View {
    
    let date, min, max: String
    
    var body: some View {
        HStack {
            Text(getFormattedDateFromString(dateString: date, inFormat: isoDateFormatString, outFormat: "d MMM"))
            Divider().frame(height: 20)
            Text("mín: " + String(min))
            Text("máx: " + String(max))
        }
    }
    
}

// MARK: - Previews

struct MetadataView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetadataView(province: "Inventada", predictionDate: "2020-07-06T00:00:00")
    }
}

struct DailyPredictionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyPredictionView(date: "2020-07-06T00:00:00", min: "19", max: "34")
    }
}
