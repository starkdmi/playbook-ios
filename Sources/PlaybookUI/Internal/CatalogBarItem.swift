import SwiftUI

internal struct CatalogBarItem: View {
    var image: Image
    var insets: EdgeInsets
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            image
                .padding(8)
                .imageScale(.large)
                //.foregroundColor(Color(.label))
                .foregroundColor(colorScheme == .light ? Color(.label) : Color(red: 237/255, green: 70/255, blue: 70/255))
                .padding(insets)
        }
    }
}
