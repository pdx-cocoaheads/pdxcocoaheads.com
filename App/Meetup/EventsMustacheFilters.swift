import Foundation
import Mustache

/** Namespace/vendor for FilterFunctions needed for the Events page. */
struct EventsMustacheFilters {
    
    /**
     * All filters used in the upcoming-events.mustache template, boxed and
     * ready to be added to the Mustache rendering context.
     */
    static var asContext: [String : MustacheBox] {
        return ["formattedDate" : Box(filter: formattedDateFilter),
                "pluralizedRSVP" : Box(filter: pluralizedRSVPFilter)]
    }

    /** Fallback for missing timezone info. */
    // Note: this may be overly defensive; currently a `MeetupEvent` cannot
    // be created without a timezone.
    private static let PDXStandardUTCOffset = -25200000
    
    /**
     * Format the event's millisecond timestamp into a nice description,
     * using the event's timezone information.
     */
    static var formattedDateFilter: FilterFunction = Filter {
        
        (time: Int?, info: RenderingInfo) in

            guard let milliseconds = time else {
                return Rendering("Unknown date")
            }

            // Context's MustacheBox wraps a MeetupEvent
            let offsetBox = info.context.mustacheBox(forKey: "utcOffset")
            let utcOffset = (offsetBox.value as? Int) ?? PDXStandardUTCOffset
        
            let date = Date(timeIntervalSince1970: Double(milliseconds/1000))
            let formatter = DateFormatter()
            // UTC offset is also milliseconds
            formatter.timeZone = TimeZone(forSecondsFromGMT: utcOffset/1000)
            formatter.dateStyle = .full
            formatter.timeStyle = .short
    
            return Rendering(formatter.string(from: date))
    }

    /** Change the inner text of the RSVP description based on the count. */
    // This snazzy idea cribbed straight out of the Mustache docs.
    // See Mustache/Rendering/CoreFunctions.swift#L310
    static var pluralizedRSVPFilter: FilterFunction = Filter {
        
        (count: Int?, info: RenderingInfo) in
        
            var peoples: String = "people are"
            if count == 1 {
                peoples = "person is"
            }
            return Rendering(peoples)
    }
}
