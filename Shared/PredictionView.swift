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
        VStack {
            HStack {
                Text(model.predictions?.provincia ?? "Provincia")
                Text("Elaborado: \(model.predictions?.elaborado ?? "")")
            }
            List((model.predictions?.prediccion.dia[0].temperatura)!, id: \.periodo) { temp in
                HStack {
                    Text(temp.periodo + "h")
                    Text(temp.value + " ºC")
                }
            }.navigationTitle(model.predictions?.nombre ?? "Ciudad")
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionView(townID: "29701")
    }
}
