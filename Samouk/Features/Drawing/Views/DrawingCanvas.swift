import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var penColor: UIColor
    var penWidth: CGFloat
    var onDrawingChanged: ((PKDrawing) -> Void)?
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: penWidth)
        canvasView.backgroundColor = .white
        canvasView.isOpaque = true
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = PKInkingTool(.pen, color: penColor, width: penWidth)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvas
        
        init(_ parent: DrawingCanvas) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.onDrawingChanged?(canvasView.drawing)
        }
    }
} 