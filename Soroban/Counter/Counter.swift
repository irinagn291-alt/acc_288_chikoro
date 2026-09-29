import Foundation

/// A named bead on the board. Identity is the stable id; library order is the chart array.
struct Counter: Identifiable, Codable, Equatable, Sendable {
    var id: UUID
    var name: String
    var isArchived: Bool

    init(id: UUID = UUID(), name: String, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.isArchived = isArchived
    }
}
