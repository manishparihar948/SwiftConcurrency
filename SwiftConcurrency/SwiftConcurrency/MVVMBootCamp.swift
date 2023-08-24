//
//  MVVMBootCamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 24.08.23.
//

import SwiftUI



class MVVMBootCampViewModel : ObservableObject {
    @Published var title : String = ""
    
    init() {
        print("ViewModel")
    }
}

struct MVVMBootCamp: View {
    
    @StateObject private var viewModel = MVVMBootCampViewModel()
    let isActive : Bool
    
    /*
     Why the ViewModel not being created every time ?
     Because we identified it as @StateObject - it tells the Struct not to change this between all those mutations, if we create this struct one time, this view is going to render hunderd more more time while our app is live, every time we click the screen and its create totally new struct
     We dont need to change View Model or data Manager is constant or not changing throught out the app live during the re-render of struct, and during this re-render we are accessing the same instance of the class, which is why our view model we initialized once and our view might initialized bunch of times
      
    */
    
    // we are reinitialising the view every time
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }

    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear(
               // runTest()
            )
    }
}

struct MVVMHomeView: View {
    
    @State private var isActive : Bool = false
    
    var body: some View {
        MVVMBootCamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

struct MVVMBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        MVVMBootCamp(isActive: true)
    }
}
