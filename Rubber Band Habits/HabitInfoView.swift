
import SwiftUI

struct DailyWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var plural: Bool = false
    var habit: Habit
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(habit.dailyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") today")
            }
        }
        .onAppear() {
            isPlural()
        }
    }
    func isPlural() {
        if habit.dailyCount != 1 {
            plural.toggle()
        }
    }
    static func saveText(for habit: Habit) -> String {
            return "\(habit.dailyCount) Time\(habit.dailyCount == 1 ? "" : "s") today"
        }
}

struct WeeklyWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var plural: Bool = false
    var habit: Habit
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(habit.weeklyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") this week")
            }
        }
        .onAppear() {
            isPlural()
        }
    }
    func isPlural() {
        if habit.weeklyCount != 1 {
            plural.toggle()
        }
    }
    static func saveText(for habit: Habit) -> String {
            return "\(habit.weeklyCount) Time\(habit.weeklyCount == 1 ? "" : "s") this week"
        }
}

struct MonthlyWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var plural: Bool = false
    var habit: Habit
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(habit.monthlyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") this month")
            }
        }
        .onAppear() {
            isPlural()
        }
    }
    func isPlural() {
        if habit.monthlyCount != 1 {
            plural.toggle()
        }
    }
    static func saveText(for habit: Habit) -> String {
            return "\(habit.monthlyCount) Time\(habit.monthlyCount == 1 ? "" : "s") this month"
        }
}

struct ProgressWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var doingGood: Bool = false
    var habit: Habit
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            Text("You\(doingGood ? " did it!" : "'re on your way")")
                .font(.system(size: 30)).bold()
                .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
        }
        .onAppear {
            getProgress()
        }
    }
    func getProgress() {
        let count: Int
            switch habit.timescale {
            case "Daily":
                count = habit.dailyCount
            case "Weekly":
                count = habit.weeklyCount
            case "Monthly":
                count = habit.monthlyCount
            default:
                count = 0
            }
            
            if habit.goalFrequency == 0 {
                doingGood = (count == 0)
                return
            }
        
        switch habit.timescale {
        case "Daily":
            doingGood = habit.good ? habit.dailyCount >= habit.goalFrequency : habit.dailyCount <= habit.goalFrequency
        case "Weekly":
            doingGood = habit.good ? habit.weeklyCount >= habit.goalFrequency : habit.weeklyCount <= habit.goalFrequency
        case "Monthly":
            doingGood = habit.good ? habit.monthlyCount >= habit.goalFrequency : habit.monthlyCount <= habit.goalFrequency
        default:
            doingGood = false
        }
    }
}


struct HabitInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var shareInfo: String = ""
    var habit: Habit
       
       var body: some View {
           NavigationStack {
               ScrollView(.vertical, showsIndicators: false) {
                   VStack(spacing: 16) {
                       DailyWidget
                           .init(habit: habit)
                       WeeklyWidget
                           .init(habit: habit)
                       MonthlyWidget
                           .init(habit: habit)
                       ProgressWidget
                           .init(habit: habit)
                   }
                   .padding(.top)
               }
               .navigationTitle("\(habit.name) Insights")
               .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       ShareLink(item: shareInfo)
                   }
               }
               .onAppear() {
                   share()
               }
           }
       }
    func share() {
        shareInfo = "I've done \(habit.name)\n" + DailyWidget.saveText(for: habit) + "!\n" + WeeklyWidget.saveText(for: habit) + "!\n" +  MonthlyWidget.saveText(for: habit) + "!"
    }
}

#Preview {
    let sampleHabit = Habit(
        name: "Sample",
        description: "A sample habit for previewing.",
        good: true,
        goalFrequency: 5,
        timescale: "Monthly"
    )
    HabitInfoView(habit: sampleHabit)
}
