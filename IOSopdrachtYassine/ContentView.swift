import SwiftUI

struct Recipe: Decodable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let ingredients: String
    let servings: String
    let instructions: String
    
  
    var name: String {
        return title
    }
    
    
    var creator: String {
        return "Unknown"
    }
    

    var imageName: String {
        return "placeholderImage"
    }
}

struct SavedRecipe {
    let id: UUID = UUID()
    let recipe: Recipe
}

struct RecipeCard: View {
    let recipe: Recipe
    @State private var isPresented = false
    @EnvironmentObject var favorites: FavoriteRecipes
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("spaghetti-bolognese-recipe")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipped()
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.white)
            Text("By \(recipe.creator)")
                .font(.subheadline)
                .foregroundColor(.white)
            Button(action: {
                if favorites.isRecipeInFavorites(recipe: recipe) {
                    favorites.removeFromFavorites(recipe: recipe)
                } else {
                    favorites.addToFavorites(recipe: recipe)
                }
            }) {
                Image(systemName: favorites.isRecipeInFavorites(recipe: recipe) ? "heart.fill" : "heart")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color(red: 40/255, green: 144/250, blue: 97/255))
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

class FavoriteRecipes: ObservableObject {
    @Published var recipes: [SavedRecipe] = []
   
    func addToFavorites(recipe: Recipe) {
        if !isRecipeInFavorites(recipe: recipe) {
            let savedRecipe = SavedRecipe(recipe: recipe)
            recipes.append(savedRecipe)
        }
    }
    

    func removeFromFavorites(recipe: Recipe) {
        recipes.removeAll { $0.recipe.id == recipe.id }
    }
    

    func isRecipeInFavorites(recipe: Recipe) -> Bool {
        return recipes.contains { $0.recipe.id == recipe.id }
    }
}

struct ContentView: View {
    @State private var recipes: [Recipe] = []
    @StateObject private var favorites = FavoriteRecipes()
    @State private var filteredRecipes: [Recipe] = []
    @State private var isMenuVisible = false
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var isLocationViewActive = false
    
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    let fontSize = 50
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color.accentColor
                    .ignoresSafeArea()
                VStack(alignment: .center) {
                    HStack {
                        Button(action: {
                            isMenuVisible.toggle()
                        }) {
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                openMaps()
                            }) {
                                Image(systemName: "map")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                            NavigationLink(destination: LocationView(), isActive: $isLocationViewActive) {
                                EmptyView()
                            }
                            Button(action: {
                                isSearching.toggle()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Spaghetti")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("LightPrimary"))
                        .font(.custom("Rubik", size: 50))
                        .frame(width: 300 , height:55, alignment: .topLeading)
                    
                    Text("Finder")
                        .fontWeight(.heavy)
                        .foregroundColor(Color("LightPrimary"))
                        .font(.custom("Rubik", size: 50))
                        .frame(width: 300 , height:55, alignment: .topTrailing)
                    
                    if isSearching {
                        TextField("Zoeken...", text: $searchText, onCommit: {
                            filterRecipes()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .foregroundColor(.black)
                        .onTapGesture {
                        }
                    }
                    
                    ScrollView {
                        LazyVGrid(columns: gridItems, spacing: 20) {
                            ForEach(filteredRecipes.isEmpty ? recipes : filteredRecipes, id: \.id) { recipe in
                                RecipeCard(recipe: recipe)
                                    .environmentObject(favorites)
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
                            
                            Text("Favorieten:")
                                .foregroundColor(.white)
                                .font(.title)
                            ForEach(favorites.recipes, id: \.id) { savedRecipe in
                                Text(savedRecipe.recipe.name)
                                    .foregroundColor(.white)
                            }
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
        .onAppear {
            fetchRecipes()
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
                    self.filterRecipes()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func filterRecipes() {
        if searchText.isEmpty {
            filteredRecipes = recipes
        } else {
            filteredRecipes = recipes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func openMaps() {
        isLocationViewActive = true
    }
}

struct RecipeDetail: View {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .cornerRadius(10)
            Text(recipe.name)
                .font(.title)
                .foregroundColor(.white)
            Text("By \(recipe.creator)")
                .font(.subheadline)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 5) {
                Text("Ingredients:")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(recipe.ingredients)
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Servings:")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(recipe.servings)
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Instructions:")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(recipe.instructions)
                    .foregroundColor(.white)
            }
            Spacer()
            Button("Terug") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .background(Color(red: 40/255, green: 144/250, blue: 97/255))
        .cornerRadius(10)
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
