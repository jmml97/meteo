//
//  ContentView.swift
//  Shared
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var favouriteTownManager: FavouriteTownManager
    
    @State var isSheetOpened = false
    
    var body: some View {
        NavigationView  {
            VStack {
                List(favouriteTownManager.favouriteTowns, id: \.id) { town in
                    //Text(town.nombre)
                    NavigationLink(
                        destination: PredictionView(townID: town.id),
                        label: {
                            Text(town.nombre)
                        })
                }.sheet(isPresented: self.$isSheetOpened, onDismiss: {
                    print("dismiss")
                }) {
                    TownListView(isSheetOpened: self.$isSheetOpened).environmentObject(self.favouriteTownManager)
                }.navigationTitle("Municipios")
                .navigationBarItems(trailing: Button(action: {
                    self.isSheetOpened = true
                }, label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Añadir")
                    }
                }))
                Spacer()
                Text("Datos proporcionados por la Agencia Estatal de Meteorología")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(FavouriteTownManager())
    }
}
