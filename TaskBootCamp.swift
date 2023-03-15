//
//  TaskBootCamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Rishi on 15/03/2023.
//

import SwiftUI


class TaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    
    
    
    func fetchImage() async {
        try?  await Task.sleep(nanoseconds: 2_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let(data,_) =  try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("Successfully returned Image!")
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
                NavigationLink("Click Me 🤓") {
                    TaskBootCamp()
                }
                
            }
        }
        
    }
    
    
    struct TaskBootCamp: View {
        
        @StateObject var vm = TaskViewModel()
        @State private var fetchImageTask: Task<(), Never>? = nil
        var body: some View {
            VStack {
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            }
            .onDisappear{
                fetchImageTask?.cancel()
            }
            .onAppear {
                Task {
                    fetchImageTask = Task {
                        await vm.fetchImage()
                    }
                    
                }
                
            }
        }
    }
    
    struct TaskBootCamp_Previews: PreviewProvider {
        static var previews: some View {
            TaskBootcampHomeView()
        }
    }
}
