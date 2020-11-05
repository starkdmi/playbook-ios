import SwiftUI

internal struct ScenarioDisplaySheet: View {
    var data: SearchedData
    var onClose: () -> Void

    @EnvironmentObject
    private var store: GalleryStore

    @WeakReference
    private var contentUIView: UIView?

    var colorScheme: ColorScheme // @starkdmi

    init(
        data: SearchedData,
        colorScheme: ColorScheme = .light, // @starkdmi
        onClose: @escaping () -> Void
    ) {
        self.data = data
        self.colorScheme = colorScheme // @starkdmi
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            ScenarioContentView(
                kind: data.kind,
                scenario: data.scenario,
                additionalSafeAreaInsets: .only(top: topBarHeight),
                contentUIView: _contentUIView
            )
            .edgesIgnoringSafeArea(.all)
            .background(
                Color(.scenarioBackground)
                    .edgesIgnoringSafeArea(.all)
            )

            VStack(spacing: 0) {
                topBar()

                Divider()
                    .edgesIgnoringSafeArea(.all)

                Spacer.zero
            }
        }
        .sheet(item: $store.shareItem) { item in
            ImageSharingView(item: item) { self.store.shareItem = nil }
                .edgesIgnoringSafeArea(.all)
        }
        .background(
            Color(.scenarioBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

private extension ScenarioDisplaySheet {
    var topBarHeight: CGFloat { 44 }

    func topBar() -> some View {
        HStack(spacing: 0) {
            shareButton()

            Spacer(minLength: 24)

            Text(data.scenario.name.rawValue)
                .bold()
                .lineLimit(1)
                //.foregroundColor(colorScheme == .light ? Color(red: 24/255, green: 36/255, blue: 45/255) : .white) // @starkdmi

            Spacer(minLength: 24)

            closeButton()
        }
        .padding(.horizontal, 24)
        .frame(height: topBarHeight)
        /*.background( // @starkdmi
            colorScheme == .light ? AnyView(Blur(style: .systemMaterial).edgesIgnoringSafeArea(.all)) : AnyView(Color(red: 24/255, green: 36/255, blue: 45/255)),
            alignment: .topLeading
        )*/
        .background(
            Blur(style: .systemMaterial) // .dark for dark mode +-
                .edgesIgnoringSafeArea(.all),
            alignment: .topLeading
        )/*
        .background( // @starkdmi
            colorScheme == .light ? .white : Color(red: 24/255, green: 36/255, blue: 45/255) // Color(red: 41/255, green: 55/255, blue: 63/255)
        )*/
    }

    func shareButton() -> some View {
        Button(action: share) {
            Image(symbol: .squareAndArrowUp)
                .imageScale(.large)
                .font(.headline)
                .foregroundColor(Color(.label))
                //.foregroundColor(colorScheme == .light ? Color(red: 24/255, green: 36/255, blue: 45/255) : .white) // @starkdmi
                .frame(width: 30, height: 30)
        }
    }

    func closeButton() -> some View {
        Button(action: onClose) {
            ZStack {
                Color.gray.opacity(0.2)
                //(colorScheme == .light ? Color.gray.opacity(0.2) : Color(red: 41/255, green: 55/255, blue: 63/255)) // @starkdmi
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)

                Image(symbol: .multiply)
                    .imageScale(.large)
                    .font(Font.subheadline.bold())
                    .foregroundColor(.gray)
                    //.foregroundColor(colorScheme == .light ?  Color(red: 24/255, green: 36/255, blue: 45/255) : .white) // @starkdmi
            }
        }
    }

    func share() {
        guard let uiView = contentUIView else { return }

        let image = UIGraphicsImageRenderer(bounds: uiView.bounds).image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }

        store.shareItem = ImageSharingView.Item(image: image)
    }
}
