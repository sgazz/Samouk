import SwiftUI
import CoreGraphics

class LetterAnimationService {
    static let shared = LetterAnimationService()
    
    private init() {}
    
    func createAnimatedPath(for letter: LetterModel, in size: CGSize) -> some View {
        let points = letter.normalizedPoints(for: size)
        
        return ZStack {
            // Prvo prikazujemo blede linije za celo slovo
            ForEach(0..<letter.strokeOrder.count, id: \.self) { strokeIndex in
                let indices = letter.strokeOrder[strokeIndex]
                let start = points[indices[0]]
                let end = points[indices[1]]
                
                Path { path in
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round
                ))
            }
            
            // Zatim animiramo svaki potez
            ForEach(0..<letter.strokeOrder.count, id: \.self) { strokeIndex in
                AnimatedStroke(
                    points: points,
                    strokeIndices: letter.strokeOrder[strokeIndex],
                    delay: Double(strokeIndex) * 0.5
                )
            }
        }
    }
}

struct AnimatedStroke: View {
    let points: [CGPoint]
    let strokeIndices: [Int]
    let delay: Double
    
    @State private var progress: CGFloat = 0
    
    var body: some View {
        let path = Path { path in
            let start = points[strokeIndices[0]]
            let end = points[strokeIndices[1]]
            
            path.move(to: start)
            path.addLine(to: end)
        }
        
        path.trim(from: 0, to: progress)
            .stroke(Color.blue, style: StrokeStyle(
                lineWidth: 8,
                lineCap: .round,
                lineJoin: .round
            ))
            .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        progress = 1
                    }
                }
            }
    }
}

// Preview provider
struct AnimatedStroke_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedStroke(
            points: [
                CGPoint(x: 50, y: 50),
                CGPoint(x: 200, y: 200)
            ],
            strokeIndices: [0, 1],
            delay: 0
        )
        .frame(width: 300, height: 300)
        .background(Color.white)
    }
} 