import Foundation
import SwiftData

// MARK: - ViewMode

enum ViewMode: String, CaseIterable {
    case visualCards = "Visual Cards"
    case minimalistList = "List"
}

// MARK: - NicheCategory

enum NicheCategory: String, CaseIterable, Codable, Identifiable {
    case celestial       = "Space/Celestial"
    case additiveFab     = "Additive Fab"
    case privacySec      = "Privacy/Sec"
    case eMobility       = "E-Mobility"
    case experienceDesign = "Experience Design"
    case outdoorFrontier = "Outdoor Frontier"
    case dataHeritage    = "Data Heritage"
    case longevity       = "Longevity"
    case repairEconomy   = "Repair Economy"
    case agenticAI       = "Agentic AI"
    case serializedMedia = "Serialized Media"
    case legalTech       = "Legal Tech"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .celestial:        return "star.fill"
        case .additiveFab:      return "cube.fill"
        case .privacySec:       return "lock.shield.fill"
        case .eMobility:        return "bolt.car.fill"
        case .experienceDesign: return "theatermasks.fill"
        case .outdoorFrontier:  return "mountain.2.fill"
        case .dataHeritage:     return "server.rack"
        case .longevity:        return "heart.fill"
        case .repairEconomy:    return "wrench.and.screwdriver.fill"
        case .agenticAI:        return "cpu.fill"
        case .serializedMedia:  return "books.vertical.fill"
        case .legalTech:        return "building.columns.fill"
        }
    }

    var accentColor: String {
        switch self {
        case .celestial:        return "#7B61FF"
        case .additiveFab:      return "#FF6B35"
        case .privacySec:       return "#00C853"
        case .eMobility:        return "#00B0FF"
        case .experienceDesign: return "#FF4081"
        case .outdoorFrontier:  return "#69F0AE"
        case .dataHeritage:     return "#FFD740"
        case .longevity:        return "#FF5252"
        case .repairEconomy:    return "#FFAB40"
        case .agenticAI:        return "#40C4FF"
        case .serializedMedia:  return "#EA80FC"
        case .legalTech:        return "#B2DFDB"
        }
    }

    var description: String {
        switch self {
        case .celestial:        return "Comet/Aurora alerts & mission telemetry"
        case .additiveFab:      return "Viral STL files & 3D hardware breakthroughs"
        case .privacySec:       return "Zero-day vulnerabilities & encryption news"
        case .eMobility:        return "Micromobility mods & battery tech"
        case .experienceDesign: return "Theme park anomalies & resort openings"
        case .outdoorFrontier:  return "Trail alerts & gear innovations"
        case .dataHeritage:     return "NAS/Home-lab infrastructure & self-hosting"
        case .longevity:        return "Biohacking & metabolic health trends"
        case .repairEconomy:    return "DIY vehicle maintenance & Right-to-Repair"
        case .agenticAI:        return "Real-world autonomous agent use cases"
        case .serializedMedia:  return "Manga, indie game & niche series drops"
        case .legalTech:        return "E-filing shifts & municipal tech updates"
        }
    }
}

// MARK: - SelectedNiche (SwiftData Model)

@Model
final class SelectedNiche {
    @Attribute(.unique) var categoryRaw: String
    var addedAt: Date

    init(category: NicheCategory) {
        self.categoryRaw = category.rawValue
        self.addedAt = Date()
    }

    var category: NicheCategory? {
        NicheCategory(rawValue: categoryRaw)
    }
}
