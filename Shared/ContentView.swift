//
//  ContentView.swift
//  Shared
//
//  Created by José María Martín Luque on 02/07/2020.
//

import SwiftUI

struct ContentView: View {
    
    @State var isSheetOpened = false
    
    var body: some View {
        NavigationView  {
            #if os(iOS)
            FavouriteTownListView(isSheetOpened: $isSheetOpened)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        self.isSheetOpened = true
                    },
                    label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Añadir")
                        }
                    }
                )
            )
            #else
            FavouriteTownListView(isSheetOpened: $isSheetOpened)
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TownStore())
    }
}

struct FavouriteTownListView: View {
    
    @EnvironmentObject var townStore: TownStore
    
    @Binding var isSheetOpened: Bool
    
    var body: some View {
        VStack {
            List(favouriteTownManager.favouriteTowns, id: \.id) { town in
                NavigationLink(
                    destination: PredictionView(townID: town.id),
                    label: {
                        Text(town.name)
                    })
            }.sheet(isPresented: self.$isSheetOpened, onDismiss: {
                print("dismiss")
            }) {
                TownListView(isSheetOpened: self.$isSheetOpened).environmentObject(self.townStore)
            }.navigationTitle("Municipios")
            Spacer()
            #if os(macOS)
            Button(action: {
                self.isSheetOpened.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Añadir municipio")
                }
            }.buttonStyle(BorderlessButtonStyle())
            #endif
            Text("Datos proporcionados por la Agencia Estatal de Meteorología").padding()
        }
    }
}
