import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .study

    enum Tab {
        case study, words, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            StudyView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Study", systemImage: "house.fill")
                }
                .tag(Tab.study)

            WordListView()
                .tabItem {
                    Label("Words", systemImage: "list.bullet")
                }
                .tag(Tab.words)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(AppTheme.primary)
    }
}
