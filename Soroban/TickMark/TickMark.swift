import Foundation

/// One accepted tick on the lit counter. The tally change is applied separately under max(0, value + delta).
struct TickMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var counterID: UUID
    var dayKey: Int
    var createdAt: Date

    init(id: UUID = UUID(), counterID: UUID, dayKey: Int, createdAt: Date) {
        self.id = id
        self.counterID = counterID
        self.dayKey = dayKey
        self.createdAt = createdAt
    }
}
