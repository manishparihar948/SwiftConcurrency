//
//  SearchableBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

// Code Formatting : Control + i

import SwiftUI

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, indian, italian, japanese
}

final class RestaurantManager {
    
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Butter Paneer", cuisine: .indian),
            Restaurant(id: "2", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "3", title: "Pasta & Pizza", cuisine: .italian),
            Restaurant(id: "4", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "5", title: "Local Hotdog", cuisine: .american),
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    let manager = RestaurantManager()
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
        }
        catch {
            print(error)
        }
    }
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing:20) {
                ForEach(viewModel.allRestaurants, id: \.self) { restaurant in
                    restaurantRow(restaurant: restaurant)
                }
            }
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
    }
}

struct SearchableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SearchableBootcamp()
    }
}
