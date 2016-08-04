import Vapor
import VaporMustache
import Engine
import SocksCore
import Mustache

/**
    Adding a provider allows it to boot
    and initialize itself as a dependency.

    Includes are relative to the Views (`Resources/Views`)
    directory by default.
*/
let mustache = VaporMustache.Provider(withIncludes: [
    "header": "Includes/header.mustache"
])

/**
    Xcode defaults to a working directory in
    a temporary build folder. 
    
    In order for Vapor to access Resources and
    Configuration files, the working directory
    must be the root directory of your project.
 
    This can also be achieved by passing
    --workDir=$(SRCROOT) in the Xcode arguments
    or setting the root directory manually in:
    Edit Scheme > Options > [ ] Use custom working directory
*/
let workDir: String?
#if Xcode
    let parent = #file.characters.split(separator: "/").map(String.init).dropLast().joined(separator: "/")
    workDir = "/\(parent)/.."
#else
    workDir = nil
#endif

/**
    Droplets are service containers that make accessing
    all of Vapor's features easy. Just call
    `drop.serve()` to serve your application
    or `drop.client()` to create a client for
    request data from other servers.
*/
let drop = Droplet(workDir: workDir, providers: [mustache])

/**
    Vapor configuration files are located
    in the root directory of the project
    under `/Config`.

    `.json` files in subfolders of Config
    override other JSON files based on the
    current server environment.

    Read the docs to learn more

let _ = drop.config["app", "key"].string ?? ""
*/

/**
    This first route will return the welcome.html
    view to any request to the root directory of the website.

    Views referenced with `app.view` are by default assumed
    to live in <workDir>/Resources/Views/ 

    You can override the working directory by passing
    --workDir to the application upon execution.
*/
drop.get("/") { request in
    return try drop.view("index.html")
}

drop.get("/events") { _ in
    
    let template = "upcoming-events.mustache"
    
    // Show default "no events" page if config data is missing for some reason
    guard let eventsHost = drop.config["meetup", "hostname"].string,
          let queryPath = drop.config["meetup", "events-queries", "all"].string
    else {
        
        drop.log.warning("No config info for events query")
        return try drop.view(template, context: [:])
    }
    
    let requestURL = "https://\(eventsHost)/\(queryPath)"
    let response = try? drop.client.get(requestURL)
 
    // Special action for failed response?

    // Test unpacking of response, show default "no events" on failure
    guard let parsed = response?.json,
          let unpacked = try? unpackMeetupEvents(fromJSON: parsed)
    else {

        drop.log.warning("Event list response from Meetup was " +
                         "empty or nonexistent")
        return try drop.view(template, context: [:])
    }
 
    // Set up context with successfully unpacked data
    //!!!: Typing `context`'s values as `MustacheBox`, or allowing that to be 
    //!!!: inferred leads to a fatal error due to a failed unsafeBitCast 
    //!!!: in _dictionaryBridgeToObjectiveC *after returning* the built view.
    var context: [String : Any] = ["events" : Mustache.Box(boxable: unpacked)]
    EventsMustacheFilters.asContext.forEach { (key, filter) in
         context[key] = filter
    }
    
    return try drop.view(template, context: context)
}

/**
    Return JSON requests easy by wrapping
    any JSON data type (String, Int, Dict, etc)
    in JSON() and returning it.

    Types can be made convertible to JSON by 
    conforming to JsonRepresentable. The User
    model included in this example demonstrates this.

    By conforming to JsonRepresentable, you can pass
    the data structure into any JSON data as if it
    were a native JSON data type.

drop.get("json") { request in
    return JSON([
        "number": 123,
        "string": "test",
        "array": JSON([
            0, 1, 2, 3
        ]),
        "dict": JSON([
            "name": "Vapor",
            "lang": "Swift"
        ])
    ])
}
*/

/**
    This route shows how to access request
    data. POST to this route with either JSON
    or Form URL-Encoded data with a structure
    like:

    {
        "users" [
            {
                "name": "Test"
            }
        ]
    }

    You can also access different types of
    request.data manually:

    - Query: request.data.query
    - JSON: request.data.json
    - Form URL-Encoded: request.data.formEncoded
    - MultiPart: request.data.multipart

drop.get("data", Int.self) { request, int in
    return JSON([
        "int": int,
        "name": request.data["name"].string ?? "no name"
    ])
}
*/

/**
    Here's an example of using type-safe routing to ensure 
    only requests to "posts/<some-integer>" will be handled.

    String is the most general and will match any request
    to "posts/<some-string>". To make your data structure
    work with type-safe routing, make it StringInitializable.

    The User model included in this example is StringInitializable.

drop.get("posts", Int.self) { request, postId in
    return "Requesting post with ID \(postId)"
}
*/

/**
    This will set up the appropriate GET, PUT, and POST
    routes for basic CRUD operations. Check out the
    UserController in App/Controllers to see more.

    Controllers are also type-safe, with their types being
    defined by which StringInitializable class they choose
    to receive as parameters to their functions.

let users = UserController(droplet: drop)
drop.resource("users", users)
*/

/**
    VaporMustache hooks into Vapor's view class to
    allow rendering of Mustache templates. You can
    even reference included files setup through the provider.

drop.get("mustache") { request in
    return try drop.view("template.mustache", context: [
        "greeting": "Hello, world!"
    ])
}
*/

/**
    Vapor automatically handles setting
    and retreiving sessions. Simply add data to
    the session variable and–if the user has cookies
    enabled–the data will persist with each request.

drop.get("session") { request in
    let json = JSON([
        "session.data": "\(request.session)",
        "request.cookies": "\(request.cookies)",
        "instructions": "Refresh to see cookie and session get set."
    ])
    var response = try Response(status: .ok, json: json)

    request.session?["name"] = "Vapor"
    response.cookies["test"] = "123"

    return response
}
*/

/**
    Add Localization to your app by creating
    a `Localization` folder in the root of your
    project.

    /Localization
       |- en.json
       |- es.json
       |_ default.json

    The first parameter to `app.localization` is
    the language code.

drop.get("localization", String.self) { request, lang in
    return JSON([
        "title": drop.localization[lang, "welcome", "title"],
        "body": drop.localization[lang, "welcome", "body"]
    ])
}
*/

/**
    Middleware is a great place to filter 
    and modifying incoming requests and outgoing responses. 

    Check out the middleware in App/Middleware.

    You can also add middleware to a single route by
    calling the routes inside of `app.middleware(MiddlewareType) { 
        app.get() { ... }
    }`

drop.globalMiddleware.append(SampleMiddleware())
*/

let port = drop.config["app", "port"].int ?? 80

// Print what link to visit for default port
drop.serve()
