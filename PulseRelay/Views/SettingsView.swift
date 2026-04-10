import SwiftUI
import StoreKit

// MARK: - SettingsView

struct SettingsView: View {

    @AppStorage("webhookURL")        private var webhookURLString: String = ""
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    @AppStorage("velocityThreshold")   private var velocityThreshold: Double = 0.80

    @State private var webhookURLInput: String = ""
    @State private var showWebhookSheet: Bool = false
    @State private var showSubscriptionSheet: Bool = false
    @State private var isPulseTier: Bool = false
    @State private var urlError: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                // ── Subscription ────────────────────────────────────────────
                Section {
                    HStack {
                        Label("Pulse Tier", systemImage: "bolt.fill")
                            .foregroundStyle(.yellow)
                        Spacer()
                        if isPulseTier {
                            Text("Active")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.green)
                        } else {
                            Button("Upgrade") {
                                showSubscriptionSheet = true
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                            .controlSize(.small)
                        }
                    }
                } header: {
                    Text("Subscription")
                } footer: {
                    Text("Pulse Tier unlocks real-time alerts and outbound webhooks.")
                }

                // ── Notifications ───────────────────────────────────────────
                Section("Alerts") {
                    Toggle(isOn: $enableNotifications) {
                        Label("Breaking Pulse Alerts", systemImage: "bell.badge.fill")
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Velocity Threshold", systemImage: "speedometer")
                            Spacer()
                            Text("\(Int(velocityThreshold * 100))%")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $velocityThreshold, in: 0.5...1.0, step: 0.05)
                            .tint(.accentColor)
                    }
                }

                // ── Webhook ──────────────────────────────────────────────────
                Section {
                    if webhookURLString.isEmpty {
                        Button {
                            webhookURLInput = ""
                            urlError = nil
                            showWebhookSheet = true
                        } label: {
                            Label("Configure Webhook", systemImage: "link.badge.plus")
                        }
                        .disabled(!isPulseTier)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Active Webhook")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(webhookURLString)
                                .font(.system(size: 13, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Button(role: .destructive) {
                            webhookURLString = ""
                        } label: {
                            Label("Remove Webhook", systemImage: "trash")
                        }
                    }
                } header: {
                    Text("Outbound Webhook")
                } footer: {
                    Text("Pinned trends are sent as JSON to your Discord/Slack/IFTTT endpoint. Requires Pulse Tier.")
                }

                // ── About ────────────────────────────────────────────────────
                Section("About") {
                    HStack {
                        Text("PulseRelay")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    Label("Privacy-first · Zero login · No tracking", systemImage: "lock.shield.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        // Webhook config sheet
        .sheet(isPresented: $showWebhookSheet) {
            webhookSheet
        }
        // StoreKit subscription sheet
        .sheet(isPresented: $showSubscriptionSheet) {
            subscriptionSheet
        }
        .task {
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Webhook Sheet

    private var webhookSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 48))
                    .foregroundStyle(.accentColor)

                Text("Outbound Webhook")
                    .font(.system(size: 22, weight: .black))

                Text("Enter a Discord, Slack, or IFTTT webhook URL.\nPinned trends will be sent as JSON payloads.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("https://", text: $webhookURLInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if let err = urlError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showWebhookSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWebhook() }
                        .disabled(webhookURLInput.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Subscription Sheet (StoreKit 2)

    private var subscriptionSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.yellow)

                Text("Unlock Pulse Tier")
                    .font(.system(size: 26, weight: .black))

                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "bell.badge.fill",  text: "Real-time Breaking Pulse alerts")
                    FeatureRow(icon: "link.badge.plus",  text: "Outbound webhooks (Discord, Slack, IFTTT)")
                    FeatureRow(icon: "clock.arrow.2.circlepath", text: "Background auto-refresh")
                    FeatureRow(icon: "lock.shield.fill", text: "Privacy-first · No account required")
                }
                .padding(.horizontal, 8)

                SubscriptionStoreView(groupID: "pulse_tier_group")
                    .storeButton(.visible, for: .restorePurchases)

                Spacer()
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showSubscriptionSheet = false }
                }
            }
        }
    }

    // MARK: - Helpers

    private func saveWebhook() {
        guard let url = URL(string: webhookURLInput),
              url.scheme == "https" else {
            urlError = "Please enter a valid HTTPS URL."
            return
        }
        webhookURLString = webhookURLInput
        showWebhookSheet = false
    }

    @MainActor
    private func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productType == .autoRenewableSubscription {
                isPulseTier = true
                return
            }
        }
        isPulseTier = false
    }
}

// MARK: - FeatureRow

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.yellow)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15))
        }
    }
}

#Preview {
    SettingsView()
}
