import Foundation

/// Running count for one counter on one calendar day. Day totals elsewhere are derived from these rows.
struct DayTally: Identifiable, Codable, Equatable, Sendable {
    var counterID: UUID
    var dayKey: Int
    var value: Int

    var id: String { "\(counterID.uuidString).\(dayKey)" }

    init(counterID: UUID, dayKey: Int, value: Int) {
        self.counterID = counterID
        self.dayKey = dayKey
        self.value = value
    }
}

/// Int day key YYYYMMDD from `Calendar.startOfDay`.
enum DayKey {
    static func make(from date: Date, calendar: Calendar) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
