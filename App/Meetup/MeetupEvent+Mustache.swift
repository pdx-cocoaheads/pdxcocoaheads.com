import Mustache

extension MeetupEvent : MustacheBoxable {
    
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
