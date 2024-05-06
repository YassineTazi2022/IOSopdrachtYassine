import SwiftUI

struct Recipe: Decodable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let ingredients: String
    let servings: String
    let instructions: String
    
    // Computed property om de naam van de titel te halen
    var name: String {
        return title
    }
    
    // Computed property om een dummy creator te geven, aangezien deze niet beschikbaar is in de JSON
    var creator: String {
        return "Unknown"
    }
    
    // Computed property om een dummy imageName te geven, aangezien deze niet beschikbaar is in de JSON
    var imageName: String {
        return "placeholderImage" // Plaats hier de naam van een placeholder-afbeelding
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    @State private var isPresented = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150) // Hoogte van de afbeelding aanpassen
                .clipped()
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.white) // Tekstkleur wit maken
            Text("By \(recipe.creator)")
                .font(.subheadline)
                .foregroundColor(.white) // Tekstkleur wit maken
        }
        .padding()
        .background(Color.black) // Achtergrondkleur van de kaart zwart maken
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .onTapGesture {
            isPresented.toggle()
        }
        .fullScreenCover(isPresented: $isPresented) {
            RecipeDetail(recipe: recipe)
        }
    }
}

struct ContentView: View {
    
    @State private var recipes: [Recipe] = []
    @State private var isMenuVisible = false
    
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    let fontSize = 50
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.accentColor
                .ignoresSafeArea()
            VStack(alignment: .center) {
                HStack {
                    Button(action: {
                        isMenuVisible.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            // Handle camera icon action
                        }) {
                            Image(systemName: "camera")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        Button(action: {
                            // Handle person icon action
                        }) {
                            Image(systemName: "person")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                    }
                }
                .padding(.horizontal)
                
                Text("Hey bertie")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("LightPrimary"))
                    .font(.custom("Rubik", size: 50))
                    .frame(width: 300 , height:55, alignment: .topLeading)
                
                Text("Let's Cook")
                    .fontWeight(.heavy)
                    .foregroundColor(Color("LightPrimary"))
                    .font(.custom("Rubik", size: 50))
                    .frame(width: 300 , height:55, alignment: .topTrailing)
                
                HStack {
                    Button(action: {
                        // Handle recipe finding action
                        fetchRecipes()
                    }) {
                        Text("Recept vinden")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(recipes, id: \.id) { recipe in
                            RecipeCard(recipe: recipe)
                        }
                    }
                    .padding(.top)
                }
            }
            
            if isMenuVisible {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isMenuVisible.toggle()
                    }
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isMenuVisible.toggle()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Home")
                            .foregroundColor(.white)
                            .font(.title)
                        
                        Text("Mijn Recepten")
                            .foregroundColor(.white)
                            .font(.title)
                        
                        Text("Mijn Ingrediënten")
                            .foregroundColor(.white)
                            .font(.title)
                        
                        Text("Profiel")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .background(Color(hex: "#28361"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: 0, y: 0)
            }
        }
    }
    
    func fetchRecipes() {
        let query = "spaghetti".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "https://api.api-ninjas.com/v1/recipe?query=" + query)!
        var request = URLRequest(url: url)
        request.setValue("Tocp6yu2WBdASJRGBdZQYQ==YBCkRPY4EtBFt6SU", forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([Recipe].self, from: data)
                DispatchQueue.main.async {
                    self.recipes = decodedData
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct RecipeDetail: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Image("spaghetti-bolognese-recipe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(10)
            Text(recipe.name)
                .font(.title)
            Text("Ingredients: \(recipe.ingredients)")
            Text("Servings: \(recipe.servings)")
            Text("Instructions: \(recipe.instructions)")
            Spacer()
            Button("Terug") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
