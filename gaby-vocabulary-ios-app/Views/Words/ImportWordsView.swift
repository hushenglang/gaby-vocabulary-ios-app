import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportWordsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var markdownText: String = ""
    @State private var parsedWords: [ParsedWord] = []
    @State private var showResult = false
    @State private var importResult: ImportResult?
    @State private var showFilePicker = false

    var onImported: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                    filePickerButton
                    pasteSection
                    if !parsedWords.isEmpty {
                        previewSection
                        importButton
                    }
                }
                .padding(AppTheme.spacing16)
            }
            .background(AppTheme.background)
            .navigationTitle("Import Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .alert("Import Complete", isPresented: $showResult) {
                Button("OK") {
                    onImported()
                    dismiss()
                }
            } message: {
                if let result = importResult {
                    if result.skipped > 0 {
                        Text("Imported \(result.imported) of \(result.total) words. (\(result.skipped) duplicates skipped)")
                    } else {
                        Text("Imported \(result.imported) of \(result.total) words.")
                    }
                }
            }
        }
    }

    private var filePickerButton: some View {
        Button {
            showFilePicker = true
        } label: {
            HStack {
                Image(systemName: "folder")
                    .font(.system(size: AppTheme.fontBody))
                Text("Choose File (.md)")
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacing16)
            .background(AppTheme.primaryLight)
            .foregroundStyle(AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
        }
    }

    private var pasteSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Or paste markdown below:")
                .font(.system(size: AppTheme.fontSmall, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            TextEditor(text: $markdownText)
                .font(.system(size: AppTheme.fontSmall, design: .monospaced))
                .frame(minHeight: 160)
                .padding(AppTheme.spacing8)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radius12)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .onChange(of: markdownText) { _, _ in
                    parseContent()
                }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Preview (\(parsedWords.count) words parsed)")
                .font(.system(size: AppTheme.fontSmall, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 0) {
                ForEach(Array(parsedWords.prefix(20).enumerated()), id: \.offset) { _, word in
                    HStack {
                        Text(word.english)
                            .font(.system(size: AppTheme.fontSmall, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("·")
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(word.chinese)
                            .font(.system(size: AppTheme.fontSmall))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.vertical, AppTheme.spacing8)
                    .padding(.horizontal, AppTheme.spacing16)
                }
            }
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))

            if parsedWords.count > 20 {
                Text("... and \(parsedWords.count - 20) more")
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
    }

    private var importButton: some View {
        Button {
            performImport()
        } label: {
            Text("Import \(parsedWords.count) Words")
                .font(.system(size: AppTheme.fontBody, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing16)
                .background(AppTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
        }
    }

    private func parseContent() {
        parsedWords = MarkdownParser.parse(markdownText)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }

        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        if let content = try? String(contentsOf: url, encoding: .utf8) {
            markdownText = content
            parseContent()
        }
    }

    private func performImport() {
        let vm = WordListViewModel()
        let result = vm.importWords(from: markdownText, context: modelContext)
        importResult = result
        showResult = true
    }
}
