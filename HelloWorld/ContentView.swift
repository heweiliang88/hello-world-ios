import SwiftUI

struct ContentView: View {
    @State private var tapCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "swift")
                .font(.system(size: 72))
                .foregroundStyle(.orange)

            Text("Hello, World!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Built on GitHub Actions")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("点我 \(tapCount) 次") {
                tapCount += 1
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
    }
}
