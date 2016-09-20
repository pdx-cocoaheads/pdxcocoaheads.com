import class Vapor.Config
import class Engine.HTTPClient
import class Engine.TCPClientStream

/** Access to the Meetup.com API */
struct MeetupAPI {
    
    enum Error : ErrorProtocol {
        
        /** Necessary config file info was not found */
        case missingConfigInfo
        /** Could not connect or response from API was absent */
        case noResponse
        /** Response from API could not be parsed into JSON */
        case responseInvalidJSON
        /** Response was not the expected array of events */
        case responseNotAnArray
    }
    
    // `Vapor.Droplet.client` uses the class object and calls static
    // methods, so we will do the same.
    private let client = HTTPClient<TCPClientStream>.self
    
    private let configuration: Configuration
    
    init(config: Config) {
        self.configuration = Configuration(config: config)
    }
    
    /**
     * Pulls down future events for the group from Meetup.com's API and
     * converts them to `MeetupEvent`s for eventual display.
     *
     * -Throws: `MeetupAPI.Error.missingConfigInfo` if the necessary URL info
     * is somehow missing from the config file.
     * - Throws: `MeetupAPI.Error.noResponse` if the connection fails or
     * produces an empty response.
     * - Throws: `MeetupAPI.Error.responseInvalidJSON` if the response cannot
     * be parsed into JSON
     * - Throws: `MeetupAPI.Error.responseNotAnArray` if the response parses
     * into something other than an array.
     *
     * - Returns: An array of `MeetupEvent` representing the event data, in
     * the same order Meetup.com provided them.
     */
    func getUpcomingEvents() throws -> [MeetupEvent] {
        
        guard let requestURL = self.configuration.eventsEndpoint else {
            throw Error.missingConfigInfo
        }
    
        guard let response = try? self.client.get(requestURL) else {
            throw Error.noResponse
        }
        
        guard let parsed = response.json else {
            throw Error.responseInvalidJSON
        }
        
        guard let events = try? MeetupEvent.unpack(fromJSON: parsed) else {
            throw Error.responseNotAnArray
        }
        
        return events
    }
}

/**
 * Vend values, via the given `Vapor.Config`, from the meetup.json file.
 */
private struct Configuration {
    
    /**
     * The underlying `Vapor.Config` object.
     *
     * This is recieved from the active `Droplet`, rather than created from
     * scratch, because the `Droplet` knows the correct working directory.
     */
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    /** Keys for the meetup.json file, including the filename itself. */
    private struct Keys {
        
        static let file = "meetup"
        static let host = "host"
        static let groupName = "group-name"
        static let eventsPath = "events-path"
    }
    
    // Scheme is not really configurable, as -- according to Vapor -- using
    // HTTPS on Linux requires an additional component
    var scheme: String {
        return "http"
    }

    /** API hostname */
    var host: String? {
        return self.config[Keys.file, Keys.host]?.string
    }

    /** PDX CocoaHeads group's URL segment; what Meetup calls `:urlname` */
    var groupName: String? {
        return self.config[Keys.file, Keys.groupName]?.string
    }

    /** API path for fetching all events of a given group */
    var eventsPath: String? {
        return self.config[Keys.file, Keys.eventsPath]?.string
    }
    
    /**
     * Base URL for any PDX CocoaHeads group endpoint; includes scheme,
     * host, and group name. `nil` if any of that info is unavailable.
     */
    var groupURL: String? {
        
        guard
            let host = self.host,
            let groupName = self.groupName
        else {
            return nil
        }
        
        return self.scheme.finished(with: "://") +
               host.finished(with: "/") +
               groupName
    }
    
    /** API endpoint for all CocoaHeads-PDX events */
    var eventsEndpoint: String? {
        
        guard
            let groupURL = self.groupURL,
            let eventsPath = self.eventsPath
        else {
            return nil
        }
        
        return groupURL.finished(with: "/") + eventsPath
    }
}
