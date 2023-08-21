//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 21.08.23.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsDataManager {
    
    let isActive : Bool = true
    
    func getTitle() -> (title:String?, error: Error?) {
        if isActive {
            return ("New Text!", nil)

        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    
    // We want to throw an error back out of this function
    func getTitle3() throws -> String {
       
        /*
        if isActive {
            return "New Text 3"
        } else {
            throw URLError(.badServerResponse)
        }
        */
        
        throw URLError(.badServerResponse)
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text 4"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}


class DoCatchTryThrowsViewModel: ObservableObject {
    @Published var text:String = "Starting text.."
    let manager = DoCatchTryThrowsDataManager()
    
    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
        */
        
        // If we dont use try then it will show an error of call can throw, which is expecting either string or an error
        // Still showing an error after adding try because compiler tell where we going to catch an error
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
       
        do {
            // we can call as many as try in this block
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
            
        } catch {
            self.text = error.localizedDescription
        }
        
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject var vm = DoCatchTryThrowsViewModel()
    
    var body: some View {
        Text(vm.text)
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                vm.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
