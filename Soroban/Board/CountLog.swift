import Foundation

/// Append-only record of a tap, a lap, an undo, or a day-boundary snap. Stats read the mark arrays; this is the chronicle.
enum CountLog: Identifiable, Equatable, Sendable {
    case tick(TickMark)
    case miss(MissMark)
    case lap(LapMark)
    case undo(UndoMark)
    case snap(SnapMark)

    var id: UUID {
        switch self {
        case .tick(let mark): mark.id
        case .miss(let mark): mark.id
        case .lap(let mark): mark.id
        case .undo(let mark): mark.id
        case .snap(let mark): mark.id
        }
    }

    var createdAt: Date {
        switch self {
        case .tick(let mark): mark.createdAt
        case .miss(let mark): mark.createdAt
        case .lap(let mark): mark.createdAt
        case .undo(let mark): mark.createdAt
        case .snap(let mark): mark.createdAt
        }
    }
}

/// Reversal of one accepted tick. Delta is -1 before the max(0, value + delta) clamp.
struct UndoMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var tickID: UUID
    var counterID: UUID
    var dayKey: Int
    var delta: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        tickID: UUID,
        counterID: UUID,
        dayKey: Int,
        delta: Int = -1,
        createdAt: Date
    ) {
        self.id = id
        self.tickID = tickID
        self.counterID = counterID
        self.dayKey = dayKey
        self.delta = delta
        self.createdAt = createdAt
    }
}

/// Day-boundary note. Delta is the closed tally negated (log −old). The stored day row stays for history.
struct SnapMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var counterID: UUID
    var dayKey: Int
    var delta: Int
    var createdAt: Date

    init(id: UUID = UUID(), counterID: UUID, dayKey: Int, delta: Int, createdAt: Date) {
        self.id = id
        self.counterID = counterID
        self.dayKey = dayKey
        self.delta = delta
        self.createdAt = createdAt
    }
}
