import XCTest
@testable import App
import Vapor
import Mustache

// Equality for `MeetupEvent` so that arrays of them can be tested
func ==(lhs: MeetupEvent, rhs: MeetupEvent) -> Bool {
    return (lhs.name == rhs.name && 
            lhs.time == rhs.time && 
            lhs.utcOffset == rhs.utcOffset &&
            lhs.rsvpCount == rhs.rsvpCount && 
            lhs.link == rhs.link)
}

extension MeetupEvent: Equatable {}

/** Test unpacking of JSON into arrays of `MeetupEvent`s */
class UnpackEventTests: XCTestCase {
    
    let sampleObject: [String : JSONRepresentable] = 
                                       ["name" : "Discussion",
                                        "time" : 1234,
                                        "utc_offset" : 5678,
                                        "yes_rsvp_count" : 9,
                                        "link" : "http://example.com"]
    let event = MeetupEvent(name: "Discussion", time: 1234, utcOffset: 5678,
                            rsvpCount: 9, link: "http://example.com")

    // Non-array JSON -> no results
    func testNoUnpackOfNonarray() {
        
        var object = self.sampleObject
        object.removeAll()
        let json = JSON(object)
        
        XCTAssertThrowsError(try unpackMeetupEvents(fromJSON: json))
    }
    
    // Empty input -> empty output
    func testEmptyArrayUnpacksEmpty() {
        
        let json = JSON([])
        
        let unpacked = try! unpackMeetupEvents(fromJSON: json)
        
        XCTAssertTrue(unpacked.isEmpty)
    }
    
    // Single malformed input -> empty output
    func testMissingDataUnpacksEmpty() {
        
        var object = self.sampleObject
        object.removeValue(forKey: "name")
        let json = JSON([JSON(object)])
        
        let unpacked = try! unpackMeetupEvents(fromJSON: json)
        
        XCTAssertTrue(unpacked.isEmpty)
    }
    
    // Two good entries, one bad -> skip the bad
    func testSomeGoodData() {
        
        var badObject = self.sampleObject
        badObject.removeValue(forKey: "name")
        let json = JSON([JSON(self.sampleObject), 
                         JSON(badObject), 
                         JSON(self.sampleObject)])
        let expected = [self.event, self.event]
        
        let unpacked = try! unpackMeetupEvents(fromJSON: json)
        
        XCTAssertEqual(unpacked, expected)        
    }
    
    // Good data successfully unpacks
    func testGoodData() {
        
        let json = JSON([JSON(self.sampleObject), JSON(self.sampleObject)])
        let expected = [self.event, self.event]
        
        let unpacked = try! unpackMeetupEvents(fromJSON: json)
        
        XCTAssertEqual(unpacked, expected)
    }
}

/** Ensure `mustacheBox(forKey:)` returns expected values. */
class EventMustacheBoxTests: XCTestCase {
    
    let event = MeetupEvent(name: "Discussion", time: 1234, utcOffset: 5678,
                            rsvpCount: 9, link: "http://example.com")
    
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

