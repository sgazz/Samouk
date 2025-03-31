import SwiftUI

struct ContentView: View {
    @State private var isSettingsPresented = false
    @State private var isStatsPresented = false
    @State private var selectedLetter: String?
    
    var body: some View {
        NavigationView {
            LetterView(letter: selectedLetter)
                .navigationTitle("Učenje pisanja")
                .navigationBarItems(
                    leading: Button(action: {
                        isStatsPresented = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                    },
                    trailing: Button(action: {
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gear")
                    }
                )
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        .sheet(isPresented: $isStatsPresented) {
            NavigationView {
                LearningStatsView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 