//
//  DogDetailsView.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 03/04/2023.
//

import SwiftUI

struct DogDetailsView: View {
    
    @StateObject private var viewModel: DogDetailsViewModel = DogDetailsViewModel()
    public var dog: Dog
    
    var body: some View {
        VStack {
            if let subBreed = dog.subBreed, !subBreed.isEmpty {
                HStack {
                    Text("Sub-Breed: ")
                    Picker("Sub-breed", selection: $viewModel.selectedSubBreed) {
                        ForEach(subBreed, id: \.self) { subBreed in
                            Text(subBreed)
                                .tag(subBreed)
                        }
                    }
                    Spacer()
                }
            }
            AsyncImage(url: viewModel.images) { phase in
                switch phase {
                case .empty:
                    if let subBreed = dog.subBreed, !subBreed.isEmpty {
                        Text("Choose a sub-breed first")
                    } else {
                        ProgressView("Loading")
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .toolbar {
                            ShareLink(
                                item: image,
                                preview: SharePreview(
                                    self.dog.name,
                                    image: image))
                        }
                    
                case .failure(_):
                    Image(systemName: "error")
                @unknown default:
                    Image(systemName: "questionmark")
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchImages(breed: dog.name)
        }
        .onChange(of: viewModel.selectedSubBreed) { newValue in
            viewModel.fetchImages(breed: dog.name)
        }
        .navigationTitle(dog.name)
        
    }
}

struct DogDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DogDetailsView(dog: Dog(name: "Test", subBreed: [
                "boston",
                "english",
                "french"
            ]))
        }
    }
}
