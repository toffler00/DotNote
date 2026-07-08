//
//  DotNoteEntryEditors.swift
//  Orbit
//
//  Typed SwiftUI editors for the redesign milestone 2.
//  View layer only; persistence stays behind DotNoteAppModel callbacks.
//

import PencilKit
import SwiftUI
import UIKit

struct DotNoteEntryEditorView: View {
    var mode: DotNoteEntryEditorMode
    var settings: DotNoteSettings?
    var isSaving: Bool
    var onSave: (DotNoteEntry) async -> Void
    var onCreate: (DotNoteEntry) async -> Void
    var onDelete: (DotNoteEntry.ID) async -> Void
    var onCancel: () -> Void

    var body: some View {
        switch mode.entry.kind {
        case .diary:
            DiaryEditorView(
                mode: mode,
                settings: settings,
                isSaving: isSaving,
                onSave: onSave,
                onCreate: onCreate,
                onDelete: onDelete,
                onCancel: onCancel
            )
        case .drawing:
            DrawingEditorView(
                mode: mode,
                settings: settings,
                isSaving: isSaving,
                onSave: onSave,
                onCreate: onCreate,
                onDelete: onDelete,
                onCancel: onCancel
            )
        case .memo:
            MemoOverlayView(
                mode: mode,
                settings: settings,
                isSaving: isSaving,
                onSave: onSave,
                onCreate: onCreate,
                onDelete: onDelete,
                onCancel: onCancel
            )
        }
    }
}

private struct DiaryEditorView: View {
    var mode: DotNoteEntryEditorMode
    var settings: DotNoteSettings?
    var isSaving: Bool
    var onSave: (DotNoteEntry) async -> Void
    var onCreate: (DotNoteEntry) async -> Void
    var onDelete: (DotNoteEntry.ID) async -> Void
    var onCancel: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var draft: DotNoteEntryDraft

    init(
        mode: DotNoteEntryEditorMode,
        settings: DotNoteSettings?,
        isSaving: Bool,
        onSave: @escaping (DotNoteEntry) async -> Void,
        onCreate: @escaping (DotNoteEntry) async -> Void,
        onDelete: @escaping (DotNoteEntry.ID) async -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.settings = settings
        self.isSaving = isSaving
        self.onSave = onSave
        self.onCreate = onCreate
        self.onDelete = onDelete
        self.onCancel = onCancel
        _draft = State(initialValue: DotNoteEntryDraft(entry: mode.entry))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                    EditorDateWeatherHeader(draft: $draft, kind: .diary)

                    VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                        TextField("제목", text: $draft.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                            .accessibilityIdentifier("entry-title-field")

                        TextEditor(text: $draft.body)
                            .font(DotNoteType.body(settings).font(size: CGFloat(settings?.bodyFontSize ?? 16)))
                            .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 190)
                            .accessibilityIdentifier("entry-body-editor")

                        AlignmentToolbar(selection: $draft.textAlignment, tint: DotNoteEntryKind.diary.dot)
                    }
                    .padding(DotNoteTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.xl, style: .continuous)
                            .fill(DotNoteEntryKind.diary.surface(scheme))
                    )

                    if !mode.isCreating {
                        DeleteButton(isSaving: isSaving) {
                            await onDelete(mode.entry.id)
                        }
                    }
                }
                .padding(DotNoteTheme.Spacing.md)
            }
            .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
            .navigationTitle(mode.isCreating ? "일기" : "일기 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { editorToolbar(saveTint: DotNoteEntryKind.diary.dot) }
        }
    }

    @ToolbarContentBuilder
    private func editorToolbar(saveTint: Color) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("닫기", action: onCancel)
                .disabled(isSaving)
                .accessibilityIdentifier("entry-cancel-button")
        }
        ToolbarItem(placement: .principal) {
            Text(mode.isCreating ? "일기" : "일기 수정")
                .font(DotNoteType.wordmarkFont(size: 24))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                .accessibilityIdentifier("editor-title")
        }
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task { await save() }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(saveTint))
            }
            .disabled(isSaving)
            .accessibilityIdentifier("entry-save-button")
        }
    }

    private func save() async {
        let entry = draft.entry(id: mode.entry.id, kind: .diary, imageData: mode.entry.imageData)
        if mode.isCreating {
            await onCreate(entry)
        } else {
            await onSave(entry)
        }
    }
}

