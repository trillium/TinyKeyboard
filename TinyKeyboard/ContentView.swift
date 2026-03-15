import SwiftUI

struct ContentView: View {
    @State private var testText = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("TinyKeyboard")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("A near-invisible keyboard for voice-first input.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 12) {
                Label("Open Settings → General → Keyboard → Keyboards", systemImage: "1.circle.fill")
                Label("Tap \"Add New Keyboard...\"", systemImage: "2.circle.fill")
                Label("Select \"TinyKeyboard\"", systemImage: "3.circle.fill")
                Label("Switch to it using the globe key", systemImage: "4.circle.fill")
            }
            .font(.callout)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 20)

            // Test input field
            TextField("Test input here...", text: $testText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .padding(.top, 20)
        }
        .padding()
    }
}
