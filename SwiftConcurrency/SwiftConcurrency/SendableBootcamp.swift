//
//  SendableBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 25.08.23.
//

import SwiftUI

actor CurrentUserManager {

    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

// If we have to send data from this struct to (above) actor then we need to make it Sendable
struct MyUserInfo : Sendable {
    var name : String
}

// What will happen if we make it Sendable, we know class is not thread safe, make it final so avoid warning or error so it no other class allow to inherit from here

final class MyClassUserInfo : @unchecked Sendable {
    // if we make it var name : String then we need to make class as MyClass: @unchecked Sendable that means you overriding compiler, but its not recommended approach
    private var name : String
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func update(name:String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableViewModel : ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "INFO")
        
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