private struct DrawingEditorView: View {
    var mode: DotNoteEntryEditorMode
    var settings: DotNoteSettings?
    var isSaving: Bool
    var onSave: (DotNoteEntry) async -> Void
    var onCreate: (DotNoteEntry) async -> Void
    var onDelete: (DotNoteEntry.ID) async -> Void
    var onCancel: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var draft: DotNoteEntryDraft
    @State private var canvasView = PKCanvasView()
    @State private var selectedInk = UIColor(red: 58 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1)
    @State private var lineWidth: CGFloat = 5
    @State private var isEraser = false

    init(
        mode: DotNoteEntryEditorMode,
        settings: DotNoteSettings?,
        isSaving: Bool,
        onSave: @escaping (DotNoteEntry) async -> Void,
        onCreate: @escaping (DotNoteEntry) async -> Void,
        onDelete: @escaping (DotNoteEntry.ID) async -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.settings = settings
        self.isSaving = isSaving
        self.onSave = onSave
        self.onCreate = onCreate
        self.onDelete = onDelete
        self.onCancel = onCancel
        _draft = State(initialValue: DotNoteEntryDraft(entry: mode.entry))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                    EditorDateWeatherHeader(draft: $draft, kind: .drawing)

                    TextField("제목", text: $draft.title)
                        .font(.system(size: 20, weight: .bold))
                        .padding(DotNoteTheme.Spacing.md)
                        .background(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg).fill(DotNoteTheme.Palette.card(scheme)))
                        .accessibilityIdentifier("entry-title-field")

                    DrawingCanvas(canvasView: $canvasView, inkColor: selectedInk, lineWidth: lineWidth, isEraser: isEraser)
                        .frame(height: 280)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                                .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
                        )
                        .accessibilityIdentifier("drawing-canvas")

                    DrawingToolbar(
                        selectedInk: $selectedInk,
                        lineWidth: $lineWidth,
                        isEraser: $isEraser,
                        onUndo: { canvasView.undoManager?.undo() }
                    )

                    TextEditor(text: $draft.body)
                        .font(DotNoteType.body(settings).font(size: CGFloat(settings?.bodyFontSize ?? 16)))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(DotNoteTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                                .fill(DotNoteEntryKind.diary.surface(scheme))
                        )
                        .accessibilityIdentifier("entry-body-editor")

                    if !mode.isCreating {
                        DeleteButton(isSaving: isSaving) {
                            await onDelete(mode.entry.id)
                        }
                    }
                }
                .padding(DotNoteTheme.Spacing.md)
            }
            .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
            .navigationTitle(mode.isCreating ? "그림" : "그림 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { editorToolbar }
            .onAppear {
                canvasView.backgroundColor = .clear
                canvasView.drawingPolicy = .anyInput
            }
        }
    }

    @ToolbarContentBuilder
    private var editorToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("닫기", action: onCancel)
                .disabled(isSaving)
                .accessibilityIdentifier("entry-cancel-button")
        }
        ToolbarItem(placement: .principal) {
            Text(mode.isCreating ? "그림" : "그림 수정")
                .font(DotNoteType.wordmarkFont(size: 24))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                .accessibilityIdentifier("editor-title")
        }
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task { await save() }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(DotNoteEntryKind.drawing.dot))
            }
            .disabled(isSaving || draft.isEmpty)
            .accessibilityIdentifier("entry-save-button")
        }
    }

    private func save() async {
        let bounds = canvasView.bounds.isEmpty ? CGRect(origin: .zero, size: CGSize(width: 320, height: 280)) : canvasView.bounds
        let image = canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
        let imageData = canvasView.drawing.strokes.isEmpty ? mode.entry.imageData : image.pngData()
        let entry = draft.entry(id: mode.entry.id, kind: .drawing, imageData: imageData)
        if mode.isCreating {
            await onCreate(entry)
        } else {
            await onSave(entry)
        }
    }
}

