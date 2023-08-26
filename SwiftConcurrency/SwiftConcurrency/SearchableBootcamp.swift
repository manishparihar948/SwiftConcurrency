//
//  SearchableBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 26.08.23.
//

// Code Formatting : Control + i

import SwiftUI
import Combine

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
            /*
            Restaurant(id: "6", title: "Dum Biryani", cuisine: .indian),
            Restaurant(id: "7", title: "Chicken Teryaki", cuisine: .japanese),
            Restaurant(id: "8", title: "Idli Dosa", cuisine: .indian),
             */
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = [] // This is a subset of allRestuarants
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes : [SearchScopeOption] = []
    
    let manager = RestaurantManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestions: Bool {
        // searchText.count < 3
        searchText.count < 5
    }
    
    // Create custom enum
    enum SearchScopeOption : Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        // we gonna subscribe the search text so we need $ (dollar) sign to access the published value not the current value so everytime the search text changes this search text subscribes get change.
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
        // we dont want to update the filters until the users stop typing, debounce saying everytime the search text get updated so every single character so we gonna perform some action
    
    }
    
    private func filterRestaurants(searchText:String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            self.searchScope = .all
            return
        }
        
        // Filter on search scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        
        // Filter on search text
        let search = searchText.lowercased()
        // If searchText not empty then
        
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
        //filteredRestaurants = allRestaurants.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        })
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map({ SearchScopeOption.cuisine(option: $0)
            })
        }
        catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        
        guard showSearchSuggestions else {
            return []
        }
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        suggestions.append("Market")
        suggestions.append("Grocery")
        suggestions.append(CuisineOption.indian.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantsSuggestion() -> [Restaurant] {
        guard showSearchSuggestions else {
            return []
        }
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian }))
        }
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .japanese }))
        }
        if search.contains("ind") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .indian }))
        }
       
        return suggestions
    }
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                    NavigationLink(value: restaurant) {
                        restaurantRow(restaurant: restaurant)
                    }
                }
            }
            .padding()
            
            // Text("ViewModel is searching: \(viewModel.isSearching.description)")
            // SearchChildView()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search restaurants..."))
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id:\.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions({
            
            ForEach(viewModel.getSearchSuggestions(), id:\.self){suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            
            ForEach(viewModel.getRestaurantsSuggestion(), id:\.self){suggestion in
                NavigationLink(value: suggestion) {
                    Text(suggestion.title)
                }
            }
        })
        //.navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundColor(.orange)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
}

// Create Child View
struct SearchChildView: View {
    // The Environment is the parent of the view,
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child view is searching: \(isSearching.description)")

    }
}

struct SearchableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchableBootcamp()
        }
    }
}
