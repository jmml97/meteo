//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

// MARK: Constants

let weatherIcons: [AEMETSkyDescription: String] = [
    .despejado: "sun.max",
    .cubierto: "cloud",
    .cubiertoLluviaEscasa: "cloud.drizzle",
    .intervalosNubosos: "cloud.sun",
    .intervalosNubososLluvia: "cloud.sun.rain",
    .intervalosNubososLluviaEscasa: "cloud.sun.rain",
    .intervalosNubososTormenta: "cloud.sun.bolt",
    .pocoNuboso: "cloud.sun",
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
struct PredictionViewContainer: View {
    
    @ObservedObject var manager = PredictionManager()
    var townID: String
    
    @ViewBuilder
    var body: some View {
        if let hourlyPredictions = manager.hourlyPredictionsContainer {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    #if os(macOS)
                    Text(hourlyPredictions.name)
                        .font(.title)
                        .fontWeight(.bold)
                    #endif
                    MetadataView(province: hourlyPredictions.province, predictionDate: hourlyPredictions.created)
                    CurrentDataView(data: manager.getCurrentData())
                    Spacer().frame(height: 50)
                    HourlyPredictionView(prediction: manager.getHourlyPredictions()).navigationTitle(hourlyPredictions.name)
                    Spacer().frame(height: 50)
                    if let dailyPredictions = manager.dailyPredictionsContainer {
                        DailyPredictionListView(predictions: dailyPredictions)
                    }
                    Spacer()
                }.padding([.top, .leading])
            }
        } else {
            
            VStack {
                Spacer()
                ProgressView("Cargando").onAppear {
                    manager.townID = townID
                    manager.loadHourlyPredictions()
                    manager.loadDailyPredictions()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                Spacer()
            }
        }
        
    }
}

struct PredictionView: View {
    
    @Binding var manager: PredictionManager
    
    var body: some View {
        ScrollView(.vertical) {
            
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

struct CurrentDataView: View {
    
    let data: (AEMETPeriodicData, AEMETSky)
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(data.0.value + "º").font(.system(size: 36))
                Image(systemName: weatherIcons[data.1.description, default: "tornado"]).font(.system(size: 36))
            }
            Text(data.1.description.rawValue)
        }
    }
}

struct HourlyPredictionView: View {
    
    let prediction: AEMETHourlyPrediction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción horaria")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(prediction.days, id:\.date) { d in
                        VStack(alignment: .leading) {
                            Text(getFormattedDateFromString(dateString: d.date, inFormat: isoDateFormatString, outFormat: "EEEE d"))
                                .font(.subheadline)
                                .padding(.bottom)
                            let datosHorarios = Array(zip(d.temperature, d.sky))
                            HStack(spacing: 20) {
                                ForEach(datosHorarios, id:\.0.period) { dato in
                                    HourlyDataView(period: dato.0.period!, temp: dato.0.value, sky: dato.1.description)
                                }
                            }
                        }
                        Divider().frame(height: 100)
                    }
                }
            }
        }
    }
}

struct HourlyDataView: View {
    
    let period, temp: String
    let sky: AEMETSkyDescription
    
    var body: some View {
        VStack {
            Text(period + "h")
                .foregroundColor(Color.gray)
            Spacer()
            Image(systemName: weatherIcons[sky, default: "tornado"]).font(.system(size: 24))
            Spacer()
            Text(temp + "º")
                .fontWeight(.bold)
        }.frame(height: 80)
    }
}

/// List of each one of the daily predictions
struct DailyPredictionListView: View {
    
    let predictions: AEMETDailyPredictionContainer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Predicción diaria")
                .font(.headline)
            VStack {
                ForEach(predictions.prediction.day, id:\.date) { d in
                    //Text(predictions.prediction.day[0].sky[0].description)
                    DailyPredictionView(date: d.date, min: String(d.temperature.min), max: String(d.temperature.max), sky: d.sky[0].description)
                }
            }
        }
    }
}

struct DailyPredictionView: View {
    
    let date, min, max: String
    let sky: AEMETSkyDescription
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getFormattedDateFromString(dateString: date, inFormat: isoDateFormatString, outFormat: "EEEE d"))
                .font(.subheadline)
            HStack(alignment: .top) {
                Text(String(max) + "º")
                    .fontWeight(.semibold)
                Text(String(min) + "º")
                Spacer()
                Text(sky.rawValue)
                Image(systemName: weatherIcons[sky, default: "tornado"])
            }
        }.frame(maxWidth: 400)
        .padding(.top)
        
    }
    
}


// MARK: - Previews

struct MetadataView_Previews: PreviewProvider {
    
    static var previews: some View {
        MetadataView(province: "Provincia", predictionDate: "2020-07-06T00:00:00")
    }
}

struct HourlyDataView_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack {
            HourlyDataView(period: "12:00", temp: "23", sky: AEMETSkyDescription.cubierto)
            HourlyDataView(period: "13:00", temp: "25", sky: AEMETSkyDescription.despejado)
        }
        
    }
}

struct DailyPredictionView_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyPredictionView(date: "2020-07-06T00:00:00", min: "19", max: "34", sky: AEMETSkyDescription.cubierto)
    }
}
