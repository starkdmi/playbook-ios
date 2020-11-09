import SwiftUI
import Combine

/// A view that displays scenarios manged by given `Playbook` instance with
/// catalog-style appearance.
public struct PlaybookCatalog: View {
    private var underlyingView: PlaybookCatalogInternal
    
    //@State var colorScheme: ColorScheme = .light

    /// Creates a new view that displays scenarios managed by given `Playbook` instance.
    ///
    /// - Parameters:
    ///   - name: A name of `Playbook` to be displayed on the user interface.
    ///   - playbook: A `Playbook` instance that manages scenarios to be displayed.
    public init(
        name: String = "PLAYBOOK",
        playbook: Playbook = .default,
        icons: [String: Image] = [String: Image](),
        //colorScheme: ColorScheme = .light,
        infoTapped: @escaping () -> () = {}
    ) {
        underlyingView = PlaybookCatalogInternal(
            name: name,
            playbook: playbook,
            store: CatalogStore(playbook: playbook, isSearchTreeHidden: false), // , isSearchTreeHidden: true
            icons: icons,
            infoTapped: infoTapped
        )
        //self.colorScheme = colorScheme
     }

    /// Declares the content and behavior of this view.
    public var body: some View {
        underlyingView
    }
}

internal struct PlaybookCatalogInternal: View {
    var name: String
    var playbook: Playbook

    @ObservedObject
    var store: CatalogStore
    
    var icons: [String: Image]
    var infoTapped: () -> ()

    @Environment(\.colorScheme) var colorScheme
    
    @WeakReference
    var contentUIView: UIView?

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    
    let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as! UIApplication
    //@State var appState = application.applicationState
    
    //@State var previousColorScheme = ColorScheme.light
    @State var previousScenario: SearchedData?
    
    var body: some View {
        platformContent()
            .environmentObject(store)
            .onAppear(perform: {
                //#if targetEnvironment(macCatalyst)
                selectFirstScenario()
                //#endif
                
                //self.store.isSearchTreeHidden = false
                                
                //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            .sheet(item: $store.shareItem) { item in
                ImageSharingView(item: item) { self.store.shareItem = nil }
                    .edgesIgnoringSafeArea(.all)
            }
            
            .onReceive(Just(self.$store.selectedScenario.wrappedValue?.id), perform: { id in
                if id == nil {
                    if previousScenario != nil {
                        if store.selectedScenario == nil, let store = previousScenario, let scenario = previousScenario?.scenario  {
                                               
                            self.store.start()
                            self.store.selectedScenario = SearchedData(
                                scenario: scenario,
                                kind: store.kind,
                                shouldHighlight: false
                            )
                        } else {
                            selectFirstScenario()
                        }
                    }
                    
                    //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                previousScenario = self.$store.selectedScenario.wrappedValue
            })
            
            /*.onReceive(Just(colorScheme), perform: { scheme in
                if colorScheme != previousColorScheme {
                    selectFirstScenario()
                    print("reload2", colorScheme, previousColorScheme)
                    //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    previousColorScheme = colorScheme
                }
            })*/
        
            /*.onReceive(Just(application.applicationState), perform: { state in
                #if !targetEnvironment(macCatalyst)
                //if state != .background {
                    selectFirstScenario() // Reload when app returns from background
                //}
                #endif
            })*/
 
 
            /*.onReceive(Just(self.$store.selectedScenario), perform: { _ in
                print("Receive ", self.store.playbook.stores) // selectFirstScenario
            })
            .onReceive(Just(colorScheme), perform: { scheme in
                print("Scheme", scheme)
            })*/
    }
}

private extension PlaybookCatalogInternal {
    var bottomBarHeight: CGFloat { 44 }
        
    func platformContent() -> some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return AnyView(
                CatalogSplitStyle(
                    name: name,
                    searchTree: ScenarioSearchTree(icons: icons),
                    content: scenarioContent
                )
            )

        default:
            return AnyView(
                CatalogDrawerStyle(
                    name: name,
                    searchTree: ScenarioSearchTree(icons: icons),
                    content: scenarioContent
                )
            )
        }
    }

    func displayView() -> some View {
        if let data = store.selectedScenario {
            return AnyView(
                ScenarioContentView(
                    kind: data.kind,
                    scenario: data.scenario,
                    additionalSafeAreaInsets: .only(bottom: bottomBarHeight),
                    contentUIView: _contentUIView
                )
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    application.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
        }
        else {
            return AnyView(emptyContent())
        }
    }

    func emptyContent() -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer.zero
            }

            Spacer.zero

            Image(symbol: .book)
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundColor(Color(.label))

            Spacer.fixed(length: 44)

            Text("There are no templates")
                .foregroundColor(Color(.label))
                .font(.system(size: 24, weight: .bold))
                .lineLimit(nil)

            Spacer.zero
        }
        .padding(.horizontal, 24)
    }

    func scenarioContent(firstBarItem: CatalogBarItem) -> some View {
        ZStack {
            Color(.scenarioBackground)
                .edgesIgnoringSafeArea(.all)

            displayView()

            VStack(spacing: 0) {
                Spacer.zero

                Divider()
                    .edgesIgnoringSafeArea(.all)

                bottomBar(firstBarItem: firstBarItem)
            }
        }
    }

    func bottomBar(firstBarItem: CatalogBarItem) -> some View {
        HStack(spacing: 16) {
            firstBarItem

            if store.selectedScenario != nil {
                CatalogBarItem(
                    image: Image(symbol: .squareAndArrowUp),
                    insets: .only(bottom: 4),
                    action: share
                )
            }
            
            HStack(spacing: 0) {
                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    //#if !targetEnvironment(macCatalyst)
                    Text(name)
                        .bold()
                        .lineLimit(1)
                        .font(.system(size: 24))
                        //.padding(.bottom, 2)
                    /*#else
                    Text(name)
                        .bold()
                        .lineLimit(1)
                        .font(.system(size: 24))
                        .foregroundColor(Color(.label))
                    #endif*/
                    
                    Button(action: infoTapped) {
                        Image(symbol: .info)
                            .imageScale(.large)
                            //.foregroundColor(Color(.label))
                            .frame(width: 32, height: 32)
                            //.foregroundColor(self.colorScheme == .light ? Color(red: 24/255, green: 36/255, blue: 45/255) : Color.white)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: bottomBarHeight)
        .background(
            Blur(style: .systemMaterial)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all),
            alignment: .topLeading
        )
        .foregroundColor(colorScheme == .light ? Color(.label) : Color(red: 237/255, green: 70/255, blue: 70/255))
    }

    func share() {
        guard let uiView = contentUIView else { return }

        let image = UIGraphicsImageRenderer(bounds: uiView.bounds).image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
        
        store.shareItem = ImageSharingView.Item(image: image)
    }

    func selectFirstScenario() {
        guard store.selectedScenario == nil, let store = playbook.stores.first, let scenario = store.scenarios.first else {
            return
        }

        self.store.start()
        self.store.selectedScenario = SearchedData(
            scenario: scenario,
            kind: store.kind,
            shouldHighlight: false
        )
    }
}
