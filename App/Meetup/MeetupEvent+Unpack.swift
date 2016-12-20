import enum Vapor.JSON

extension MeetupEvent {
    
    /** Errors during unpacking of Meetup API's JSON data. */
    enum UnpackError : ErrorProtocol {
        case notAnArray
    }

    /**
     * Transform an array of JSON-coded events returned from Meetup into
     * `MeetupEvent` instances, skipping any that are malformed.
     *
     * - Parameter fromJSON: Vapor.JSON wrapping an array of objects
     *
     * - Throws: `MeetupEvent.UnpackError.NotAnArray` if the `fromJSON`
     * parameter cannot be unwrapped into a Swift array
     *
     * - Returns: An array of `MeetupEvent`s in the order the event
     * descriptions were presented in the JSON
     */
    static func unpack(fromJSON json: JSON) throws -> [MeetupEvent] {
    
        guard let events: [JSON] = json.array else {
            throw UnpackError.notAnArray
        }
    
        return events.flatMap {
            // Just skip an individual item if it's not usable
            MeetupEvent(fromJSON: $0)
        }
    }
}
