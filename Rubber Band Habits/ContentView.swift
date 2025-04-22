
import SwiftUI



struct HabitRowView: View {
    @Binding var habit: Habit
    
    
    var body: some View {
        NavigationLink {
            HabitView(habit: $habit)
                .navigationTitle(habit.name)
        } label: {
            VStack(alignment: .leading) {
                Text(habit.name)
                    .foregroundStyle(habit.good ? .green : .red)
                    .font(.system(size: 20))
                    .bold()
                if !habit.description.isEmpty {
                    ShowDescription(habit: habit)
                }
            }
        }
    }

    struct ShowDescription: View {
        var habit: Habit
        var body: some View {
            Text(habit.description)
                .font(.system(size: 15))
        }
    }
}




struct ContentView: View {
    @ObservedObject private var habit = Habitual()
    @State private var showAddHabit = false
    @State private var showDeleteAlert = false
    @State private var itemToDelete: IndexSet?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habit.items.indices, id: \.self) { index in
                        HabitRowView(habit: $habit.items[index])
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
                        AddHabitView(habit: habit)
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

    func deleteItems(at offsets: IndexSet) {
        habit.items.remove(atOffsets: offsets)
    }
     
}






#Preview {
    ContentView()
}

