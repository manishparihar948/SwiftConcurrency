//
//  StrongWeakAsyncAwaitBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

import SwiftUI

final class StrongSelfDataService {
    
    func getData() async -> String {
        "Updated data"
    }
}

final class StrongWeakViewModel : ObservableObject {
    
    @Published var data : String = "Some Title"
    let dataService = StrongSelfDataService()
    
    private var someTask : Task<Void, Never>? = nil
    private var myTask : [Task<Void, Never>] = []

    
    func cancelTask() {
        someTask?.cancel()
        someTask = nil
        
        myTask.forEach({ $0.cancel() })
        myTask = []
    }
    
    // This implies a strong refrence..
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This implies a strong refrence..
    func updateData2(data:String) {
        Task {
            self.data = await dataService.getData()
        }
    }

    // This implies a strong refrence..
    func updateData3() {
        Task { [self ] in
            data = await dataService.getData()
        }
    }
    
    // This is a weak reference..
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }

    
    // We dont need to manage weak/strong
    // We can manage the Task!
    func updateData5() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // We can manage the Task here
    func updateData6() {
        
        let task1 =  Task {
            self.data = await self.dataService.getData()
        }
        myTask.append(task1)
        
        let task2 =  Task {
              self.data = await self.dataService.getData()
        }
        myTask.append(task2)
    }
    
    // We purposely do not cancel tasks to keep strong references
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    
    func updateData8() async {
        self.data = await dataService.getData()
    }
    
}

struct StrongWeakAsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = StrongWeakViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear{
                viewModel.updateData()
            }
            .onDisappear{
                viewModel.cancelTask()
            }
            .task {
                // this task will automatically cancel as view dismiss or view changes
               await viewModel.updateData8()
            }
    }
}

struct StrongWeakAsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StrongWeakAsyncAwaitBootcamp()
    }
}
