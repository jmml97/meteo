//
//  SearchBar.swift
//  Meteo
//
//  https://medium.com/@axelhodler/creating-a-search-bar-for-swiftui-e216fe8c8c7f
//

import SwiftUI

struct SearchBar: NSViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    
    class Coordinator: NSObject, NSSearchFieldDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }
        
        func controlTextDidChange(_ notification: Notification) {
            guard let searchBar = notification.object as? NSSearchField else { return }
            text = searchBar.stringValue
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeNSView(context: NSViewRepresentableContext<SearchBar>) -> NSSearchField {
        let searchField = NSSearchField(frame: .zero)
        searchField.delegate = context.coordinator
        searchField.placeholderString = placeholder
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: NSViewRepresentableContext<SearchBar>) {
        nsView.stringValue = text
    }
}
