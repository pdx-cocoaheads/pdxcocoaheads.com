import Mustache
import Vapor

/** 
 * Holder for values returned from Meetup API that we want to display on 
 * "Upcoming Events" page.
 */
struct MeetupEvent {
    /** Event title */
    let name: String
    /** Event date in milliseconds since epoch */
    let time: Int
    /** Event location timezone's milliseconds from UTC */
    let utcOffset: Int
    /** Number of people who have said they're attending */
    let rsvpCount: Int
    /** URL (as string) of event's page on Meetup.com */
    let link: String
}

extension MeetupEvent: MustacheBoxable {
    
    /** Allow lookup of fields by name in Mustache rendering context */
    func mustacheBox(forKey key: String) -> MustacheBox {
        
        switch key {
        case "name": return Box(boxable: self.name)
        case "time": return Box(boxable: self.time)
        case "utcOffset": return Box(boxable: self.utcOffset)
        case "rsvpCount": return Box(boxable: self.rsvpCount)
        case "link": return Box(boxable: self.link)
        default: return Box()
        }
    }
    
    var mustacheBox: MustacheBox {
        return MustacheBox(value: self,
                           keyedSubscript: self.mustacheBox(forKey:))
    }
}
    
/** Errors during unpacking of Meetup API's returned JSON data. */
enum MeetupEventUnpackError : ErrorProtocol {
    case NotAnArray(JSON)
}

/** 
 * Transform an array of JSON-coded events returned from Meetup into 
 * `MeetupEvent` instances, skipping any that are malformed.
 *
 * - Parameter fromJSON: Vapor.JSON wrapping an array of objects
 *
 * - Throws: `MeetupEventUnpackError.NotAnArray` if the `fromJSON` parameter
 * cannot be unwrapped into a Swift array
 *
 * - Returns: An array of `MeetupEvent`s in the order the event descriptions
 * were presented in the JSON
 */
func unpackMeetupEvents(fromJSON json: JSON) throws -> [MeetupEvent] {
    
    guard let events: [JSON] = json.array else {
        throw MeetupEventUnpackError.NotAnArray(json)
    }
    
    return events.flatMap { eventJSON in
        
        // Lenient unpacking: just skip an individual item if it's not usable
        guard let event = eventJSON.object,
              let name = event["name"].string,
              let time = event["time"].int,
              let utcOffset = event["utc_offset"].int,
              let rsvpCount = event["yes_rsvp_count"].int,
              let link = event["link"].string
        else {
                
                return nil
        }
        
        return MeetupEvent(name: name, time: time, utcOffset: utcOffset,
                           rsvpCount: rsvpCount, link: link)
    }
}
