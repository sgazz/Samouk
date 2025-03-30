import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("penColor") private var penColorString = "black"
    @AppStorage("penWidth") private var penWidth = 5.0
    @AppStorage("showGuideLines") private var showGuideLines = true
    
    private let availableColors = ["black", "blue", "red", "green"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Olovka")) {
                    Picker("Boja", selection: $penColorString) {
                        ForEach(availableColors, id: \.self) { color in
                            Text(color.capitalized)
                        }
                    }
                    
                    VStack {
                        Text("Debljina: \(Int(penWidth))")
                        Slider(value: $penWidth, in: 1...20, step: 1)
                    }
                }
                
                Section(header: Text("Pomoć pri pisanju")) {
                    Toggle("Prikaži pomoćne linije", isOn: $showGuideLines)
                }
                
                Section {
                    Button(action: {
                        ProgressTracker.shared.resetProgress()
                    }) {
                        Text("Resetuj napredak")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Podešavanja")
            .navigationBarItems(trailing: 
                Button("Zatvori") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 