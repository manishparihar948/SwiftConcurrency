//
//  PhotoPickerBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 27.08.23.
//

import SwiftUI
import PhotosUI


@MainActor
final class PhotoPickerViewModel: ObservableObject {
    @Published private(set) var selectedImage : UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
         // Anytime we trigger "@Published var imageSelection: PhotosPickerItem? = nil" value this didSet get triggered
            setImage(from: imageSelection)
        }
    }
    
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
//            if let data = try? await selection.loadTransferable(type: Data.self) {
//                if let uiImage = UIImage(data: data){
//                    selectedImage = uiImage
//                    return
//                }
//            }
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            }
            catch {
                print(error)
            }
        }
    }
}

struct PhotoPickerBootcamp: View {
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Hello World")
            
            if let image = viewModel.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width:200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the photo picker!")
                    .foregroundColor(.red)
            }
        }
    }
}

struct PhotoPickerBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerBootcamp()
    }
}
