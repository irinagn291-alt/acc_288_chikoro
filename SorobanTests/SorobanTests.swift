import XCTest
@testable import Soroban

/// Placeholder. Replace with the cases required by SPEC.md section 17.
final class SorobanTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: SorobanApp.self), "SorobanApp")
    }
}
