import SwiftUI
import SwiftData

struct StudyView: View {
    @Binding var selectedTab: ContentView.Tab
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = StudyViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if viewModel.isEmpty {
                    EmptyStudyView {
                        selectedTab = .words
                    }
                } else if viewModel.isComplete {
                    CompletedStudyView(reviewedCount: viewModel.sessionTotal)
                } else if let card = viewModel.currentCard, let word = card.word {
                    activeStudyContent(word: word)
                } else {
                    CompletedStudyView(reviewedCount: 0)
                }
            }
            .navigationTitle("Study")
        }
        .onAppear {
            viewModel.loadQueue(context: modelContext)
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .study {
                viewModel.loadQueue(context: modelContext)
            }
        }
    }

    @ViewBuilder
    private func activeStudyContent(word: Word) -> some View {
        VStack(spacing: AppTheme.spacing24) {
            ProgressRingView(
                completed: viewModel.sessionCompleted,
                total: viewModel.sessionTotal
            )
            .padding(.top, AppTheme.spacing16)

            FlashcardView(
                english: word.english,
                chinese: word.chinese,
                isRevealed: viewModel.isRevealed,
                onTap: { viewModel.revealCard() }
            )
            .padding(.horizontal, AppTheme.spacing16)

            if viewModel.isRevealed {
                ratingButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isRevealed)
    }

    private var ratingButtons: some View {
        HStack(spacing: AppTheme.spacing8) {
            ratingButton("Forgot", color: AppTheme.danger, rating: .forgot)
            ratingButton("Hard", color: AppTheme.warning, rating: .hard)
            ratingButton("Good", color: AppTheme.primary, rating: .good)
            ratingButton("Easy", color: AppTheme.success, rating: .easy)
        }
        .padding(.horizontal, AppTheme.spacing16)
    }

    private func ratingButton(_ title: String, color: Color, rating: RecallRating) -> some View {
        Button {
            viewModel.rateCard(rating, context: modelContext)
        } label: {
            VStack(spacing: AppTheme.spacing4) {
                Text(title)
                    .font(.system(size: AppTheme.fontSmall, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacing16)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
        }
    }
}
