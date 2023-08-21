//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 21.08.23.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let title = "Title2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)

            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
       try? await Task.sleep(nanoseconds: 2_000_000_000) // For 2 Seconds
        
        let author2 = "Author2 : \(Thread.current)"
        // If you are unsure on which thread you are calling UI, Then make sure to switch to Main Thread before updating the UI
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1 : \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(something1)
        })
        
        let something2 = "Something2 : \(Thread.current)"
        self.dataArray.append(something2)

        
    }
    
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject var vm  = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(vm.dataArray, id:\.self) { data in
                Text(data)
            }
        }
        .onAppear{
//            vm.addTitle1()
//            vm.addTitle2()
            Task {
                await vm.addAuthor1()
                await vm.addSomething()

                
                let finalText = "Final Text: \(Thread.current)"
                vm.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
