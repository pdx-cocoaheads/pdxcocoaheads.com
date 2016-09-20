import Vapor
import Leaf

let drop = Droplet()

drop.get("/") { request in
    return try drop.view.make("index.leaf")
}

drop.get("/topics") { request in
    return try drop.view.make("topics.leaf")
}

drop.run()
