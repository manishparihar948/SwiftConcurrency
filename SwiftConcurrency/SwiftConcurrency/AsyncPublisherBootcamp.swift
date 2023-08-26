//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

import SwiftUI
import Combine

// It is not easy to use combine with async await in Swift Concurrency

class AsyncPublisherDataManager {
   
    // how can we subscribe a publish variable without use of combine
    @Published var myData : [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")

    }
}

class AsyncPublisherViewModel : ObservableObject {
   @MainActor @Published var dataArray: [String] = []
    
    let manager = AsyncPublisherDataManager()
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        // AsyncPublisher is just like subscribing to the publisher, its going to produce value over time, and we get the values in ForEach loop
        // this value manager.$myData.values is asynchronous publishers so these loop is not going to execute so we need to await the value here
        Task {
            for await value in manager.$myData.values {
                // This value should be in Main Thread affecting our UI so make dataArray as Main Actor
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
        
        /*
        manager.$myData
            .receive(on: DispatchQueue.main, options: nil)
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellables)
         */
    }
    
    func start() async {
        await manager.addData()
    }
    
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach (viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
            .task {
                await viewModel.start()
            }
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
