
import SwiftUI

struct DayCell: View {
    var dayText: String
    var isCurrentMonth: Bool
    var isCompleted: Bool
    var isGoodHabit: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isCurrentMonth ? Color.white : Color.clear)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
            
            if isCompleted {
                Circle()
                    .fill(isGoodHabit ? Color.green : Color.red)
                    .frame(width: 25, height: 25)
                    .padding(4)
            }

            Text(dayText)
                .font(.system(size: 14))
                .foregroundColor(isCurrentMonth ? .black : .clear)
        }
    }
}

struct MonthView: View {
    let month: Int
    let year: Int
    let completionDates: [Date]
    let isGoodHabit: Bool
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    
    var daysInMonth: Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return calendar.range(of: .day, in: .month, for: date)!.count
    }
    
    var startDayOffset: Int {
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let weekday = calendar.component(.weekday, from: date) - 1 // 0 = Sunday
        return weekday
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(0..<42, id: \.self) { index in
                let day = index - startDayOffset + 1
                let isCurrentMonth = day > 0 && day <= daysInMonth
                
                // Determine if the date is in completionDates
                let dateComponents = DateComponents(year: year, month: month, day: day)
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)
                let isCompleted = date != nil && completionDates.contains(where: { calendar.isDate($0, inSameDayAs: date!) })
                
                DayCell(
                    dayText: isCurrentMonth ? "\(day)" : "",
                    isCurrentMonth: isCurrentMonth,
                    isCompleted: isCompleted,
                    isGoodHabit: isGoodHabit
                )
            }
        }
        .padding(1)
        .background(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
        .frame(width: 350, height: 300)
        .cornerRadius(10)
    }
}

#Preview {
    let habit = Habit(
        name: "Exercise",
        description: "Daily exercise routine",
        good: true,
        goalFrequency: 5,
        completionDates: [
            Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 3))!,
            Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 7))!,
            Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 15))!
        ],
        timescale: ""
    )
    
    MonthView(month: 10, year: 2024, completionDates: habit.completionDates, isGoodHabit: habit.good)
}

