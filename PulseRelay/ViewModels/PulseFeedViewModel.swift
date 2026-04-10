import Foundation
import Observation

// MARK: - PulseFeedViewModel

@Observable
final class PulseFeedViewModel {

    // MARK: - State

    var trends: [VelocityTrend] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // View controls
    var viewMode: ViewMode = .visualCards
    var humanVerifiedOnly: Bool = false
    var selectedNiches: Set<NicheCategory> = Set(NicheCategory.allCases)

    // Pinned trends (for webhook dispatch)
    var pinnedIDs: Set<String> = []

    // MARK: - Dependencies

    private let client: PulseClientProtocol

    // MARK: - Init

    init(client: PulseClientProtocol = PulseClient()) {
        self.client = client
    }

    // MARK: - Computed Feed

    var filteredTrends: [VelocityTrend] {
        trends
            .filter { selectedNiches.contains($0.niche) }
            .filter { humanVerifiedOnly ? $0.isHuman : true }
            .sorted { $0.velocityScore > $1.velocityScore }
    }

    var breakingTrends: [VelocityTrend] {
        filteredTrends.filter(\.isBreaking)
    }

    // MARK: - Actions

    func fetchTrends() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await client.fetchVelocityTrends()
            self.trends = response.trends
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func togglePin(_ trend: VelocityTrend) {
        if pinnedIDs.contains(trend.id) {
            pinnedIDs.remove(trend.id)
        } else {
            pinnedIDs.insert(trend.id)
        }
    }

    func isPinned(_ trend: VelocityTrend) -> Bool {
        pinnedIDs.contains(trend.id)
    }

    func toggleNiche(_ niche: NicheCategory) {
        if selectedNiches.contains(niche) {
            selectedNiches.remove(niche)
        } else {
            selectedNiches.insert(niche)
        }
    }

    func isNicheSelected(_ niche: NicheCategory) -> Bool {
        selectedNiches.contains(niche)
    }
}
