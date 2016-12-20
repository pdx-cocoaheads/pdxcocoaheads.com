@testable import App

extension MeetupEvent {
    
    init(name: String,
         time: Int,
    utcOffset: Int,
    rsvpCount: Int,
         link: String) {
    
         self.name = name
         self.time = time
         self.utcOffset = utcOffset
         self.rsvpCount = rsvpCount
         self.link = link
    }
}
