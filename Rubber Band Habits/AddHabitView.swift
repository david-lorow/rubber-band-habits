
import SwiftUI

struct AddHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var nameLimit = 12
    @State private var description: String = ""
    @State private var good: Bool = true
    @State private var goalFrequency: Double = 0
    
    @ObservedObject var habit: Habitual
    
    let timescales = ["Daily", "Weekly", "Monthly"]
    
    @State private var timescale: String = "Daily"
    @State private var frequencyType: [String: String] = [
        "Daily": "day",
        "Weekly": "week",
        "Monthly": "month"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: Binding(
                        get: { self.name },
                        set: { newValue in
                            if newValue.count <= nameLimit {
                                self.name = newValue
                            }
                        }
                    ))
                    TextField("Description", text: $description)
                    Text("Is this a good habit?")
                    Picker("Is this a good habit?", selection: $good) {
                        Text("Yes").tag(true)
                        Text("No").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Ideal Frequency") {
                    Text("What is the goal or limit?")
                    Picker("Timescale", selection: $timescale) {
                        ForEach(timescales, id: \.self) { timescale in
                            Text(timescale)
                        }
                    }
                    Text("^[\(Int(goalFrequency)) time](inflect: true) per \(frequencyType[timescale]!)")
                    Slider(value: $goalFrequency, in: 0...50, step: 1)
                    
                }
                
                
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let item = Habit(name: name, description: description, good: good, goalFrequency: Int(goalFrequency), timescale: timescale)
                        habit.items.append(item)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive, action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AddHabitView(habit: Habitual())
}
