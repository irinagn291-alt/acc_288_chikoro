import XCTest
@testable import Soroban

final class ReviewLaunchTests: XCTestCase {
    func testParserReadsKeyAfterFlag() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Soroban", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Soroban", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Soroban", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Soroban", "-ReviewScreen", "library"]), "library")
    }

    func testParserIgnoresANormalLaunch() {
        XCTAssertNil(ReviewLaunch.screen(in: ["Soroban"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Soroban", "-ReviewScreen"]))
    }
}
