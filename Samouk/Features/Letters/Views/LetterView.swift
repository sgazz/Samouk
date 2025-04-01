import SwiftUI
import PencilKit

struct LetterView: View {
    @State private var canvasView = PKCanvasView()
    @State private var currentLetter: String
    @State private var showingAnimation = false
    @State private var isChecking = false
    @State private var recognitionResult: RecognitionResult?
    @State private var showConfetti = false
    
    @AppStorage("penColor") private var penColorString = "black"
    @AppStorage("penWidth") private var penWidth = 5.0
    @AppStorage("showGuideLines") private var showGuideLines = true
    
    private let handwritingService = HandwritingRecognitionService.shared
    private let sampleService = HandwritingSampleService.shared
    private let progressTracker = ProgressTracker.shared
    private let audioManager = AudioManager.shared
    
    // Gradijenti za pozadinu
    private let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "ECF2FF"),
            Color(hex: "FBFCFF")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Gradijent za dugmiće
    private let buttonGradient = LinearGradient(
        colors: [
            Color(hex: "3B82F6").opacity(0.8),
            Color(hex: "2563EB")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    init(letter: String? = nil) {
        _currentLetter = State(initialValue: letter ?? ProgressTracker.shared.getNextRecommendedLetter())
    }
    
    private var penColor: UIColor {
        switch penColorString {
            case "blue": return .systemBlue
            case "red": return .systemRed
            case "green": return .systemGreen
            default: return .black
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pozadinski gradijent
                backgroundGradient
                    .ignoresSafeArea()
                
                // Glavni sadržaj
                Group {
                    if geometry.size.width > geometry.size.height {
                        landscapeLayout(geometry: geometry)
                    } else {
                        portraitLayout(geometry: geometry)
                    }
                }
                
                // Confetti efekat
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                }
            }
        }
        .onChange(of: showingAnimation) { oldValue, newValue in
            if newValue {
                withAnimation(.spring()) {
                    // Animacija će se automatski zaustaviti nakon 2.5 sekunde
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        showingAnimation = false
                    }
                }
            }
        }
    }
    
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 25) {
            // Leva strana - kontrole
            VStack(spacing: 20) {
                makeModernButton(
                    title: "Obriši",
                    icon: "trash",
                    color: .red,
                    action: {
                        withAnimation(.spring()) {
                            canvasView.drawing = PKDrawing()
                            recognitionResult = nil
                        }
                    }
                )
                
                makeModernButton(
                    title: "Prikaži",
                    icon: "play.circle.fill",
                    color: .blue,
                    action: {
                        withAnimation(.spring()) {
                            showingAnimation = true
                        }
                    }
                )
            }
            .frame(width: 120)
            
            // Centralni deo
            VStack(spacing: 15) {
                // Naslov sa efektom
                Text("Napiši slovo:")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(currentLetter)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)
                
                // Canvas sa efektima
                makeModernCanvas(geometry: geometry)
                    .frame(height: min(geometry.size.height * 0.7, geometry.size.width * 0.4))
                
                // Feedback sa animacijom
                if let result = recognitionResult {
                    RecognitionFeedbackView(
                        isRecognizing: isChecking,
                        confidence: result.confidence,
                        recognizedText: result.text,
                        expectedLetter: currentLetter
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            
            // Desna strana - dugme za proveru
            VStack {
                makeModernButton(
                    title: "Proveri",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    action: checkDrawing
                )
            }
            .frame(width: 120)
            .disabled(isChecking)
        }
        .padding(.horizontal, 25)
    }
    
    private func portraitLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // Naslov sa efektom
            VStack(spacing: 5) {
                Text("Napiši slovo:")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(currentLetter)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.top)
            
            // Canvas sa efektima
            makeModernCanvas(geometry: geometry)
                .frame(height: min(geometry.size.width * 0.9, geometry.size.height * 0.5))
                .padding(.horizontal)
            
            // Feedback sa animacijom
            if let result = recognitionResult {
                RecognitionFeedbackView(
                    isRecognizing: isChecking,
                    confidence: result.confidence,
                    recognizedText: result.text,
                    expectedLetter: currentLetter
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Kontrole
            HStack(spacing: 25) {
                makeModernButton(
                    title: "Obriši",
                    icon: "trash",
                    color: .red,
                    action: {
                        withAnimation(.spring()) {
                            canvasView.drawing = PKDrawing()
                            recognitionResult = nil
                        }
                    }
                )
                
                makeModernButton(
                    title: "Prikaži",
                    icon: "play.circle.fill",
                    color: .blue,
                    action: {
                        withAnimation(.spring()) {
                            showingAnimation = true
                        }
                    }
                )
                
                makeModernButton(
                    title: "Proveri",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    action: checkDrawing
                )
            }
            .padding(.horizontal)
            .disabled(isChecking)
        }
        .padding(.vertical)
    }
    
    private func makeModernButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.15))
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                }
            )
            .foregroundColor(color)
            .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(SpringyButtonStyle())
    }
    
    private func makeModernCanvas(geometry: GeometryProxy) -> some View {
        ZStack {
            // Pozadina canvas-a
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Guide linije sa blagom providnošću
            if showGuideLines {
                GuideLines()
                    .opacity(0.1)
            }
            
            // Canvas za crtanje
            DrawingCanvas(
                canvasView: $canvasView,
                penColor: penColor,
                penWidth: penWidth
            ) { drawing in
                audioManager.playSound(.stroke)
            }
            
            // Animacija pisanja
            if showingAnimation {
                GeometryReader { geometry in
                    LetterAnimationService.shared.createAnimatedPath(
                        for: LetterModel.letterA,
                        in: geometry.size
                    )
                }
                .allowsHitTesting(false)
            }
        }
    }
    
    private func checkDrawing() {
        withAnimation(.spring()) {
            isChecking = true
            recognitionResult = nil
        }
        
        handwritingService.recognizeHandwriting(from: canvasView.drawing, for: currentLetter) { result in
            if let result = result {
                withAnimation(.spring()) {
                    recognitionResult = result
                }
                
                let isCorrect = handwritingService.validateDrawing(result.text, against: currentLetter)
                
                sampleService.saveSample(
                    letter: currentLetter,
                    drawing: canvasView.drawing,
                    confidence: result.confidence,
                    wasSuccessful: isCorrect
                )
                
                audioManager.playSound(isCorrect ? .correct : .incorrect)
                progressTracker.recordAttempt(for: currentLetter, wasSuccessful: isCorrect)
                
                if isCorrect {
                    withAnimation(.spring()) {
                        showConfetti = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.spring()) {
                            currentLetter = progressTracker.getNextRecommendedLetter()
                            canvasView.drawing = PKDrawing()
                            recognitionResult = nil
                            showConfetti = false
                        }
                    }
                }
            }
            
            withAnimation(.spring()) {
                isChecking = false
            }
        }
    }
}

// Pomoćne strukture za vizuelne efekte
struct SpringyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct ConfettiView: View {
    var body: some View {
        Canvas { context, size in
            // Implementacija confetti efekta
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView(letter: "A")
    }
} 