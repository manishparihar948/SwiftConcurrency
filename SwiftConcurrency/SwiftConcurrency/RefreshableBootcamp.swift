//
//  RefreshableBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

import SwiftUI

final class RefreshableDataService {
    
    func getData() async throws -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
      return  ["Apple","Banana","Orange","Kiwi","Lemon"].shuffled()
    }
}

@MainActor
final class RefreshableViewModel : ObservableObject {
    @Published private(set) var items: [String] = []
    let manager = RefreshableDataService()
    
    func loadData() async {
        do {
                items = try await manager.getData()
        } catch {
                print(error)
        }
    }
   
}


struct RefreshableBootcamp: View {
    
    @StateObject private var viewModel = RefreshableViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id:\.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
               await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            .task {
               await viewModel.loadData()
            }
        }
    }
}

struct RefreshableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableBootcamp()
    }
}