private struct MemoOverlayView: View {
    var mode: DotNoteEntryEditorMode
    var settings: DotNoteSettings?
    var isSaving: Bool
    var onSave: (DotNoteEntry) async -> Void
    var onCreate: (DotNoteEntry) async -> Void
    var onDelete: (DotNoteEntry.ID) async -> Void
    var onCancel: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var draft: DotNoteEntryDraft

    init(
        mode: DotNoteEntryEditorMode,
        settings: DotNoteSettings?,
        isSaving: Bool,
        onSave: @escaping (DotNoteEntry) async -> Void,
        onCreate: @escaping (DotNoteEntry) async -> Void,
        onDelete: @escaping (DotNoteEntry.ID) async -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.settings = settings
        self.isSaving = isSaving
        self.onSave = onSave
        self.onCreate = onCreate
        self.onDelete = onDelete
        self.onCancel = onCancel
        _draft = State(initialValue: DotNoteEntryDraft(entry: mode.entry))
    }

    var body: some View {
        ZStack {
            DotNoteTheme.Palette.paper(scheme).opacity(0.96).ignoresSafeArea()
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityElement()
                .accessibilityIdentifier("memo-overlay")

            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Self.dateFormatter.string(from: draft.createdAt))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                        Text("메모")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(DotNoteEntryKind.memo.chipForeground(scheme))
                    }
                    Spacer()
                    Button {
                        Task { await close() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                            .frame(width: 36, height: 36)
                    }
                    .accessibilityIdentifier("entry-cancel-button")
                }

                TextField("제목", text: $draft.title)
                    .font(.system(size: 18, weight: .semibold))
                    .accessibilityIdentifier("entry-title-field")

                TextEditor(text: $draft.body)
                    .font(DotNoteType.body(settings).font(size: CGFloat(settings?.bodyFontSize ?? 16)))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 170)
                    .accessibilityIdentifier("entry-body-editor")

                HStack {
                    if !mode.isCreating {
                        Button(role: .destructive) {
                            Task { await onDelete(mode.entry.id) }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                        .disabled(isSaving)
                        .accessibilityIdentifier("entry-delete-button")
                    }

                    Spacer()

                    Button {
                        Task { await save() }
                    } label: {
                        Label("저장", systemImage: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, DotNoteTheme.Spacing.md)
                            .padding(.vertical, DotNoteTheme.Spacing.xs)
                            .background(Capsule().fill(DotNoteEntryKind.memo.dot))
                            .foregroundStyle(.white)
                    }
                    .disabled(isSaving || draft.isEmpty)
                    .accessibilityIdentifier("entry-save-button")
                }
            }
            .padding(DotNoteTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.xl, style: .continuous)
                    .fill(DotNoteEntryKind.memo.surface(scheme))
                    .shadow(color: DotNoteTheme.Shadow.cardColor,
                            radius: DotNoteTheme.Shadow.cardRadius,
                            y: DotNoteTheme.Shadow.cardY)
            )
            .padding(DotNoteTheme.Spacing.lg)
        }
    }

    private func save() async {
        let entry = draft.entry(id: mode.entry.id, kind: .memo, imageData: nil)
        if mode.isCreating {
            await onCreate(entry)
        } else {
            await onSave(entry)
        }
    }

    private func close() async {
        if draft.isEmpty {
            onCancel()
        } else {
            await save()
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }()
}

private struct EditorDateWeatherHeader: View {
    @Binding var draft: DotNoteEntryDraft
    var kind: DotNoteEntryKind

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
            DatePicker("날짜", selection: $draft.createdAt, displayedComponents: .date)
                .font(.system(size: 14, weight: .semibold))
                .tint(kind.chipForeground(scheme))
                .accessibilityIdentifier("entry-date-picker")

            WeatherPicker(selection: $draft.weather)
        }
        .padding(DotNoteTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
    }
}

