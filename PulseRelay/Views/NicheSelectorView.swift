import SwiftUI

// MARK: - NicheSelectorView

struct NicheSelectorView: View {

    @Bindable var viewModel: PulseFeedViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(NicheCategory.allCases) { niche in
                    NicheChip(
                        niche: niche,
                        isSelected: viewModel.isNicheSelected(niche),
                        onTap: { viewModel.toggleNiche(niche) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - NicheChip

private struct NicheChip: View {
    let niche: NicheCategory
    let isSelected: Bool
    let onTap: () -> Void

    private var accentColor: Color {
        Color(hex: niche.accentColor) ?? .accentColor
    }

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 6) {
                Image(systemName: niche.sfSymbol)
                    .font(.system(size: 13, weight: .semibold))
                Text(niche.rawValue)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? accentColor.opacity(0.18)
                    : Color(.secondarySystemBackground)
            )
            .foregroundStyle(
                isSelected ? accentColor : Color(.secondaryLabel)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? accentColor : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color hex helper

extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6,
              let value = UInt64(str, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    NicheSelectorView(viewModel: PulseFeedViewModel())
}
