//
//  MVVMWithAsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

import SwiftUI

final class MyManagerClass {
    
    func getData() async throws -> String {
        "Some Data"
    }
    
}

actor MyManagerActor {
    
    func getData() async throws -> String {
        "Some Data"
    }
}

@MainActor
final class MVVMWithAsyncAwaitViewModel : ObservableObject {
    
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    // Instead of making this MainActor we can make the class Main Actor
    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    // Instead of making this MainActor we can make the class Main Actor
    func onCallToActionButtonPressed() {
        // Instead of making this MainActor we can make the class Main Actor
      let task =  Task {
          do {
              // myData = try await managerClass.getData()
              myData = try await managerActor.getData()

          }catch {
              print(error)
          }
        }
        tasks.append(task)
    }
}

struct MVVMWithAsyncAwait: View {
    
    @StateObject private var viewModel = MVVMWithAsyncAwaitViewModel()
    
    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
    }
}

struct MVVMWithAsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        MVVMWithAsyncAwait()
    }
}
