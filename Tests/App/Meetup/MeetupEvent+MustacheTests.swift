import XCTest
@testable import App
import Mustache

/** Ensure `mustacheBox(forKey:)` returns expected values. */
class EventMustacheBoxTests: XCTestCase {
    
    let event = MeetupEvent(name: "Discussion",
                            time: 1234,
                       utcOffset: 5678,
                       rsvpCount: 9,
                            link: "http://example.com")
    
    func testMustacheBoxName() {
        
        let key = "name"
        let expected = "Discussion"
        
        let boxValue = event.mustacheBox(forKey: key).value
        
        XCTAssertTrue((boxValue as? String) == expected)
    }
    
    func testMustacheBoxTime() {
        
        let key = "time"
        let expected = 1234
        
        let boxValue = event.mustacheBox(forKey: key).value
        
        XCTAssertTrue((boxValue as? Int) == expected)
    }
    
    func testMustacheBoxUtcOffset() {
        
        let key = "utcOffset"
        let expected = 5678
        
        let boxValue = event.mustacheBox(forKey: key).value
        
        XCTAssertTrue((boxValue as? Int) == expected)
    }
    
    func testMustacheBoxRsvpCount() {
        
        let key = "rsvpCount"
        let expected = 9
    
        let boxValue = event.mustacheBox(forKey: key).value
        
        XCTAssertTrue((boxValue as? Int) == expected)
    }
    
    func testMustacheBoxLink() {
        
        let key = "link"
        let expected = "http://example.com"
        
        let boxValue = event.mustacheBox(forKey: key).value
        
        XCTAssertTrue((boxValue as? String) == expected)
    }
}
