import SwiftUI

struct ContentView: View {
    @State private var isSettingsPresented = false
    @State private var selectedLetter: String?
    
    var body: some View {
        NavigationView {
            LetterView(letter: selectedLetter)
                .navigationTitle("Učenje pisanja")
                .navigationBarItems(trailing: 
                    Button(action: {
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gear")
                    }
                )
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 