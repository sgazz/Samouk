import SwiftUI

struct GuideLines: View {
    var lineColor: Color = .blue
    var lineOpacity: Double = 0.3
    var lineWidth: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Osnovna linija (donja)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.7))
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth))
                
                // Gornja linija
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.3))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.3))
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth))
                
                // Srednja isprekidana linija
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.5))
                }
                .stroke(lineColor, style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: [5, 5]
                ))
                .opacity(lineOpacity)
            }
        }
    }
} 