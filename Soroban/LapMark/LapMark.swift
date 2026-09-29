import Foundation

/// Written when a tick returns the lantern to the first active counter. Removed if that tick is undone.
struct LapMark: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var tickID: UUID
    var counterID: UUID
    var dayKey: Int
    var createdAt: Date

    init(id: UUID = UUID(), tickID: UUID, counterID: UUID, dayKey: Int, createdAt: Date) {
        self.id = id
        self.tickID = tickID
        self.counterID = counterID
        self.dayKey = dayKey
        self.createdAt = createdAt
    }
}
