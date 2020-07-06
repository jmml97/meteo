//
//  SearchBar.swift
//  Meteo
//
//  https://medium.com/@axelhodler/creating-a-search-bar-for-swiftui-e216fe8c8c7f
//

import SwiftUI

#if os(macOS)

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

#else

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

#endif
