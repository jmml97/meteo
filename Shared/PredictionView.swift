//
//  PredictionView.swift
//  Meteo
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

struct PredictionView: View {
    
    @ObservedObject private var model: PredictionViewModel
    var townID: String
    
    init(townID: String) {
        self.townID = townID
        self.model = PredictionViewModel(townID: townID)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(model.predictions?.provincia ?? "Provincia")
                Text("Elaborado: \(model.predictions?.elaborado ?? "")")
            }
            .padding(10)
            Text("Predicción horaria")
                .font(.title)
                .padding(10.0)
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    let datosHorarios = Array(zip((model.predictions?.prediccion.dia[0].temperatura)!, (model.predictions?.prediccion.dia[0].estadoCielo)!))
                    ForEach(datosHorarios, id: \.0.periodo) { dato in
                        datoHorarioView(periodo: dato.0.periodo, temp: dato.0.value, estadoCielo: dato.1.descripcion)
                    }
                }
            }.padding(.leading, 10.0).navigationTitle(model.predictions?.nombre ?? "Ciudad")
            Spacer()
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionView(townID: "29701")
    }
}

struct datoHorarioView: View {
    
    let periodo, temp: String
    let estadoCielo: AEMETDescripcion
    
    var body: some View {
        VStack(spacing: 5) {
            Text(periodo + "h")
            switch estadoCielo {
            case AEMETDescripcion.despejado:
                Image(systemName: "sun.max")
            case AEMETDescripcion.cubierto:
                            Image(systemName: "cloud")
            case AEMETDescripcion.nuboso:
                            Image(systemName: "smoke")
            case AEMETDescripcion.niebla:
                            Image(systemName: "cloud.fog")
            default:
                Image(systemName: "tornado")
            }
            Text(temp + "º")
        }
    }
}


