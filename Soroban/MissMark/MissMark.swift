import Foundation

/// A refused tap on a dark counter. The lantern and the tally stay put.
struct MissMark: Identifiable, Codable, Equatable, Sendable {
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
