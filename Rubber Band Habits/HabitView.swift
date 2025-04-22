
import SwiftUI

struct HabitView: View {
    @Binding var habit: Habit
    @Environment(\.colorScheme) var colorScheme
    let theMonth: Int = Calendar.current.component(.month, from: Date())
    let theYear: Int = Calendar.current.component(.year, from: Date())
    @State private var towardsGoal: Double = 0
    @State private var percentMessage: String = ""
    @State private var showUndoAlert: Bool = false
    @State private var isAnimating = false
    

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(colorScheme == .light ? Color(white: 0.95) : Color(white: 0.15))
                        .frame(width: 350, height: 70)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    Text(monthName(for: theMonth))
                        .font(.system(size: 40)).bold()
                }
                ZStack {
                    Rectangle()
                        .fill(colorScheme == .light ? Color(white: 0.95) : Color(white: 0.15))
                        .frame(width: 350, height: 300)
                        .cornerRadius(10)
                    MonthView(month: theMonth, year: theYear, completionDates: habit.completionDates, isGoodHabit: habit.good)
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("\(String(format: "%.0f", towardsGoal))%")
                        .font(.system(size: 50)).bold()
                        .foregroundColor(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                    Text("\(percentMessage) \(habit.goalFrequency) Time\(habit.goalFrequency == 1 ? "" : "s") \(habit.timescale)")
                        .font(.system(size: 18))
                }
                ZStack() {
                    Button(action: {
                        habit.incrementCompletion()
                        percentCalculate()
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) {
                            isAnimating = true
                                }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAnimating = false
                            }
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(habit.good ? Color.green : Color.red)
                                .frame(width: 90, height: 90)
                                .scaleEffect(isAnimating ? 1.2 : 1.0)
                            Text("+1")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    })
                    HStack{
                        Spacer()
                        Spacer()
                        Spacer()
                        if !habit.undoUsedToday && habit.completionDates.contains(where: { Calendar.current.isDateInToday($0) }) {
                            Button(action: {
                                showUndoAlert = true  
                            }, label: {
                                ZStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            })
                            .alert(isPresented: $showUndoAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You can only undo once a day."),
                                    primaryButton: .destructive(Text("Undo")) {
                                        habit.decrementCompletion()
                                        percentCalculate()
                                        habit.undoUsedToday = true
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        Spacer()
                    }
                }
                Spacer()
            }
            .toolbar {
                NavigationLink(destination: HabitInfoView(habit: habit)) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onAppear {
            percentCalculate()
            habit.startDailyCheck()
        }
    }

    let monthDictionary: [Int: String] = [
        1: "January",
        2: "February",
        3: "March",
        4: "April",
        5: "May",
        6: "June",
        7: "July",
        8: "August",
        9: "September",
        10: "October",
        11: "November",
        12: "December"
    ]

    func monthName(for month: Int) -> String {
        monthDictionary[month] ?? "Invalid month"
    }

    func percentCalculate() {
        guard habit.goalFrequency > 0 else {
            switch habit.timescale {
            case "Daily":
                towardsGoal = habit.dailyCount > 0 ? -100 : 100
            case "Weekly":
                towardsGoal = habit.weeklyCount > 0 ? -100 : 100
            case "Monthly":
                towardsGoal = habit.monthlyCount > 0 ? -100 : 100
            default:
                towardsGoal = 0
            }
            percentMessage = "At"
            return
        }

        let progress: Double
        switch habit.timescale {
        case "Daily":
            progress = Double(habit.dailyCount) / Double(habit.goalFrequency)
        case "Weekly":
            progress = Double(habit.weeklyCount) / Double(habit.goalFrequency)
        case "Monthly":
            progress = Double(habit.monthlyCount) / Double(habit.goalFrequency)
        default:
            towardsGoal = 0
            return
        }

        if habit.good {
            towardsGoal = progress * 100
            percentMessage = towardsGoal >= 100 ? "At" : "Towards"
        } else {
            towardsGoal = (1 - progress) * 100
            
            if towardsGoal >= 0 {
                towardsGoal = 100
                percentMessage = "At or below"
            } else {
                towardsGoal = (progress - 1) * 100
                percentMessage = "Over"
            }
        }
    }
}

#Preview {
    @Previewable @State var sampleHabit = Habit(
        name: "Sample Habit",
        description: "A sample habit for previewing.",
        good: true,
        goalFrequency: 0,
        timescale: "Monthly"
    )

    return HabitView(habit: $sampleHabit)
}

