import Foundation
import SwiftData

// MARK: - NicheManager

@MainActor
final class NicheManager: ObservableObject {

    // Published list of currently selected niche categories (max 12).
    @Published private(set) var selectedCategories: [NicheCategory] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadFromStore()
    }

    // MARK: - Public Interface

    var isAtCapacity: Bool { selectedCategories.count >= 12 }

    func isSelected(_ niche: NicheCategory) -> Bool {
        selectedCategories.contains(niche)
    }

    func toggle(_ niche: NicheCategory) {
        if isSelected(niche) {
            deselect(niche)
        } else if !isAtCapacity {
            select(niche)
        }
    }

    func select(_ niche: NicheCategory) {
        guard !isSelected(niche), !isAtCapacity else { return }
        let record = SelectedNiche(category: niche)
        modelContext.insert(record)
        save()
        selectedCategories.append(niche)
    }

    func deselect(_ niche: NicheCategory) {
        guard isSelected(niche) else { return }
        let raw = niche.rawValue
        let descriptor = FetchDescriptor<SelectedNiche>(
            predicate: #Predicate { $0.categoryRaw == raw }
        )
        if let record = try? modelContext.fetch(descriptor).first {
            modelContext.delete(record)
            save()
        }
        selectedCategories.removeAll { $0 == niche }
    }

    /// Resets to all 12 niches selected.
    func selectAll() {
        NicheCategory.allCases.forEach { select($0) }
    }

    /// Removes all niche selections.
    func clearAll() {
        NicheCategory.allCases.forEach { deselect($0) }
    }

    // MARK: - Persistence Helpers

    private func loadFromStore() {
        let descriptor = FetchDescriptor<SelectedNiche>(
            sortBy: [SortDescriptor(\.addedAt)]
        )
        let records = (try? modelContext.fetch(descriptor)) ?? []
        selectedCategories = records.compactMap(\.category)
    }

    private func save() {
        try? modelContext.save()
    }
}
