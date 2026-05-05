import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PlaceholderView(
                    title: "Home",
                    description: "A local-first starting point for recent meals, seasonal memories, and the next FoodLife destination."
                )
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                PlaceholderView(
                    title: "Made",
                    description: "Food you cooked, saved as a personal archive of meals, context, and memory."
                )
            }
            .tabItem { Label("Made", systemImage: "fork.knife") }

            NavigationStack {
                PlaceholderView(
                    title: "Found",
                    description: "Food and places discovered outside, kept separate from meals made at home."
                )
            }
            .tabItem { Label("Found", systemImage: "map") }

            NavigationStack {
                PlaceholderView(
                    title: "Timeline",
                    description: "A chronological view for browsing FoodLife memories across Made and Found."
                )
            }
            .tabItem { Label("Timeline", systemImage: "calendar") }

            NavigationStack {
                PlaceholderView(
                    title: "Add Memory",
                    description: "A future entry point for capturing a Made or Found food memory."
                )
            }
            .tabItem { Label("Add Memory", systemImage: "plus.circle") }
        }
    }
}

struct PlaceholderView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.largeTitle.weight(.bold))
            Text(description)
                .foregroundStyle(.secondary)
            NavigationLink("Detail/Edit") {
                PlaceholderDetailEditView()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationTitle(title)
    }
}

struct PlaceholderDetailEditView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Detail/Edit")
                .font(.largeTitle.weight(.bold))
            Text("A future detail and edit placeholder for one local FoodLife memory.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationTitle("Detail/Edit")
    }
}
