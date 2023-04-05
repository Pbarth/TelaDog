//
//  DogDetailsViewModel.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 03/04/2023.
//

import Combine
import SwiftUI

public class DogDetailsViewModel: ObservableObject {
    @Published var images: URL?
    @Published var selectedSubBreed: String = ""
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func fetchImages(breed: String) {
        guard let url = URLFactory.image(breed: breed, subBreed: selectedSubBreed) else {
            return
        }
        NetworkRequest()
            .url(url)
            .decodable(DogImage.self)
            .trace()
            .call()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(completion) = completion {
                    print(completion.localizedDescription)
                }
            } receiveValue: { (image: DogImage) in
                self.images = URL(string: image.message)
            }
            .store(in: &cancellables)
    }
    
    public func saveImage(image: Image) {
    }
}


struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
}

struct PhotoView: View {
    let photo: Photo

    var body: some View {
        photo.image
            .toolbar {
                ShareLink(
                    item: photo,
                    preview: SharePreview(
                        "photo.caption",
                        image: photo.image))
            }
    }
}
