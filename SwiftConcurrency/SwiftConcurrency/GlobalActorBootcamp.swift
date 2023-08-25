//
//  GlobalActorBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 25.08.23.
//

import SwiftUI

// Why we use Global Actor

/*
@globalActor struct MyFirstGlobalActor {
    // what gloabal actor do -
    // We need shared instance of the Actor
    static var shared = MyNewDataManager()
    
}
*/

// Mark as final - mean no other class can inherit from this class
@globalActor final class MyFirstGlobalActor {
    // what gloabal actor do -
    // We need shared instance of the Actor
    static var shared = MyNewDataManager()
    
}

// Remember alway whenever we use @globalActor we use shared instance to access actor

actor MyNewDataManager {
 
    func getDataFromDatabase() ->  [String] {
        return ["One", "Two", "Three","Four", "Five","Six","Seven","Eight","Nine"]
    }
}

// Make it Main Actor when we have more than one Main Actor to display in View
@MainActor class GlobalActorViewModel: ObservableObject {

    // This dataArray is affeting our View directly so anything we update this dataArray so it need to be done in Main Thread so we need to make it @MainActor
    @Published var dataArray : [String] = []

    
   // @MainActor @Published var dataArray : [String] = []
    
    /*
    // If we have more than one MainActor then make class as @MainActor
    @MainActor @Published var dataArray1 : [String] = []
    @MainActor @Published var dataArray2 : [String] = []
    @MainActor @Published var dataArray3 : [String] = []
    @MainActor @Published var dataArray4 : [String] = []
    */
    
    
    //let manager = MyNewDataManager()
    let manager = MyFirstGlobalActor.shared
    
    // @MyFirstGlobalActor and @MainActor is same thing
    //@MyFirstGlobalActor func getData() async {
    //@MainActor func getData() async { // When we use MainActor mean Main Thread, Anything we want to make in main thread just mark it as @MainActor
        // Let image if we have really HEAVY COMPLEX METHODS
    nonisolated func getData() async {
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
             })
        }
    }
}



struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach (viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
            .task {
                await viewModel.getData()
            }
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
