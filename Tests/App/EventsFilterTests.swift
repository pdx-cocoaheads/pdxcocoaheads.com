import XCTest
@testable import App
import Mustache

/**
 * These are not really  unit tests: Testing the `FilterFunction`s in isolation 
 * means a fair bit of setup of Mustache internals; these tests use a 
 * `Mustache.Template` and do integrated testing of expected rendering.
 */

/** 
 * Test EventsMustacheFilter.formattedDateFilter rendering of millisecond
 * value to pretty date string. 
 */
class DateFilterTests: XCTestCase {
    
    var template: Template!
    let templateContent = "{{ formattedDate(time) }}"
    let filter = EventsMustacheFilters.formattedDateFilter
    let defaultOffset = -25200000
    
    override func setUp() {
        
        self.template = try! Template(string: templateContent)
        self.template.registerInBaseContext(key: "formattedDate", 
                                       Box(filter: self.filter))
    }
    
    // Time missing -> "Unknown date"
    func testNoTime() {
        
        let time = Box()
        let expected = "Unknown date"

        self.template.registerInBaseContext(key: "time", time)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)        
    }
    
    // Offset missing -> Date in PST
    func testNoOffset() {
        
        // Time is milliseconds from epoch in UTC
        let time = Box(boxable: 1470879000000)
        let expected = "Wednesday, August 10, 2016 at 6:30 PM"
        
        self.template.registerInBaseContext(key: "time", time)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // Time 0 -> Epoch date
    func testTimeZero() {
        
        let time = Box(boxable: 0)
        let offset = Box(boxable: self.defaultOffset)
        let expected = "Wednesday, December 31, 1969 at 5:00 PM"
        
        self.template.registerInBaseContext(key: "time", time)
        self.template.registerInBaseContext(key: "utcOffset", offset)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // All expected data -> Date in PST
    func testGoodData() {
        
        // Time is milliseconds from epoch in UTC
        let time = Box(boxable: 1470879000000)
        let offset = Box(boxable: self.defaultOffset)
        let expected = "Wednesday, August 10, 2016 at 6:30 PM"
        
        self.template.registerInBaseContext(key: "time", time)
        self.template.registerInBaseContext(key: "utcOffset", offset)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
}

/** 
 * Test EventsMustacheFilter.pluralizedRSVPFilter rendering of 
 * "people are"/"person is" based on integer count.
 */
class PluralizeFilterTests: XCTestCase {
    
    var template: Template!
    let templateContent = "{{ pluralizedRSVP(count) }}"
    let filter = EventsMustacheFilters.pluralizedRSVPFilter
    
    override func setUp() {
        
        self.template = try! Template(string: templateContent)
        self.template.registerInBaseContext(key: "pluralizedRSVP", 
                                            Box(filter: self.filter))
    }
    
    // No count -> plural version
    func testNoCount() {
        
        let count = Box()
        let expected = "people are"
        
        self.template.registerInBaseContext(key: "count", count)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // Zero -> plural
    func testZero() {
        
        let count = Box(boxable: 0)
        let expected = "people are"
        
        self.template.registerInBaseContext(key: "count", count)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // One -> singular
    func testOne() {
        
        let count = Box(boxable: 1)
        let expected = "person is"
        
        self.template.registerInBaseContext(key: "count", count)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // Negative -> plural
    func testNegativeCount() {
        
        let count = Box(boxable: -1)
        let expected = "people are"
        
        self.template.registerInBaseContext(key: "count", count)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
    
    // Lots and lots -> plural
    func testIntMax() {
        
        let count = Box(boxable: Int.max)
        let expected = "people are"
        
        self.template.registerInBaseContext(key: "count", count)
        let rendering = try? self.template.render()
        
        XCTAssertEqual(rendering?.string, expected)
    }
}
