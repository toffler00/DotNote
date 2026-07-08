//
//  DotNoteTheme.swift
//  Orbit
//
//  Single source of truth for Dot Note design tokens (View layer only).
//  Do NOT import this from Domain / Store / Migration code.
//  Colors, fonts, spacing, radii live here — never hardcoded in the data layer.
//
//  Drop into: Rebuild/App/Design/DotNoteTheme.swift
//

import SwiftUI

// MARK: - Theme tokens

enum DotNoteTheme {

    /// Core palette. Each token resolves per color scheme (warm light / warm dark).
    /// Pure black is intentionally avoided — the dark scheme keeps the brand's warm cast.
    enum Palette {
        static func paper(_ s: ColorScheme) -> Color   { s == .dark ? Color(hex: 0x1E1916) : Color(hex: 0xFFFEF6) }
        static func card(_ s: ColorScheme) -> Color    { s == .dark ? Color(hex: 0x2A231F) : .white }
        static func ink(_ s: ColorScheme) -> Color     { s == .dark ? Color(hex: 0xF2E9DE) : Color(hex: 0x3A302B) }
        static func inkSoft(_ s: ColorScheme) -> Color  { s == .dark ? Color(hex: 0x9A8D84) : Color(hex: 0x8A7F78) }
        static func faded(_ s: ColorScheme) -> Color    { s == .dark ? Color(hex: 0x6F645D) : Color(hex: 0xCBC2B8) }
        static func accent(_ s: ColorScheme) -> Color   { s == .dark ? Color(hex: 0xC9A56A) : Color(hex: 0x8A6D3B) }
        static func hairline(_ s: ColorScheme) -> Color  { s == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.08) }

        /// Today's date fill — identical saturation across schemes.
        static let today = Color(hex: 0xE0A94F)
        static let destructive = Color(hex: 0xD0453B)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs:  CGFloat = 8
        static let sm:  CGFloat = 12
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 20
        static let xl:  CGFloat = 28
        static let xxl: CGFloat = 40
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 18
        static let xl: CGFloat = 20
    }

    /// Card elevation. Apply as `.shadow(color:radius:y:)`.
    enum Shadow {
        static let cardColor = Color.black.opacity(0.14)
        static let cardRadius: CGFloat = 12
        static let cardY: CGFloat = 6
    }
}

// MARK: - Convenience for reading the current scheme

extension DotNoteTheme.Palette {
    /// Sugar so Views can write `Palette.paper(scheme)` or, inside a View with
    /// `@Environment(\.colorScheme) var scheme`, `Palette.ink(scheme)`.
    /// For SwiftUI-native theming you may instead register these in an Asset
    /// Catalog with Any/Dark appearances and reference by name.
}

// MARK: - Entry kind → visual treatment (derived from data, defined here)

extension DotNoteEntryKind {

    func surface(_ s: ColorScheme) -> Color {
        switch self {
        case .diary:   return s == .dark ? Color(hex: 0x22301A) : Color(hex: 0xF6FCE2)
        case .drawing: return s == .dark ? Color(hex: 0x20262C) : .white
        case .memo:    return s == .dark ? Color(hex: 0x2C2519) : Color(hex: 0xFFFDF4)
        }
    }

    /// Dot / marker color — same saturation in both schemes for legibility.
    var dot: Color {
        switch self {
        case .diary:   return Color(hex: 0x7BA05B)
        case .drawing: return Color(hex: 0x5B8BB0)
        case .memo:    return Color(hex: 0xE0A94F)
        }
    }

    /// Brightened dot for use on dark surfaces (chips, meta text).
    var dotDark: Color {
        switch self {
        case .diary:   return Color(hex: 0x9DC578)
        case .drawing: return Color(hex: 0x7FB0D6)
        case .memo:    return Color(hex: 0xE6B968)
        }
    }

    func chipBackground(_ s: ColorScheme) -> Color {
        (s == .dark ? dotDark : dot).opacity(s == .dark ? 0.22 : 0.16)
    }

    func chipForeground(_ s: ColorScheme) -> Color {
        s == .dark ? dotDark : dot
    }

    var label: String {
        switch self {
        case .diary:   return "일기"
        case .drawing: return "그림"
        case .memo:    return "메모"
        }
    }
}

// MARK: - Typography

/// Font-family choices wrapped behind an enum so a brand font change never forces
/// a data migration — `DotNoteSettings.bodyFontName` stores the case rawValue only.
enum DotNoteFontTheme: String, CaseIterable, Identifiable {
    case barunGothic
    case myeongjo
    case barunpen
    case brush
    case shinb7
    case flowerRoad
    case rock

    var id: String { rawValue }

    /// PostScript / registered font name. Fonts must be listed in Info.plist `UIAppFonts`.
    var postScriptName: String {
        switch self {
        case .barunGothic: return "NanumBarunGothic"
        case .myeongjo:    return "NanumMyeongjoEco"
        case .barunpen:    return "NanumBarunpenR"
        case .brush:       return "NanumBrush"
        case .shinb7:      return "SSShinb7"
        case .flowerRoad:  return "SSFlowerRoad"
        case .rock:        return "SSRock"
        }
    }

    var displayName: String {
        switch self {
        case .barunGothic: return "바른고딕"
        case .myeongjo:    return "명조"
        case .barunpen:    return "바른펜"
        case .brush:       return "붓글씨"
        case .shinb7:      return "신비"
        case .flowerRoad:  return "플라워로드"
        case .rock:        return "록"
        }
    }

    func font(size: CGFloat) -> Font { .custom(postScriptName, size: size) }
}

/// Role-based type. Wordmark and screen titles are fixed to the brand pen face;
/// body text follows the user's saved setting.
enum DotNoteType {
    static let wordmark = DotNoteFontTheme.barunpen

    static func wordmarkFont(size: CGFloat) -> Font { wordmark.font(size: size) }

    static func body(_ settings: DotNoteSettings?) -> DotNoteFontTheme {
        DotNoteFontTheme(rawValue: settings?.bodyFontName ?? "") ?? .barunGothic
    }
}

// MARK: - Weather (label preserved for data compatibility, glyph mapped in the View)

/// Maps the legacy free-text `weather` String to an SF Symbol for display.
/// Storage keeps the original label (e.g. "맑음") so existing entries stay valid.
enum DotNoteWeather {
    static let presets = ["맑음", "구름조금", "흐림", "비", "눈", "바람"]

    static func symbolName(for label: String) -> String {
        switch label {
        case "맑음":     return "sun.max"
        case "구름조금":  return "cloud.sun"
        case "흐림":     return "cloud"
        case "비":       return "cloud.rain"
        case "눈":       return "cloud.snow"
        case "바람":     return "wind"
        default:        return "sparkles"
        }
    }
}

// MARK: - Color(hex:) helper

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8)  & 0xff) / 255,
            blue:  Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}
