import Foundation

// MARK: - SourcePlatform

enum SourcePlatform: String, Codable {
    case twitter    = "twitter"
    case reddit     = "reddit"
    case hackernews = "hackernews"
    case youtube    = "youtube"
    case mastodon   = "mastodon"
    case github     = "github"
    case rss        = "rss"

    var sfSymbol: String {
        switch self {
        case .twitter:    return "bird.fill"
        case .reddit:     return "bubble.left.and.bubble.right.fill"
        case .hackernews: return "flame.fill"
        case .youtube:    return "play.rectangle.fill"
        case .mastodon:   return "antenna.radiowaves.left.and.right"
        case .github:     return "chevron.left.forwardslash.chevron.right"
        case .rss:        return "dot.radiowaves.left.and.right"
        }
    }

    var displayName: String {
        switch self {
        case .twitter:    return "X / Twitter"
        case .reddit:     return "Reddit"
        case .hackernews: return "Hacker News"
        case .youtube:    return "YouTube"
        case .mastodon:   return "Mastodon"
        case .github:     return "GitHub"
        case .rss:        return "RSS"
        }
    }
}

// MARK: - VelocityTrend

struct VelocityTrend: Identifiable, Codable, Hashable {
    let id: String
    let niche: NicheCategory
    let headline: String
    let summary: String
    let velocityScore: Double       // 0.0 – 1.0  (mentions last 60 min / last 24 h)
    let signalStrength: Double      // 0.0 – 1.0  normalised engagement
    let mentionsLastHour: Int
    let mentionsPrevious24h: Int
    let source: SourcePlatform
    let sourceURL: String
    let isHuman: Bool               // Human-Verified flag
    let isBreaking: Bool            // velocityScore > threshold
    let timestamp: Date
    let tags: [String]

    // Computed helpers
    var velocityPercent: Int { Int(velocityScore * 100) }
    var signalPercent: Int   { Int(signalStrength * 100) }

    enum CodingKeys: String, CodingKey {
        case id, niche, headline, summary
        case velocityScore     = "velocity_score"
        case signalStrength    = "signal_strength"
        case mentionsLastHour  = "mentions_last_hour"
        case mentionsPrevious24h = "mentions_previous_24h"
        case source, sourceURL = "source_url"
        case isHuman           = "is_human"
        case isBreaking        = "is_breaking"
        case timestamp, tags
    }
}

// MARK: - PulseFeedResponse

struct PulseFeedResponse: Codable {
    let trends: [VelocityTrend]
    let fetchedAt: Date
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case trends
        case fetchedAt   = "fetched_at"
        case totalCount  = "total_count"
    }
}
