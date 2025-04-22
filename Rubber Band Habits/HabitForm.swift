
import Foundation

struct Habit: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var good: Bool
    var goalFrequency: Int
    var dailyCount: Int = 0
    var weeklyCount: Int = 0
    var monthlyCount: Int = 0
    var totalCount: Int = 0
    var completionDates: [Date] = []
    var timescale: String
    var lastDateChecked: Date = Date()
    var undoUsedToday: Bool = false
    
    mutating func incrementCompletion() {
        let now = Date()
        completionDates.append(now)
        updateCounts(for: now)
    }
    
    mutating func decrementCompletion() {
        let now = Date()
        if let index = completionDates.lastIndex(where: { Calendar.current.isDateInToday($0) }) {
            completionDates.remove(at: index)
            updateCounts(for: now)
        }
    }
    
    private mutating func updateCounts(for date: Date) {
        dailyCount = completionDates.filter { Calendar.current.isDateInToday($0) }.count
        weeklyCount = completionDates.filter { Calendar.current.isDate($0, equalTo: date, toGranularity: .weekOfYear) }.count
        monthlyCount = completionDates.filter { Calendar.current.isDate($0, equalTo: date, toGranularity: .month) }.count
        totalCount = completionDates.count
    }
    
    mutating func startDailyCheck() {
        let currentDate = Date()
        if !Calendar.current.isDate(lastDateChecked, inSameDayAs: currentDate) {
            lastDateChecked = currentDate
            undoUsedToday = false
        }
    }
}

class Habitual: ObservableObject {
    @Published var items = [Habit]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
        init() {
            if let saveItems = UserDefaults.standard.data(forKey: "Items") {
                if let decodedItems = try? JSONDecoder().decode([Habit].self, from: saveItems) {
                    items = decodedItems
                    return
                }
            }
            
            items = []
        }
    
}

