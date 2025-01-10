import SwiftUI

/// Loading component for views
///
/// ```
/// LoaderView(isAnimating: $isAnimating, speed: 1.0)
/// ```
///
/// - Parameters:
///     - isLoading: if the view should be animating or not
///     - speed: a double of the speed of the animation
///
/// - Returns: A SwiftUI view that shows a wave form for loading
struct LoaderView: View {
    var isLoading: Bool
    var speed: Double
    @State private var randomColors: [Color] = []
    @State private var isAnimating: Bool = false
    private let bars: [CGFloat] = [20, 30, 60, 30, 20, 45, 70, 45, 30, 20]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<bars.count, id: \.self) { index in
                Rectangle()
                    .frame(width: 8, height: isAnimating ?  bars[index % bars.count] : 5)
                    .foregroundColor(self.defaultColor(for: index))
                    .animation(
                        isAnimating ? Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.3)
                            .speed(speed) : .default,
                        value: isAnimating
                    )
            }
        }
        .frame(height: bars.max() ?? 0.0)
        .onAppear {
            isAnimating = isLoading
        }.onChange(of: isLoading) {
            isAnimating = isLoading
        }
    }


    private func defaultColor(for index: Int) -> Color {
        let hue = Double(index) / Double(bars.count) // Evenly spaced hues
        return Color(hue: hue, saturation: 1.0, brightness: 0.85)
    }
}

#Preview {
    @Previewable @State var isLoading = false
    @Previewable @State var speed = 1.5
    VStack(alignment:.center) {
        Spacer()
        LoaderView(isLoading: true, speed: speed)
        Spacer()
        Button(isLoading ? "Loading Off" : "Loading On") {
            isLoading.toggle()
        }
        .padding()

    }
}
