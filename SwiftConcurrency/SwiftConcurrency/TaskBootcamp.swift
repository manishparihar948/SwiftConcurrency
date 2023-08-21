//
//  TaskBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 21.08.23.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    
    @Published var image : UIImage? = nil
    @Published var image2 : UIImage? = nil
    
    func fetchImage() async {
        
       try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("Image Returned Succesfully")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
                print("Image Returned Succesfully")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
}


struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click Me! 😎") {
                    TaskBootcamp()
                }
            }
        }
    }
}


struct TaskBootcamp: View {
    
    @StateObject var vm = TaskViewModel()
    @State private var fetchImageTask : Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing:40){
            if let image = vm.image {
                Image(uiImage:image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = vm.image2 {
                Image(uiImage:image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            // .task is very powerfull - SwitUI automatically cancels the task if the view disappears before the action complete. we dont have to do manually
            // if we use .task then we dont need onAppear and onDisappear
            await vm.fetchImage()
            
            // For long task - Its always better to check for long task, Task.checkCancellation 
            
        }
        /*
        .onDisappear{
            fetchImageTask?.cancel()
        }
         */
        
        /*
        // But this is Synchronous code
        .onAppear{
            self.fetchImageTask = Task {
                await vm.fetchImage()
            }
            /*
            Task {
                await vm.fetchImage()
            }
             */
            
            /*
            Task {
                // This await will run one by one means first one finish then second is loading image , but if we want concurrent task then create another task and run-
                await vm.fetchImage()
                await vm.fetchImage2()

            }
            */
            
            /*
            // Both Task will run at same time it will not wait for await to finish
            // This is asynchoronous code
            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await vm.fetchImage()
            }
            // This is asynchoronous code
            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await vm.fetchImage2()
            }
             */
            
            /*
            Task(priority: .high) {
              // try? await Task.sleep(nanoseconds:2_000_000_000)
              // instead of sleep we can use yeild
                await Task.yield()
                print("high : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                print("medium : \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .utility) {
                print("utility : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .low) {
                print("low : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .background) {
                print("background : \(Thread.current) : \(Task.currentPriority)")
            }
            */
            
            /*
            Task(priority: .low) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
                
                // Child class inherits all the metadata from parent class, for seperating we need to use detached
                /*
                Task.detached {
                    print("userInitiated2 : \(Thread.current) : \(Task.currentPriority)")
                }
                 */
            }
            */
           
           
        }
         */
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
