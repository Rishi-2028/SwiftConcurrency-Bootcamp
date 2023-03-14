//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Rishi on 14/03/2023.
//

import SwiftUI



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
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
             let (data, response) =  try await URLSession.shared.data(from: url, delegate: nil)
             return handleResponse(data: data, response: response)
            
        } catch {
            throw error
        }
       
    }
    
    
}



class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    var loader = DownloadImageAsyncImageLoader()
    
    func fetchImage() async {
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
        
    }
    
}

struct DownloadImageAsync: View {
    @StateObject private var vm = DownloadImageAsyncViewModel()
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear{
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
