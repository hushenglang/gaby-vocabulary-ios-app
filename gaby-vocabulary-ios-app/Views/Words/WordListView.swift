import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WordListViewModel()
    @State private var showAddWord = false
    @State private var showImportWords = false
    @State private var wordToDelete: Word?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if viewModel.words.isEmpty {
                    emptyState
                } else {
                    wordList
                }
            }
            .navigationTitle("Words")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addMenu
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search words...")
            .sheet(isPresented: $showAddWord) {
                AddWordView {
                    viewModel.fetchWords(context: modelContext)
                }
            }
            .sheet(isPresented: $showImportWords) {
                ImportWordsView {
                    viewModel.fetchWords(context: modelContext)
                }
            }
            .alert("Delete Word?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { wordToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let word = wordToDelete {
                        viewModel.deleteWord(word, context: modelContext)
                        wordToDelete = nil
                    }
                }
            } message: {
                if let word = wordToDelete {
                    Text("Are you sure you want to delete \"\(word.english)\"? This cannot be undone.")
                }
            }
        }
        .onAppear {
            viewModel.fetchWords(context: modelContext)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacing16) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textTertiary)

            Text("No words yet")
                .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Tap + to add your first word")
                .font(.system(size: AppTheme.fontBody))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var wordList: some View {
        List {
            Section {
                ForEach(viewModel.filteredWords, id: \.persistentModelID) { word in
                    WordRowView(word: word)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                wordToDelete = word
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            } header: {
                Text("\(viewModel.wordCount) words")
                    .font(.system(size: AppTheme.fontSmall, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var addMenu: some View {
        Menu {
            Button {
                showAddWord = true
            } label: {
                Label("Add Word", systemImage: "pencil")
            }

            Button {
                showImportWords = true
            } label: {
                Label("Import Words", systemImage: "doc.text")
            }
        } label: {
            Image(systemName: "plus")
        }
    }
}
