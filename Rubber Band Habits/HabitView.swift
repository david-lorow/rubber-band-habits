
import SwiftUI

//This is the beast, the true core of the app, where completions are done
struct HabitView: View {
    //@Binding var habit: Habit
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    var habit: Habit
    
    //Compute different counts for every frequency type
    var dailyCount: Int {
        habit.completions.filter {
            Calendar.current.isDateInToday($0.date)
        }.count
    }
    var weeklyCount: Int {
        habit.completions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
    }
    var monthlyCount: Int {
        habit.completions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
    }
    
    //Basic date information summarized for later
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
                //Month name
                ZStack {
                    Rectangle()
                        .fill(colorScheme == .light ? Color(white: 0.95) : Color(white: 0.15))
                        .frame(width: 350, height: 70)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    Text(monthName(for: theMonth))
                        .font(.system(size: 40)).bold()
                }
                //Month view wrapped
                ZStack {
                    Rectangle()
                        .fill(colorScheme == .light ? Color(white: 0.95) : Color(white: 0.15))
                        .frame(width: 350, height: 300)
                        .cornerRadius(10)
                    
                    MonthView(month: theMonth, year: theYear, completions: habit.completions, isGoodHabit: habit.good)
                }
                //Habit info
                HStack(alignment: .firstTextBaseline) {
                    Text("\(String(format: "%.0f", towardsGoal))%")
                        .font(.system(size: 50)).bold()
                        .foregroundColor(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
                    Text("\(percentMessage) \(habit.goalFrequency) Time\(habit.goalFrequency == 1 ? "" : "s") \(habit.timescale)")
                        .font(.system(size: 18))
                }
                ZStack() {
                    Button(action: {
                        @State var completion = Completion(date: Date(), habit: habit)
                        habit.completions.append(completion)
                        percentCalculate()
                        //Bounce animation
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 5)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAnimating = false
                        }
                    }, label: {//Button label is +1
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
                    //Here is the undo button
                    //Rather than using geometry, I just did some
                    //insane container placements
                    HStack{
                        Spacer()
                        Spacer()
                        Spacer()
                        if(!habit.undoUsed(today: Date()) && habit.completions.contains(where: { Calendar.current.isDateInToday($0.date) })
                        ) {
                            Button(action: {
                                showUndoAlert = true
                            }, label: {
                                ZStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            })//Alert if user presses undo
                            .alert(isPresented: $showUndoAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You can only undo once a day."),
                                    primaryButton: .destructive(Text("Undo")) {
                                        if(habit.doUndo(context: modelContext)) {
                                            percentCalculate()
                                        }
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
         }
    }
    //Dictionary for ease with month identification
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
    //Function for month identification
    func monthName(for month: Int) -> String {
        monthDictionary[month] ?? "Invalid month"
    }
    
    //This is just a way to track progress but it quickly sprialed into semantics
    func percentCalculate() {
        guard habit.goalFrequency > 0 else {
            switch habit.timescale {
            case "Daily":
                towardsGoal = dailyCount > 0 ? -100 : 100
            case "Weekly":
                towardsGoal = weeklyCount > 0 ? -100 : 100
            case "Monthly":
                towardsGoal = monthlyCount > 0 ? -100 : 100
            default:
                towardsGoal = 0
            }
            percentMessage = "At"
            return
        }
        
        let progress: Double
        switch habit.timescale {
        case "Daily":
            progress = Double(dailyCount) / Double(habit.goalFrequency)
        case "Weekly":
            progress = Double(weeklyCount) / Double(habit.goalFrequency)
        case "Monthly":
            progress = Double(monthlyCount) / Double(habit.goalFrequency)
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
    let sampleHabit = Habit(
        name: "Sample",
        good: true,
        hDescription: "A sample habit for previewing.",
        timescale: "Daily",
        goalFrequency: 1,
    )
    let sampleCompletion = Completion(date: Date(), habit: sampleHabit)
    
    sampleHabit.completions.append(sampleCompletion)
    
    return HabitView(habit: sampleHabit)
}

