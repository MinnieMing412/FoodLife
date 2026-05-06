import XCTest
@testable import FoodLife

final class FoodLifeTests: XCTestCase {
    func testFoodLifeAppCanBeConstructed() {
        XCTAssertNotNil(FoodLifeApp())
    }
}
