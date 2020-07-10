//
//  TownListView.swift
//  Meteo
//
//  Created by José María Martín Luque on 03/07/2020.
//

import SwiftUI

struct TownListView: View {
    
    @EnvironmentObject var townStore: TownStore
    
    @State private var searchText : String = ""
    @Binding var isSheetOpened : Bool
    
    @State var selectedTown = Set<AEMETTown>()
    
    @ViewBuilder
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Búsqueda de municipios")
            if (searchText.isEmpty) {
                VStack {
                    Spacer()
                    Text("Los resultados de la búsqueda se mostrarán aquí")
                    Spacer()
                }
            } else {
                List(townStore.getTowns(containingString: searchText), id: \.self, selection: $selectedTown) { town in
                    Text(town.name)
                }.id(UUID())
            }
            Spacer()
            Button(action: {
                if (!selectedTown.isEmpty) {
                    self.townStore.addFavouriteTown(Array(selectedTown)[0])
                }
                self.isSheetOpened = false
            }, label: {
                Text("OK")
            })
        }
    }
}

struct TownListView_Previews: PreviewProvider {
    static var previews: some View {
        TownListView(isSheetOpened: .constant(true)).environmentObject(TownStore())
    }
}
