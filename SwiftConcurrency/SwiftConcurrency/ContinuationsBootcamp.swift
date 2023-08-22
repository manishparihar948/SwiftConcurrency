//
//  ContinuationsBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 22.08.23.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    
    // this is asynchronous function
    func getData(url : URL) async throws -> Data {
        do {
        let (data, _) =  try await URLSession.shared.data(from: url, delegate: nil)
        return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url : URL) async throws -> Data {
        // Use of continuation
        // withunsafeContinuation - telling the compiler, when you are checking it yourself,you are sure there are no errors in the code, there are performance benefits by using it
       return try await withCheckedThrowingContinuation { continuation in
           URLSession.shared.dataTask(with: url) { data, response, error in
               if let data = data {
                   continuation.resume(returning: data)
               } else if let error = error {
                   continuation.resume(throwing: error)
               } else {
                   continuation.resume(throwing: URLError(.badURL))
               }
           }
           .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage
    ) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
       await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    
}

class ContinuationViewModel : ObservableObject {
    
    @Published var image: UIImage? = nil
    // create a reference to above Network Manager
    let networkManager = CheckedContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/500") else { return }
        
        do {
          let data =  try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    /*
    func getHeartImage() {
        networkManager.getHeartImageFromDatabase { [weak self] image in
            self?.image = image
        }
    }
     */
    
    func getHeartImage() async {
        self.image =  await networkManager.getHeartImageFromDatabase()
    }
}


struct ContinuationsBootcamp: View {
    
    @StateObject var vm = ContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width:200, height: 200)
            }
        }
        .task {
           //await vm.getImage()
            await vm.getHeartImage()
        }
    }
}

struct ContinuationsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ContinuationsBootcamp()
    }
}
