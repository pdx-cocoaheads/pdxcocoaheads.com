import enum Vapor.JSON

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
    
    init?(fromJSON json: JSON) {
        
        guard
            let event = json.object,
            let name = event[Keys.name.rawValue].string,
            let time = event[Keys.time.rawValue].int,
            let utcOffset = event[Keys.utcOffset.rawValue].int,
            let rsvpCount = event[Keys.rsvpCount.rawValue].int,
            let link = event[Keys.link.rawValue].string
        else {
            return nil
        }
        
        self.name = name
        self.time = time
        self.utcOffset = utcOffset
        self.rsvpCount = rsvpCount
        self.link = link
    }
    
    /** Keys in the Meetup API's JSON "event" object */
    private enum Keys : String {
        
        case name, time, link
        case utcOffset = "utc_offset"
        case rsvpCount = "yes_rsvp_count"
    }
}

