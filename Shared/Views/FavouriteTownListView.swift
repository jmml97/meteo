//
//  FavouriteTownListView.swift
//  Meteo
//
//  Created by José María Martín Luque on 10/07/2020.
//

import SwiftUI

struct FavouriteTownListView: View {
    
    @EnvironmentObject var townStore: TownStore
    
    @Binding var isSheetOpened: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(townStore.favouriteTowns, id: \.id) { town in
                    NavigationLink(
                        destination: PredictionViewContainer(townID: town.id),
                        label: {
                            Text(town.name)
                        })
                }
                .onDelete(perform: townStore.removeFavouriteTown)
                .onMove(perform: townStore.moveFavouriteTown)
            }
            .sheet(isPresented: self.$isSheetOpened, onDismiss: {
                print("dismiss")
            }) {
                TownListView(isSheetOpened: self.$isSheetOpened).environmentObject(self.townStore)
            }
            .navigationTitle("Municipios")
            Spacer()
            #if os(macOS)
            Button(action: {
                self.isSheetOpened.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Añadir municipio")
                }
            }.buttonStyle(BorderlessButtonStyle()).padding(.leading)
            #endif
            Text("Datos proporcionados por la Agencia Estatal de Meteorología").padding()
        }
    }
    
}
