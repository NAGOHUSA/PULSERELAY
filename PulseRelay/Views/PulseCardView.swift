import SwiftUI

// MARK: - PulseCardView

/// The primary feed view. Supports `.visualCards` and `.minimalistList` modes.
struct PulseCardView: View {

    @Bindable var viewModel: PulseFeedViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Niche chip selector
            NicheSelectorView(viewModel: viewModel)
            Divider()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.filteredTrends.isEmpty {
                emptyView
            } else {
                feedContent
            }
        }
    }

    // MARK: - Feed Content

    @ViewBuilder
    private var feedContent: some View {
        switch viewModel.viewMode {
        case .visualCards:
            cardScrollView
        case .minimalistList:
            listScrollView
        }
    }

    // ── Visual Card Scroll ──────────────────────────────────────────────────

    private var cardScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredTrends) { trend in
                    PulseCardItemView(
                        trend: trend,
                        isPinned: viewModel.isPinned(trend),
                        onPin: { viewModel.togglePin(trend) }
                    )
                    .containerRelativeFrame(.horizontal) { width, _ in width }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.fetchTrends()
        }
    }

    // ── Minimalist List ─────────────────────────────────────────────────────

    private var listScrollView: some View {
        List {
            ForEach(viewModel.filteredTrends) { trend in
                PulseListRowView(
                    trend: trend,
                    isPinned: viewModel.isPinned(trend),
                    onPin: { viewModel.togglePin(trend) }
                )
                .listRowSeparator(.visible)
                .listRowBackground(Color(.systemBackground))
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchTrends()
        }
    }

    // MARK: - Auxiliary Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.4)
            Text("Fetching pulse…")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.red)
            Text("Signal Lost")
                .font(.system(size: 22, weight: .black))
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Retry") {
                Task { await viewModel.fetchTrends() }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 48))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("No Signals Found")
                .font(.system(size: 20, weight: .black))
            Text("Try deselecting \"Human-Verified Only\" or\nselecting more niches.")
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        PulseCardView(viewModel: {
            let vm = PulseFeedViewModel()
            vm.trends = [.preview]
            return vm
        }())
        .navigationTitle("Pulse")
    }
}
