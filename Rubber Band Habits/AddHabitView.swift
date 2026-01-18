
import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) var modelContext
    //@Environment(\.presentationMode) var presentationMode
    //I have learned that PresentationMode is deprecated
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var nameLimit = 12
    @State private var hDescription: String = ""
    @State private var good: Bool = true
    @State private var goalFrequency: Double = 0
    @State private var validHabit: Bool = false
    
    let timescales = ["Daily", "Weekly", "Monthly"]
    
    //Between these two, options in timescale frequency are translated into
    //frequency type
    @State private var timescale: String = "Daily"
    @State private var frequencyType: [String: String] = [
        "Daily": "day",
        "Weekly": "week",
        "Monthly": "month"
    ]

    var body: some View /*I just hate the brackets being level */{
        NavigationStack {
            //Pretty basic form to fill out habit information
            Form {
                Section {//The get-set allows the limit to be programmed
                    TextField("Name", text: Binding(
                        get: { self.name },
                        set: { newValue in
                            if ((newValue.count <= nameLimit) && (newValue.count > 0)) {
                                self.name = newValue
                                validHabit = true
                            }//I realized you can make nameless habits
                        }
                    ))
                    TextField("Description", text: $hDescription)
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
                    //Strange syntax is little trick for plurality switching
                    Text("^[\(Int(goalFrequency)) time](inflect: true) per \(frequencyType[timescale]!)")
                    Slider(value: $goalFrequency, in: 0...50, step: 1)
                    //Sliders don't like integers
                }
                
                
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if(validHabit) {
                            let habit = Habit(name: name, good: good, hDescription: hDescription, timescale: timescale, goalFrequency: Int(goalFrequency))
                            modelContext.insert(habit)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive, action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            //An artifact of navigationStack
        }

    }
}

#Preview {
    AddHabitView()
}
