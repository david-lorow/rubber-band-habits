import Foundation
import SwiftData

/*
 Originally I was saving data in user defaults but for the sake of having an easier time with data updates,
 I have upgraded the data storage system to utilize SwiftData.
 */

@Model
class Habit {
    var id = UUID()
    var name: String
    var good: Bool
    var hDescription: String //Thanks @Model
    var timescale: String
    var goalFrequency: Int
    var lastUndoDate: Date? //Maybe there is, maybe there isn't
    
    @Relationship(deleteRule: .cascade, inverse: \Completion.habit)
    var completions: [Completion] = []
    
    init(name: String, good: Bool, hDescription: String, timescale: String, goalFrequency: Int) {
        self.name = name
        self.good = good
        self.hDescription = hDescription
        self.timescale = timescale
        self.goalFrequency = goalFrequency
    }
    //Undo completion----------------------------------------------------------------------------------------------------------------
    
    //Check undo
    func undoUsed(today: Date) -> Bool {
        guard let undoDate = lastUndoDate else /* if the date doesn't exist */ { return false }
        return Calendar.current.isDate(undoDate, inSameDayAs: today)
    }
    //Undo is pressed: if(Habit.undoUsedToday(Date()) -> "Undo invalid" else Habit.lastUndoDate = Date()
    
    //Do undo
    func doUndo(today: Date = Date(), context: ModelContext) -> Bool {
        if(undoUsed(today: today)) {
            return false //Unsuccessfully undone (aka {not (successfully done)} via DeMorgan's Law)
        }
        guard let lastCompletionIdx = completions.lastIndex(where: {Calendar.current.isDate($0.date, inSameDayAs: today)})
        else {
            print("Error in finding latest completion date for habit: \(name)")//It's called we do a little bit of error handling
            return false
        }
        //Undo process
        let completion = completions.remove(at: lastCompletionIdx)
        context.delete(completion)
        lastUndoDate = today
        return true //Successfully undone
    }
}

@Model
class Completion {
    var id = UUID()
    var date: Date
    var habit: Habit
    
    init(date: Date, habit: Habit) {
        self.date = date
        self.habit = habit
    }
    
}
