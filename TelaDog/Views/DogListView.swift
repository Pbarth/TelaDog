//
//  DogListView.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 03/04/2023.
//

import SwiftUI

struct DogListView: View {
    @StateObject private var viewModel: DogListViewModel = DogListViewModel()
    @State private var searchText: String = ""
    
    var searchResults: [Dog] {
        if searchText.isEmpty {
            return viewModel.dogs
        } else {
            return viewModel.dogs.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List(searchResults, id: \.id) { dog in
            NavigationLink(dog.name, value: dog)
        }
        .navigationDestination(for: Dog.self) { dog in
            DogDetailsView(dog: dog)
        }
        .searchable(text: $searchText)
        .onAppear {
            viewModel.fetchResults()
        }
        .navigationTitle(Text("Dog list"))
    }
}

struct DogListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DogListView()
        }
    }
}
