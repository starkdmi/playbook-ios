import SwiftUI

internal struct Counter: View, Equatable {
    var numerator: Int
    var denominator: Int
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            Spacer.zero

            Text("\(numerator) / \(denominator)")
                .font(Font.subheadline.monospacedDigit())
                //.foregroundColor(Color(.label))
                .bold()
                .foregroundColor(colorScheme == .light ? Color(red: 237/255, green: 70/255, blue: 70/255) : Color(.label))
            
        }
        .padding(.top, 8)
        .padding(.horizontal, 24)
        .animation(nil, value: self)
    }
    
    static func == (lhs: Counter, rhs: Counter) -> Bool {
        lhs.numerator == rhs.numerator &&  lhs.denominator == rhs.denominator ? true : false
    }
}
