import SwiftUI

/// Spacing, radii, and type steps. Views reach colour and the face only through these accessors.
enum BoardMetrics {
    static let unit: CGFloat = 8
    static let cardRadius: CGFloat = 4
    static let chipRadius: CGFloat = 2
    static let hairline: CGFloat = 1
    static let hit: CGFloat = 44
    static let rowHeight: CGFloat = 72
    static let beadColumn: CGFloat = 72
    static let pressScale: CGFloat = 0.97
    static let pressDuration: Double = 0.16
    static let sheetFrom: CGFloat = 0.96
}

enum BoardColor {
    static var background: Color { DesignTokens.bg }
    static var surface: Color { DesignTokens.surface }
    static var ink: Color { DesignTokens.ink }
    static var accent: Color { DesignTokens.accent }
    static var muted: Color { DesignTokens.muted }
}

enum BoardType {
    static var display: Font { Font.custom(DesignTokens.fontFamily, size: 44, relativeTo: .largeTitle).weight(.bold) }
    static var title: Font { Font.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title).weight(.bold) }
    static var headline: Font { Font.custom(DesignTokens.fontFamily, size: 22, relativeTo: .headline).weight(.bold) }
    static var body: Font { Font.custom(DesignTokens.fontFamily, size: 17, relativeTo: .body) }
    static var caption: Font { Font.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption) }
    static var micro: Font { Font.custom(DesignTokens.fontFamily, size: 11, relativeTo: .caption2) }
}

/// Section 3.6 empty copy. Kept off the Text/Button call so the sentences stay exact.
enum BoardCopy {
    static let bareDetail = "Add a counter to light the first bead."
    static let addCounter = "Add a counter"
    static let libraryEmpty = "Add a counter."
    static let addThenTick = "Add a counter, then tick the lit seat."
}

enum BoardFormat {
    static func tally(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayKey(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayNumber(_ value: Int) -> String {
        tally(value % 100)
    }

    static func monthYear(_ value: Int, calendar: Calendar = .current) -> String {
        var parts = DateComponents()
        parts.year = value / 10_000
        parts.month = (value / 100) % 100
        parts.day = value % 100
        guard let date = calendar.date(from: parts) else { return dayKey(value) }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .current
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: date)
    }

    static func dayLabel(_ value: Int, calendar: Calendar = .current) -> String {
        "\(dayNumber(value)) \(monthYear(value, calendar: calendar))"
    }
}

/// Primary control. Tinted glass, press scale 0.97, default, pressed, disabled, and loading.
struct GlassButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled && !isLoading
        configuration.label
            .font(BoardType.body)
            .foregroundStyle(BoardColor.ink)
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
            .background {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(BoardColor.accent.opacity(isEnabled ? 0.28 : 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .strokeBorder(BoardColor.accent.opacity(0.9), lineWidth: BoardMetrics.hairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            .opacity(isEnabled && !isLoading ? 1 : 0.45)
            .overlay {
                if isLoading {
                    ProgressView()
                        .tint(BoardColor.ink)
                }
            }
            .scaleEffect(reduceMotion || !pressed ? 1 : BoardMetrics.pressScale)
            .animation(reduceMotion ? nil : .easeOut(duration: BoardMetrics.pressDuration), value: pressed)
    }
}

/// Archive and erase. Hairline plus fill, no accent.
struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .font(BoardType.body)
            .foregroundStyle(BoardColor.ink)
            .frame(maxWidth: .infinity, minHeight: BoardMetrics.hit)
            .background {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .fill(BoardColor.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .strokeBorder(BoardColor.muted, lineWidth: BoardMetrics.hairline)
            }
            .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(reduceMotion || !pressed ? 1 : BoardMetrics.pressScale)
            .animation(reduceMotion ? nil : .easeOut(duration: BoardMetrics.pressDuration), value: pressed)
    }
}

/// Quiet index row. Press scale only. The lit tick uses GlassButtonStyle.
struct IndexPressStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed && isEnabled
        configuration.label
            .scaleEffect(reduceMotion || !pressed ? 1 : BoardMetrics.pressScale)
            .animation(reduceMotion ? nil : .easeOut(duration: BoardMetrics.pressDuration), value: pressed)
    }
}

/// Sheet title in the only face. The system navigation title stays off so UIKit cannot substitute its font.
struct SheetTitle: ViewModifier {
    var title: String

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(BoardType.headline)
                        .foregroundStyle(BoardColor.ink)
                        .lineLimit(1)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}

/// 2pt chip fill for list rows and small marks. Replaces the inset-grouped corner.
struct ChipSurface: View {
    var body: some View {
        RoundedRectangle(cornerRadius: BoardMetrics.chipRadius, style: .continuous)
            .fill(BoardColor.surface)
    }
}

extension View {
    func sheetTitle(_ title: String) -> some View {
        modifier(SheetTitle(title: title))
    }

    func indexList() -> some View {
        self
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
    }
}

/// Hairline plus a flat surface fill. The only elevation for plates that sit above the board.
struct HairlinePlate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BoardColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .strokeBorder(BoardColor.muted, lineWidth: BoardMetrics.hairline)
            }
    }
}

/// The tick verb, drawn with the same tinted glass as the primary button style.
struct TickGlass: View {
    var title: String

    var body: some View {
        Text(title)
            .font(BoardType.headline)
            .foregroundStyle(BoardColor.ink)
            .lineLimit(1)
            .frame(minWidth: BoardMetrics.hit, minHeight: BoardMetrics.hit)
            .padding(.horizontal, BoardMetrics.unit)
            .background {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(BoardColor.accent.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: BoardMetrics.cardRadius, style: .continuous)
                    .strokeBorder(BoardColor.accent.opacity(0.9), lineWidth: BoardMetrics.hairline)
            }
    }
}

/// Sheets scale from 0.96 to 1 and fade. Reduce Motion keeps opacity only.
struct SheetArrival: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (arrived ? 1 : BoardMetrics.sheetFrom))
            .opacity(arrived ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: BoardMetrics.pressDuration)) {
                    arrived = true
                }
            }
    }
}
