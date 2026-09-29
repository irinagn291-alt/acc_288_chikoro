import Foundation

/// Tracks the single lit counter id. Advance and retreat walk active counters in board order.
struct Lantern: Equatable, Sendable {
    var litCounterID: UUID?

    /// Next active id. `completedCircuit` is true when the step lands on the first active counter.
    func advanced(through activeIDs: [UUID]) -> (next: UUID?, completedCircuit: Bool) {
        guard let litCounterID, !activeIDs.isEmpty else {
            return (nil, false)
        }
        guard let index = activeIDs.firstIndex(of: litCounterID) else {
            return (activeIDs.first, false)
        }
        let nextIndex = (index + 1) % activeIDs.count
        return (activeIDs[nextIndex], nextIndex == 0)
    }

    /// Previous active id. From the first seat this steps to the last.
    func retreated(through activeIDs: [UUID]) -> UUID? {
        guard let litCounterID, !activeIDs.isEmpty else {
            return activeIDs.first
        }
        guard let index = activeIDs.firstIndex(of: litCounterID) else {
            return activeIDs.first
        }
        let previous = (index - 1 + activeIDs.count) % activeIDs.count
        return activeIDs[previous]
    }
}
