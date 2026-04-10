import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    @State private var viewModel = PulseFeedViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // ── Feed tab ──────────────────────────────────────────────────
            NavigationStack {
                PulseCardView(viewModel: viewModel)
                    .navigationTitle("PulseRelay")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar { feedToolbarItems }
            }
            .tabItem {
                Label("Pulse", systemImage: "waveform")
            }
            .tag(0)

            // ── Settings tab ──────────────────────────────────────────────
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(1)
        }
        .task {
            await viewModel.fetchTrends()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var feedToolbarItems: some ToolbarContent {
        // Human-Verified filter toggle (left side)
        ToolbarItem(placement: .topBarLeading) {
            humanToggleButton
        }

        // View mode toggle (right side)
        ToolbarItem(placement: .topBarTrailing) {
            viewModeButton
        }

        // Refresh button
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                Task { await viewModel.fetchTrends() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }

    // ── Human-Verified filter toggle ────────────────────────────────────────

    private var humanToggleButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.impactOccurred()
            viewModel.humanVerifiedOnly.toggle()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: viewModel.humanVerifiedOnly
                    ? "checkmark.seal.fill"
                    : "checkmark.seal")
                    .foregroundStyle(viewModel.humanVerifiedOnly ? .green : Color(.tertiaryLabel))
                Text("Human")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(viewModel.humanVerifiedOnly ? .green : Color(.secondaryLabel))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                viewModel.humanVerifiedOnly
                    ? Color.green.opacity(0.12)
                    : Color(.secondarySystemBackground)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            viewModel.humanVerifiedOnly
                ? "Human-Verified filter ON – tap to show all"
                : "Human-Verified filter OFF – tap to show only verified"
        )
    }

    // ── View mode toggle ────────────────────────────────────────────────────

    private var viewModeButton: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .soft)
            impact.impactOccurred()
            viewModel.viewMode = viewModel.viewMode == .visualCards
                ? .minimalistList
                : .visualCards
        } label: {
            Image(systemName: viewModel.viewMode == .visualCards
                ? "list.bullet"
                : "square.stack.fill")
        }
        .accessibilityLabel("Switch to \(viewModel.viewMode == .visualCards ? "list" : "card") view")
    }
}

#Preview {
    ContentView()
}
