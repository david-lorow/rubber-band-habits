
import SwiftUI

extension Color {
    static let DarkGray = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let OffWhite = Color(red: 0.92, green: 0.92, blue: 0.92)
    static let duskyViolet = Color(red: 131 / 255, green: 99 / 255, blue: 158 / 255)
    static let lightViolet = Color(red: 186/255, green: 149/255, blue: 213/255)
    
}

#Preview {
    struct viewTesting: View {
        var body: some View {
            VStack(alignment: .center) {
                Text("Dusky Violet")
                    .font(.title)
                    .foregroundStyle(Color.duskyViolet)
                Text("Light Violet")
                    .font(.title)
                    .foregroundStyle(Color.lightViolet)
            }
        }
    }
    return viewTesting()
}

