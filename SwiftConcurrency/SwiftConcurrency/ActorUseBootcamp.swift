//
//  ActorUseBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 25.08.23.
//

import SwiftUI
//
// 1. What is the problems that actor are solving ?
// 2. How was this problem solved prior to actors ?
// 3. Actors can solve the problem!

// App is running
// Classes is not Thread Safe
// Take this class and make Thread Safe
// Before actors solve the problem with DispatchQueue, lock and queues inside the class
class MyDataManager {
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    // create dispatchQueue label
    private let lock = DispatchQueue(label: "com.manishparihar.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title : String?) -> ()) {
        lock.async{
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
}

// Actor is Thread Safe by default
// This code is easier to read than above class
// when we go to the actor we actually calling await, before we going to the actor
// Better and eassier to use in any multithreaded environment
actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    
    let myRandomText = "Something"
    
    nonisolated let mySecondRandomText = "Hey Random"
    
    func getRandomData() -> String? {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            return self.data.randomElement()
    }
    
    // By default all the data in here inside actor is ISOLATED
    // But if we want to access this funtion so we need to make NOT ISOLATED
    // below line means this function is not isolated to the actor
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
}


struct HomeView: View {
    
    let manager = MyActorDataManager.instance // Singleton Class
    @State private var text : String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            Task {
                let newString =  await manager.getSavedData()
                // it is showing asynchoronus because it is isolated
                let myanotherString = manager.myRandomText
                
                let mySecondRand = manager.mySecondRandomText
            }
        })
        .onReceive(timer) { _ in
            Task {
              if let data = await manager.getRandomData() {
                    // switch to main thread
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = manager.getRandomData() {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct BrowseView: View {
    
    
    let manager = MyActorDataManager.instance // Singleton Class
    @State private var text : String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
              if let data = await manager.getRandomData() {
                    // switch to main thread
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = manager.getRandomData() {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}


struct ActorUseBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browser", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorUseBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorUseBootcamp()
    }
}
