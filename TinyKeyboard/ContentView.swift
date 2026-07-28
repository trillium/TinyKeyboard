import SwiftUI

struct ContentView: View {
    @State private var testText = ""
    @State private var isEnabled = false
    @State private var showingPrivacyPolicy = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "keyboard")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)

                Text("TinyKeyboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityIdentifier("instructions-label")

                Text(
                    "A near-invisible keyboard for voice-first input. If you drive your iPhone with Talon Voice, "
                        + "Dragon, or iOS Voice Control, TinyKeyboard keeps text fields focused without the "
                        + "standard keyboard covering half your screen."
                )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .accessibilityIdentifier("instructions-subtitle")

                statusBadge

                VStack(alignment: .leading, spacing: 12) {
                    Label("Open Settings → General → Keyboard → Keyboards", systemImage: "1.circle.fill")
                    Label("Tap \"Add New Keyboard...\"", systemImage: "2.circle.fill")
                    Label("Select \"TinyKeyboard\"", systemImage: "3.circle.fill")
                    Label("Switch to it using the globe key", systemImage: "4.circle.fill")
                }
                .font(.callout)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Keyboard Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
                .accessibilityIdentifier("open-settings-button")

                // Test input field
                TextField("Test input here...", text: $testText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
                    .accessibilityIdentifier("test-text-field")

                Button("Privacy Policy") {
                    showingPrivacyPolicy = true
                }
                .font(.footnote)
                .padding(.top, 8)
                .accessibilityIdentifier("privacy-policy-button")

                Divider()
                    .padding(.horizontal, 40)

                VStack(spacing: 4) {
                    Text("Build: \(BuildInfo.buildDate)")
                    Text("Commit: \(BuildInfo.commitSHA)")
                    Text(BuildInfo.commitMessage)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .accessibilityIdentifier("build-info")
            }
            .padding()
        }
        .onAppear(perform: refreshEnabledState)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            refreshEnabledState()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }

    private var statusBadge: some View {
        Label(
            isEnabled ? "Enabled ✓" : "Not enabled yet",
            systemImage: isEnabled ? "checkmark.circle.fill" : "exclamationmark.circle"
        )
        .font(.subheadline)
        .foregroundColor(isEnabled ? .green : .orange)
        .accessibilityIdentifier("keyboard-status")
    }

    /// Best-effort check for whether TinyKeyboard is enabled: its
    /// identifier shows up in the active input modes once iOS has loaded it
    /// at least once. This can lag behind Settings state until the keyboard
    /// picker has been opened, so it's a helpful nudge, not a guarantee.
    private func refreshEnabledState() {
        isEnabled = UITextInputMode.activeInputModes.contains { mode in
            String(describing: mode).contains("com.trillium.TinyKeyboard.keyboard")
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("TinyKeyboard does not collect, transmit, store, or share any personal data.")

                    Text(
                        "The keyboard does not record keystrokes, access clipboard content, or communicate "
                            + "with any server. No network connections are made. No analytics are collected."
                    )

                    Text("The keyboard extension runs entirely on-device and has no network entitlements.")

                    Text("Last updated: 2026-07-27")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
