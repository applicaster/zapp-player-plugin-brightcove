import XCTest
@testable import BrightcovePlayerPlugin

class BrightcovePlayerTest: XCTestCase {
    
    // MARK: - Factory methods
    
    func test_pluggablePlayerInit_noItems_returnsNil() {
        let plugin = BrightcovePlayerPlugin.pluggablePlayerInit(playableItems: nil, configurationJSON: [:])
        XCTAssertNil(plugin)
    }
    
    func test_pluggablePlayerInit_emptyArray_returnsInstance() {
        let plugin = BrightcovePlayerPlugin.pluggablePlayerInit(playableItems: [], configurationJSON: [:])
        XCTAssertNotNil(plugin)
    }
    
    // MARK: - PlayerType
    
    func test_staticPlayerType_returnsUndefined() {
        XCTAssertEqual(BrightcovePlayerPlugin.pluggablePlayerType(), .undefined)
    }
}


