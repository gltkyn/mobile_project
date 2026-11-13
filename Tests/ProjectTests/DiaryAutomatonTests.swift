import XCTest
@testable import mobile_project

final class DiaryAutomatonTests: XCTestCase {
    func testTodoParsing() {
        let result = DiaryAutomaton.shared.process(text: "todo add Buy milk #high due:tomorrow")
        XCTAssertTrue(result.matched)
        XCTAssertEqual(result.taskTitle, "Buy milk")
        XCTAssertEqual(result.priority, "high")
    }
}
