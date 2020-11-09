import SwiftUI
import UIKit

internal struct SearchBar: View {
    @Binding
    var text: String?
    var height: CGFloat

    var body: some View {
        SearchBarWrapper(text: $text, placeholder: "Search") { searchBar in
            let backgroundImage = UIColor.tertiarySystemFill.circleImage(length: self.height)
            searchBar.setSearchFieldBackgroundImage(backgroundImage, for: .normal)
        }
        .animation(nil)
        .accentColor(Color(.primaryBlue))
        .frame(height: height)
        .padding(.top, 16)
        .padding(.horizontal, 8)
    }
}

private struct SearchBarWrapper: UIViewRepresentable {
    @Binding
    var text: String?

    var placeholder: String?
    var updateUIView: ((UISearchBar) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.backgroundImage = UIImage()
        searchBar.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -8, vertical: 0), for: .clear)
        searchBar.tintColor = UIColor(red: 239/255, green: 70/255, blue: 70/255, alpha: 1.0)
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
        uiView.delegate = context.coordinator
        updateUIView?(uiView)
    }
}

private extension SearchBarWrapper {
    final class Coordinator: NSObject, UISearchBarDelegate {
        let base: SearchBarWrapper

        init(_ base: SearchBarWrapper) {
            self.base = base
        }
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            //print("reload0")
            //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // @starkdmi
            return true
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            base.text = searchText
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}
