import Foundation

/// One Codable root. Islands, Books, Sessions, Runs, and Rhumbs are not fields.
struct BoardChart: Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var counters: [Counter]
    var litCounterID: UUID?
    var tickMarks: [TickMark]
    var missMarks: [MissMark]
    var lapMarks: [LapMark]
    var dayTallies: [DayTally]
    var undoMarks: [UndoMark]
    var snapMarks: [SnapMark]
    var onboardingComplete: Bool

    static let empty = BoardChart(
        schemaVersion: currentSchema,
        counters: [],
        litCounterID: nil,
        tickMarks: [],
        missMarks: [],
        lapMarks: [],
        dayTallies: [],
        undoMarks: [],
        snapMarks: [],
        onboardingComplete: false
    )

    var isBare: Bool {
        counters.allSatisfy(\.isArchived)
    }
}

extension BoardChart: Codable {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case counters
        case litCounterID
        case tickMarks
        case missMarks
        case lapMarks
        case dayTallies
        case undoMarks
        case snapMarks
        case onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = 1
            counters = try container.decode([Counter].self, forKey: .counters)
            litCounterID = try container.decodeIfPresent(UUID.self, forKey: .litCounterID)
            tickMarks = try container.decode([TickMark].self, forKey: .tickMarks)
            missMarks = try container.decode([MissMark].self, forKey: .missMarks)
            lapMarks = try container.decode([LapMark].self, forKey: .lapMarks)
            dayTallies = try container.decode([DayTally].self, forKey: .dayTallies)
            undoMarks = try container.decode([UndoMark].self, forKey: .undoMarks)
            snapMarks = try container.decode([SnapMark].self, forKey: .snapMarks)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported board schema \(version)."
            )
        }
        if counters.allSatisfy(\.isArchived) {
            litCounterID = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(counters, forKey: .counters)
        try container.encodeIfPresent(litCounterID, forKey: .litCounterID)
        try container.encode(tickMarks, forKey: .tickMarks)
        try container.encode(missMarks, forKey: .missMarks)
        try container.encode(lapMarks, forKey: .lapMarks)
        try container.encode(dayTallies, forKey: .dayTallies)
        try container.encode(undoMarks, forKey: .undoMarks)
        try container.encode(snapMarks, forKey: .snapMarks)
        try container.encode(onboardingComplete, forKey: .onboardingComplete)
    }
}
