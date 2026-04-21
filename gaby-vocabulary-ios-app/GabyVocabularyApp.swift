import SwiftUI
import SwiftData

@main
struct GabyVocabularyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Word.self, ReviewCard.self])
    }
}
