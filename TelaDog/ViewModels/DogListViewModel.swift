//
//  DogListViewModel.swift
//  TelaDog
//
//  Created by Pierre BARTHELEMY on 03/04/2023.
//

import Combine
import SwiftUI

public class DogListViewModel: ObservableObject {
    @Published var dogs: [Dog] = [Dog]()
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func fetchResults() {
        guard let url = URLFactory.breeds() else {
            return
        }
        NetworkRequest()
            .url(url)
            .decodable(DogList.self)
            .trace()
            .call()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(completion) = completion {
                    print(completion.localizedDescription)
                }
            } receiveValue: { (list: DogList) in
                var dogsToAdd: [Dog] = [Dog]()
                if let elements = list.message {
                    for element in elements {
                        dogsToAdd.append(Dog(name: element.key, subBreed: element.value))
                    }
                }
                
                self.dogs = dogsToAdd.sorted(by: { $0.name < $1.name })
            }
            .store(in: &cancellables)
    }
}
