
import SwiftUI

//Different widgets for every frequency type of the habit
//They're each pretty similar, just a basic widget to hold info and adapt text
//as needed. I've simplified them since the original to be dependent on info
//from the main view rather than calculating too many things on their own.

struct DailyWidget: View {
    var colorScheme: ColorScheme
    var dailyCount: Int
    var plural: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(dailyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") today")
            }
        }
    }
}

struct WeeklyWidget: View {
    var colorScheme: ColorScheme
    var weeklyCount: Int
    var plural: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(weeklyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") this week")
            }
        }
    }
}

struct MonthlyWidget: View {
    var colorScheme: ColorScheme
    var monthlyCount: Int
    var plural: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? Color.OffWhite : Color.DarkGray)
                .frame(width: 300, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack(alignment: .firstTextBaseline) {
                Text("\(monthlyCount)")
                    .font(.system(size: 50)).bold()
                    .foregroundStyle(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                Text("Time\(plural ? "s" : "") this month")
            }
        }
    }
}

struct ProgressWidget: View {
    var colorScheme: ColorScheme
    var habit: Habit
    var dailyCount: Int
    var weeklyCount: Int
    var monthlyCount: Int

    //This used to be a function with .onAppear and stuff
    //But a computed variable is just so nice
    var doingGood: Bool {
        //First the count that matters for measuring progress is based on
        //the timescale the user had selected
        //For example only weekly count matters if the goal was based on
        //x times per week
        let count: Int
        switch habit.timescale {
            case "Daily":
                count = dailyCount
            case "Weekly":
                count = weeklyCount
            case "Monthly":
                count = monthlyCount
            default:
                count = 0
        }
        
        //If the goal was to do it 0 times, anything not 0 means the goal is not
        //being reached
        if habit.goalFrequency == 0 {
            return (count == 0)
        }
    
        //Then if the goal frequency is non-zero, there's the issue of
        //"goodness"
        //If habit is good, the count should be >= the goal, if it's no good,
        //the count should be <= the goal
        switch habit.timescale {
            case "Daily":
                return habit.good ? dailyCount >= habit.goalFrequency :    dailyCount <= habit.goalFrequency
            case "Weekly":
                return habit.good ? weeklyCount >= habit.goalFrequency :   weeklyCount <= habit.goalFrequency
            case "Monthly":
                return habit.good ? monthlyCount >= habit.goalFrequency :  monthlyCount <= habit.goalFrequency
            default:
                return false
        }
    }
    
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
    }
}


struct HabitInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var shareInfo: String = ""
    var habit: Habit
    
    //Compute different counts for every frequency type and their plurality
    var dailyCount: Int {
        habit.completions.filter {
            Calendar.current.isDateInToday($0.date)
        }.count
    }
    var dailyPlural: Bool {
        dailyCount == 1 ? false : true
    }
    var weeklyCount: Int {
        habit.completions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }
    var weeklyPlural: Bool {
        weeklyCount == 1 ? false : true
    }
    var monthlyCount: Int {
        habit.completions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
    }
    var monthlyPlural: Bool {
        monthlyCount == 1 ? false : true
    }
       
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    DailyWidget.init(colorScheme: colorScheme,dailyCount: dailyCount, plural: dailyPlural)
                    WeeklyWidget.init(colorScheme: colorScheme,weeklyCount: weeklyCount, plural:weeklyPlural)
                    MonthlyWidget.init(colorScheme: colorScheme,monthlyCount: monthlyCount, plural:monthlyPlural)
                    ProgressWidget.init(colorScheme: colorScheme,habit: habit, dailyCount: dailyCount,weeklyCount: weeklyCount, monthlyCount:monthlyCount)
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
    //A string just summarizing these results can be sent via user's apps
    func share() {
        let dailyLine = "\(dailyCount) time\(dailyCount == 1 ? "" : "s") today!\n"
        let weeklyLine = "\(weeklyCount) time\(weeklyCount == 1 ? "" : "s") this week!\n"
        let monthlyLine = "\(monthlyCount) time\(monthlyCount == 1 ? "" : "s") this month!"
        shareInfo = "I've done \(habit.name)\n" + dailyLine + weeklyLine + monthlyLine
    }
}

#Preview {
    let sampleHabit = Habit(
        name: "Sample",
        good: true,
        hDescription: "A sample habit for previewing.",
        timescale: "Daily",
        goalFrequency: 1,
    )
    let sampleCompletion = Completion(date: Date(), habit: sampleHabit)
    
    sampleHabit.completions.append(sampleCompletion)
    
    return HabitInfoView(habit: sampleHabit)
}

