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
                    trailing: HStack {
                        EditButton()
                        Button(
                            action: {
                                self.isSheetOpened = true
                            },
                            label: {
                                Text("Añadir")
                            }
                        )
                    }
                    
                )
            #else
            FavouriteTownListView(isSheetOpened: $isSheetOpened)
            VStack {
                Spacer()
                Text("Selecciona un municipio")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                Spacer()
            }
            .background(Color(NSColor.controlBackgroundColor))
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TownStore())
    }
}
