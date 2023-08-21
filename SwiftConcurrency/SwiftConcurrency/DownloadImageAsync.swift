//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 21.08.23.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
          let data = data,
          let image = UIImage(data: data),
          let response = response as? HTTPURLResponse,
          response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    // In Escaping - We have to manually create completion Hander, passing an optional image and error is ok
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error? ) -> ())  {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    // In Combine -
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    // Async - We knows this function should return either return Image or throw an error, it much safer than other methods, one benefits we dont have to use Weak Self, second benefit if we forget to return it will show an error 
    func dowloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch  {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel : ObservableObject {
 
    @Published var image:UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async  {
        // First way of showing image
        /*
        // This is asynchronous code
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
        */
        
        // Second way of showing image
        /*
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
         */
        
        // Third way of showing image with Async
        let image = try? await loader.dowloadWithAsync()
        // We can do it with DispatchQueue.main thread but when we are in Async envorinment then we should use actor
        // we have to wait to load on Main thread
        await MainActor.run {
            self.image = image

        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject var vm = DownloadImageAsyncViewModel()
    
    var body: some View {
        
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250,height: 250)
                    .shadow(radius: 10)
            }
        }
        .onAppear{
           // vm.fetchImage()
            
            // To call asynchronous function add Task
            Task {
                await vm.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
