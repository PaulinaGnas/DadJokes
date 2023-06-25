//
//  ContentView.swift
//  Dad Jokes
//
//  Created by Paulina Gnas on 25/06/2023.
//

import SwiftUI

struct Joke: Codable {
    let id: String
    let joke: String
    let status: Int
}

class ViewModel: ObservableObject {
    @Published var joke: Joke?
    
    func getJoke() {
        let url = URL(string: "https://icanhazdadjoke.com/")!
        let headers = [
            "Accept": "application/json"
        ]
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                do {
                    let joke = try JSONDecoder().decode(Joke.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.joke = joke
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State var isAnimating = false
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                Circle()
                    .stroke(.gray.opacity(0.1), lineWidth: 40)
                    .frame(width: 260, height: 260, alignment: .center)
                Circle()
                    .stroke(.gray.opacity(0.1), lineWidth: 80)
                    .frame(width: 260, height: 260, alignment: .center)
            }
                .blur(radius: isAnimating ? 0 : 10)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .animation(.easeOut(duration: 1), value: isAnimating)
                Image("oldMan")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 500)
                    .offset(y: isAnimating ? 20 : -20)
                    .animation(
                        Animation
                            .easeInOut(duration: 4)
                            .repeatForever()
                        , value: isAnimating
                    )
            }
            Text(viewModel.joke?.joke ?? "No joke")
                .fontWeight(.medium)
                .padding(5)
            
            Button {
                viewModel.getJoke()
            } label: {
                ZStack {
                    Capsule()
                        .frame(width: 200, height: 50)
                    Text("New joke")
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .onAppear {
            viewModel.getJoke()
            isAnimating = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
