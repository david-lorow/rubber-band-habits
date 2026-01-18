//Shoutout to the Tahoe 26.2 update for improving my app's UI
import SwiftUI
import SwiftData

//How each habit will present itself in the list
struct HabitRowView: View {
    @State var habit: Habit
    
    var body: some View {
        NavigationLink {
            HabitView(habit: habit)
                .navigationTitle(habit.name)
        } label: {
            VStack(alignment: .leading) {
                Text(habit.name)
                    .foregroundStyle(habit.good ? .green : .red)
                    .font(.system(size: 20))
                    .bold()
                //Adaptable view depending on whether a description is present
                if !habit.hDescription.isEmpty {
                    ShowDescription(habit: habit)
                }
            }
        }
    }
    //A basic text item wrapped in a struct for easier mutability
    struct ShowDescription: View {
        var habit: Habit
        var body: some View {
            Text(habit.hDescription)
                .font(.system(size: 15))
        }
    }
}




struct ContentView: View {
    //@ObservedObject private var habit = Habitual()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Habit.name) var habits: [Habit]
    @State private var showAddHabit = false
    @State private var showDeleteAlert = false
    @State private var itemToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            //Basic list with deletion alert, "Alarm app" type UI
            List {
                Section {
                    ForEach(habits) { habit in
                        HabitRowView(habit: habit)
                    }
                    .onDelete { indexSet in
                        itemToDelete = indexSet
                        showDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Rubber Band Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddHabit.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .sheet(isPresented: $showAddHabit) {
                        AddHabitView()
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Habit"),
                    message: Text("All data will be lost"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = itemToDelete {
                            deleteItems(at: indexSet)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .tint(colorScheme == .light ? Color.duskyViolet : Color.lightViolet)
    }
    //Translate offsets to objects and delete
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            modelContext.delete(habit)
        }
        //habit.items.remove(atOffsets: offsets)
    }
}






#Preview {
    //Simple in preview only container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, Completion.self, configurations: config)
    let context = container.mainContext
    
    let exampleHabitOne = Habit(name: "Exercise", good: true, hDescription: "", timescale: "Weekly", goalFrequency: 5)
    
    let exampleHabitTwo = Habit(name: "Smoking", good: false, hDescription: "RAZ", timescale: "Daily", goalFrequency: 1)
    
    context.insert(exampleHabitOne)
    context.insert(exampleHabitTwo)
    
    return ContentView()
        .modelContainer(container)
}

