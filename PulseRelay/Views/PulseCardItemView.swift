import SwiftUI

// MARK: - SignalStrengthMeter

struct SignalStrengthMeter: View {
    let value: Double        // 0.0 – 1.0
    let color: Color

    private var bars: Int { Int((value * 5).rounded()) }   // 0 – 5 bars

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= bars ? color : color.opacity(0.2))
                    .frame(width: 5, height: CGFloat(index) * 5 + 4)
            }
        }
    }
}

// MARK: - HumanVerifiedBadge

struct HumanVerifiedBadge: View {
    var body: some View {
        Label("Human-Verified", systemImage: "checkmark.seal.fill")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.gradient)
            .clipShape(Capsule())
    }
}

// MARK: - BreakingPulseBadge

struct BreakingPulseBadge: View {
    var body: some View {
        Label("Breaking Pulse", systemImage: "bolt.fill")
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.gradient)
            .clipShape(Capsule())
    }
}

// MARK: - PulseCardItemView  (Full Visual Card)

struct PulseCardItemView: View {

    let trend: VelocityTrend
    let isPinned: Bool
    let onPin: () -> Void

    private var nicheColor: Color {
        Color(hex: trend.niche.accentColor) ?? .accentColor
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            LinearGradient(
                colors: [nicheColor.opacity(0.25), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                // ─── Header row ────────────────────────────────────────────
                HStack {
                    // Niche icon + label
                    HStack(spacing: 6) {
                        Image(systemName: trend.niche.sfSymbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(nicheColor)
                        Text(trend.niche.rawValue.uppercased())
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(nicheColor)
                            .tracking(1.2)
                    }
                    Spacer()
                    // Pin button
                    Button(action: onPin) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isPinned ? nicheColor : Color(.tertiaryLabel))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 12)

                // ─── Headline ──────────────────────────────────────────────
                Text(trend.headline)
                    .font(.system(size: 22, weight: .black, design: .default))
                    .foregroundStyle(Color(.label))
                    .lineLimit(4)
                    .padding(.bottom, 10)

                // ─── Summary ───────────────────────────────────────────────
                Text(trend.summary)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(3)
                    .padding(.bottom, 16)

                Spacer(minLength: 0)

                // ─── Badges ────────────────────────────────────────────────
                HStack(spacing: 8) {
                    if trend.isBreaking { BreakingPulseBadge() }
                    if trend.isHuman    { HumanVerifiedBadge() }
                    Spacer()
                }
                .padding(.bottom, 14)

                // ─── Metrics row ───────────────────────────────────────────
                HStack(spacing: 20) {
                    // Velocity score
                    VStack(alignment: .leading, spacing: 3) {
                        Text("VELOCITY")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .tracking(1.2)
                        Text("\(trend.velocityPercent)%")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(nicheColor)
                    }

                    // Signal strength
                    VStack(alignment: .leading, spacing: 3) {
                        Text("SIGNAL")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .tracking(1.2)
                        SignalStrengthMeter(value: trend.signalStrength, color: nicheColor)
                    }

                    Spacer()

                    // Source platform
                    VStack(alignment: .trailing, spacing: 3) {
                        Image(systemName: trend.source.sfSymbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text(trend.source.displayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: nicheColor.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - PulseListRowView  (Compact list row)

struct PulseListRowView: View {

    let trend: VelocityTrend
    let isPinned: Bool
    let onPin: () -> Void

    private var nicheColor: Color {
        Color(hex: trend.niche.accentColor) ?? .accentColor
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Niche icon bubble
            ZStack {
                Circle()
                    .fill(nicheColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: trend.niche.sfSymbol)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(nicheColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Badges
                HStack(spacing: 6) {
                    if trend.isBreaking {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.red)
                            .font(.caption2)
                    }
                    if trend.isHuman {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.caption2)
                    }
                    Text(trend.niche.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(nicheColor)
                }

                Text(trend.headline)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(.label))
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(trend.velocityPercent)%", systemImage: "waveform")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(nicheColor)
                    Label(trend.source.displayName, systemImage: trend.source.sfSymbol)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }

            Spacer()

            Button(action: onPin) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .foregroundStyle(isPinned ? nicheColor : Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Previews

#Preview("Card") {
    PulseCardItemView(
        trend: .preview,
        isPinned: false,
        onPin: {}
    )
    .padding()
}

#Preview("List Row") {
    PulseListRowView(
        trend: .preview,
        isPinned: true,
        onPin: {}
    )
    .padding()
}

// MARK: - Preview helper

extension VelocityTrend {
    static var preview: VelocityTrend {
        VelocityTrend(
            id: "prev-001",
            niche: .celestial,
            headline: "G3-Class Geomagnetic Storm Sparks Aurora Sightings at 45°N",
            summary: "NOAA Space Weather Center confirms a G3 storm making aurora visible across mid-latitudes.",
            velocityScore: 0.91,
            signalStrength: 0.88,
            mentionsLastHour: 4200,
            mentionsPrevious24h: 4600,
            source: .twitter,
            sourceURL: "https://example.com",
            isHuman: true,
            isBreaking: true,
            timestamp: Date(),
            tags: ["aurora", "geomagnetic"]
        )
    }
}
