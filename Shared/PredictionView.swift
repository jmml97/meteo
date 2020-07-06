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
        if let predictions = loader.predictions {
            VStack(alignment: .leading) {
                HStack {
                    Text(predictions.provincia)
                    Text("Elaborado: \(getFormattedDateFromString(dateString: predictions.elaborado, inFormat: isoDateFormatString, outFormat: "MM/dd/yyyy HH:mm"))")
                }
                .padding(10)
                Text("Predicción horaria")
                    .font(.title)
                    .padding(10.0)
                HourlyPredictionView(predictions: predictions).navigationTitle(predictions.nombre)
                Spacer()
            }
        } else {
            ProgressView("Cargando").onAppear {
                loader.load(townID)
            }
        }
        
    }
}

struct HourlyPredictionView: View {
    
    let predictions: AEMETRootElement
    
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

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionView(townID: "29718")
    }
}