struct WeatherPicker: View {
    @Binding var selection: String

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: DotNoteTheme.Spacing.xs) {
            ForEach(DotNoteWeather.presets, id: \.self) { label in
                Button {
                    selection = label
                } label: {
                    Image(systemName: DotNoteWeather.symbolName(for: label))
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                                .fill(selection == label ? DotNoteTheme.Palette.today : DotNoteTheme.Palette.paper(scheme))
                        )
                        .foregroundStyle(selection == label ? .white : DotNoteTheme.Palette.inkSoft(scheme))
                }
                .accessibilityLabel(label)
                .accessibilityIdentifier("weather-\(label)")
            }
        }
    }
}

private struct AlignmentToolbar: View {
    @Binding var selection: DotNoteTextAlignment
    var tint: Color

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: DotNoteTheme.Spacing.xs) {
            ForEach(DotNoteTextAlignment.allCases) { alignment in
                Button {
                    selection = alignment
                } label: {
                    Image(systemName: alignment.symbolName)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 38, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                                .fill(selection == alignment ? tint.opacity(0.18) : DotNoteTheme.Palette.card(scheme))
                        )
                        .foregroundStyle(selection == alignment ? tint : DotNoteTheme.Palette.inkSoft(scheme))
                }
                .accessibilityIdentifier("align-\(alignment.rawValue)")
            }
        }
    }
}

private struct DrawingToolbar: View {
    @Binding var selectedInk: UIColor
    @Binding var lineWidth: CGFloat
    @Binding var isEraser: Bool
    var onUndo: () -> Void

    private let colors: [UIColor] = [
        UIColor(red: 58 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1),
        UIColor(red: 208 / 255, green: 69 / 255, blue: 59 / 255, alpha: 1),
        UIColor(red: 224 / 255, green: 169 / 255, blue: 79 / 255, alpha: 1),
        UIColor(red: 91 / 255, green: 139 / 255, blue: 176 / 255, alpha: 1),
        UIColor(red: 123 / 255, green: 160 / 255, blue: 91 / 255, alpha: 1),
        .white
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
            HStack(spacing: DotNoteTheme.Spacing.xs) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    Button {
                        selectedInk = color
                        isEraser = false
                    } label: {
                        Circle()
                            .fill(Color(uiColor: color))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.black.opacity(color == .white ? 0.18 : 0), lineWidth: 1))
                    }
                    .accessibilityIdentifier("drawing-color-\(index)")
                }

                Spacer()

                Button {
                    isEraser.toggle()
                } label: {
                    Image(systemName: isEraser ? "eraser.fill" : "pencil.tip")
                        .frame(width: 34, height: 34)
                }
                .accessibilityIdentifier("drawing-tool-toggle")

                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .frame(width: 34, height: 34)
                }
                .accessibilityIdentifier("drawing-undo")
            }

            Slider(value: $lineWidth, in: 2...16)
                .tint(DotNoteEntryKind.drawing.dot)
                .accessibilityIdentifier("drawing-line-width")
        }
    }
}

private struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var inkColor: UIColor
    var lineWidth: CGFloat
    var isEraser: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = currentTool
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = currentTool
    }

    private var currentTool: PKTool {
        isEraser ? PKEraserTool(.vector) : PKInkingTool(.pen, color: inkColor, width: lineWidth)
    }
}

private struct DeleteButton: View {
    var isSaving: Bool
    var action: () async -> Void

    var body: some View {
        Button(role: .destructive) {
            Task { await action() }
        } label: {
            Label("삭제", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(isSaving)
        .accessibilityIdentifier("entry-delete-button")
    }
}

private struct DotNoteEntryDraft {
    var createdAt: Date
    var title: String
    var weather: String
    var body: String
    var textAlignment: DotNoteTextAlignment

    init(entry: DotNoteEntry) {
        createdAt = entry.createdAt
        title = entry.title
        weather = entry.weather
        body = entry.body
        textAlignment = entry.textAlignment
    }

    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func entry(id: DotNoteEntry.ID, kind: DotNoteEntryKind, imageData: Data?) -> DotNoteEntry {
        DotNoteEntry(
            id: id,
            kind: kind,
            createdAt: createdAt,
            title: title,
            weather: weather,
            body: body,
            textAlignment: textAlignment,
            imageData: imageData
        )
    }
}

private extension DotNoteTextAlignment {
    var symbolName: String {
        switch self {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        }
    }
}
