//
//  DotNoteEntryEditors.swift
//  Orbit
//
//  Typed SwiftUI editors for the redesign milestone 2.
//  View layer only; persistence stays behind DotNoteAppModel callbacks.
//

import PencilKit
import PhotosUI
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

                    VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
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

                        Rectangle()
                            .fill(DotNoteTheme.Palette.hairline(scheme))
                            .frame(height: 1)

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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
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
    @State private var selectedInk = DrawingPalette.colors[0]
    @State private var lineWidth: CGFloat = 5
    @State private var isEraser = false
    @State private var pickedImage: UIImage?
    @State private var photoPlacement = DrawingPhotoPlacement()
    @State private var isPhotoAdjusting = false
    @State private var didClearPhoto = false
    @State private var photoPickerItem: PhotosPickerItem?

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
        _pickedImage = State(initialValue: mode.entry.imageData.flatMap(UIImage.init(data:)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                    EditorDateWeatherHeader(draft: $draft, kind: .drawing)

                    TextField("제목", text: $draft.title)
                        .font(.system(size: 20, weight: .bold))
                        .padding(DotNoteTheme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg).fill(DotNoteTheme.Palette.card(scheme)))
                        .accessibilityIdentifier("entry-title-field")

                    DrawingCanvasBoard(
                        canvasView: $canvasView,
                        image: $pickedImage,
                        photoPlacement: $photoPlacement,
                        isPhotoAdjusting: $isPhotoAdjusting,
                        inkColor: selectedInk,
                        lineWidth: lineWidth,
                        isEraser: isEraser,
                        onClearPhoto: {
                            didClearPhoto = true
                        }
                    )

                    DrawingToolbar(
                        selectedInk: $selectedInk,
                        lineWidth: $lineWidth,
                        isEraser: $isEraser,
                        isPhotoAdjusting: $isPhotoAdjusting,
                        hasPhoto: pickedImage != nil,
                        photoPickerItem: $photoPickerItem,
                        onUndo: { canvasView.undoManager?.undo() },
                        onResetPhoto: { photoPlacement = DrawingPhotoPlacement() }
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
                .frame(maxWidth: .infinity, alignment: .leading)
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
            .onChange(of: photoPickerItem) { _, newItem in
                Task {
                    guard let newItem, let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                    pickedImage = UIImage(data: data)
                    photoPlacement = DrawingPhotoPlacement()
                    isPhotoAdjusting = true
                    didClearPhoto = false
                }
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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(DotNoteEntryKind.drawing.dot))
            }
            .disabled(isSaving || (draft.isEmpty && pickedImage == nil && canvasView.drawing.strokes.isEmpty))
            .accessibilityIdentifier("entry-save-button")
        }
    }

    private func save() async {
        let bounds = canvasView.bounds.isEmpty ? CGRect(origin: .zero, size: CGSize(width: 320, height: 280)) : canvasView.bounds
        let entry = draft.entry(id: mode.entry.id, kind: .drawing, imageData: composedImageData(bounds: bounds))
        if mode.isCreating {
            await onCreate(entry)
        } else {
            await onSave(entry)
        }
    }

    /// Bakes the picked photo (if any) and the PencilKit strokes into one image,
    /// matching what `DrawingCanvasBoard` shows on screen. Falls back to the
    /// previously saved image when nothing changed this session.
    private func composedImageData(bounds: CGRect) -> Data? {
        guard pickedImage != nil || !canvasView.drawing.strokes.isEmpty else {
            return didClearPhoto ? nil : mode.entry.imageData
        }
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let composed = renderer.image { _ in
            if let pickedImage {
                let inset = bounds.insetBy(dx: DotNoteTheme.Spacing.sm, dy: DotNoteTheme.Spacing.sm)
                pickedImage.draw(in: pickedImage.placedRect(in: inset, placement: photoPlacement))
            }
            canvasView.drawing.image(from: bounds, scale: UIScreen.main.scale).draw(in: bounds)
        }
        return composed.pngData()
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

                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
                    TextField("제목", text: $draft.title)
                        .font(.system(size: 18, weight: .semibold))
                        .accessibilityIdentifier("entry-title-field")

                    TextEditor(text: $draft.body)
                        .font(DotNoteType.body(settings).font(size: CGFloat(settings?.bodyFontSize ?? 16)))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 170)
                        .accessibilityIdentifier("entry-body-editor")

                    Rectangle()
                        .fill(DotNoteTheme.Palette.hairline(scheme))
                        .frame(height: 1)

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
    @State private var isPickingDate = false

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
            HStack {
                Text("날짜")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))

                Spacer()

                Button {
                    isPickingDate = true
                } label: {
                    Text(Self.dateFormatter.string(from: draft.createdAt))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(kind.chipForeground(scheme))
                        .padding(.horizontal, DotNoteTheme.Spacing.sm)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(kind.chipBackground(scheme)))
                }
                .accessibilityIdentifier("entry-date-picker")
            }

            WeatherPicker(selection: $draft.weather, fillsAvailableWidth: true)
        }
        .padding(DotNoteTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
        .sheet(isPresented: $isPickingDate) {
            NavigationStack {
                DatePicker("날짜", selection: $draft.createdAt, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(kind.chipForeground(scheme))
                    .padding(DotNoteTheme.Spacing.md)
                    .navigationTitle("날짜 선택")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("완료") { isPickingDate = false }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 EEEE"
        return f
    }()
}

struct WeatherPicker: View {
    @Binding var selection: String
    var fillsAvailableWidth = false

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        if fillsAvailableWidth {
            HStack(spacing: DotNoteTheme.Spacing.xs) {
                ForEach(DotNoteWeather.presets, id: \.self) { label in
                    weatherButton(for: label, fillsWidth: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DotNoteTheme.Spacing.xs) {
                    ForEach(DotNoteWeather.presets, id: \.self) { label in
                        weatherButton(for: label, fillsWidth: false)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func weatherButton(for label: String, fillsWidth: Bool) -> some View {
        Button {
            selection = label
        } label: {
            Image(systemName: DotNoteWeather.symbolName(for: label))
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: fillsWidth ? .infinity : nil)
                .frame(width: fillsWidth ? nil : 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                        .fill(selection == label ? DotNoteTheme.Palette.today : DotNoteTheme.Palette.paper(scheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                        .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: selection == label ? 0 : 1)
                )
                .foregroundStyle(selection == label ? .white : DotNoteTheme.Palette.inkSoft(scheme))
        }
        .accessibilityLabel(label)
        .accessibilityIdentifier("weather-\(label)")
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
    @Binding var isPhotoAdjusting: Bool
    var hasPhoto: Bool
    @Binding var photoPickerItem: PhotosPickerItem?
    var onUndo: () -> Void
    var onResetPhoto: () -> Void

    @Environment(\.colorScheme) private var scheme

    private var customInkBinding: Binding<Color> {
        Binding(
            get: { Color(uiColor: selectedInk) },
            set: { newColor in
                selectedInk = UIColor(newColor)
                isEraser = false
            }
        )
    }

    private var isUsingCustomInk: Bool {
        !isEraser && !DrawingPalette.colors.contains { $0.isSameInk(as: selectedInk) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
            HStack(spacing: DotNoteTheme.Spacing.xs) {
                ForEach(Array(DrawingPalette.colors.enumerated()), id: \.offset) { index, color in
                    DrawingColorButton(
                        color: color,
                        isSelected: color.isSameInk(as: selectedInk) && !isEraser,
                        scheme: scheme
                    ) {
                        selectedInk = color
                        isEraser = false
                    }
                    .accessibilityLabel("색상 \(index + 1)")
                    .accessibilityIdentifier("drawing-color-\(index)")
                }

                DrawingCustomColorButton(
                    selection: customInkBinding,
                    currentColor: selectedInk,
                    isSelected: isUsingCustomInk,
                    scheme: scheme
                )
                .accessibilityLabel("커스텀 색상")
                .accessibilityIdentifier("drawing-custom-color")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: DotNoteTheme.Spacing.xs) {
                Image(systemName: "line.diagonal")
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                    .frame(width: 18)

                Slider(value: $lineWidth, in: 2...16)
                    .tint(DotNoteEntryKind.drawing.dot)
                    .onChange(of: lineWidth) { _, _ in
                        isEraser = false
                    }
                    .frame(width: hasPhoto ? 88 : 112)
                    .accessibilityIdentifier("drawing-line-width")

                Text("\(Int(lineWidth))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                    .frame(width: 22)

                Spacer(minLength: 0)

                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(DrawingIconButtonStyle(isActive: false, scheme: scheme))
                .accessibilityLabel("사진 추가")
                .accessibilityIdentifier("drawing-photo-picker")

                if hasPhoto {
                    Button {
                        isPhotoAdjusting.toggle()
                    } label: {
                        Image(systemName: "crop")
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(DrawingIconButtonStyle(isActive: isPhotoAdjusting, scheme: scheme))
                    .accessibilityLabel(isPhotoAdjusting ? "사진 위치 조정 끄기" : "사진 위치 조정")
                    .accessibilityIdentifier("drawing-photo-adjust")
                }

                Button {
                    isPhotoAdjusting = false
                    isEraser.toggle()
                } label: {
                    Image(systemName: isEraser ? "eraser.fill" : "pencil.tip")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(DrawingIconButtonStyle(isActive: isEraser, scheme: scheme))
                .accessibilityLabel(isEraser ? "지우개" : "펜")
                .accessibilityIdentifier("drawing-tool-toggle")

                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(DrawingIconButtonStyle(isActive: false, scheme: scheme))
                .accessibilityLabel("실행 취소")
                .accessibilityIdentifier("drawing-undo")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if hasPhoto && isPhotoAdjusting {
                HStack(alignment: .top, spacing: DotNoteTheme.Spacing.sm) {
                    Image(systemName: "hand.draw")
                        .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                        .frame(width: 24)

                    Text("사진을 드래그하거나 두 손가락으로 확대해요.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)

                    Button(action: onResetPhoto) {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(DrawingIconButtonStyle(isActive: false, scheme: scheme))
                    .accessibilityLabel("사진 위치 초기화")
                    .accessibilityIdentifier("drawing-photo-reset")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DotNoteTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("drawing-toolbar")
    }
}

private struct DrawingColorButton: View {
    var color: UIColor
    var isSelected: Bool
    var scheme: ColorScheme
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                    .fill(isSelected ? DotNoteEntryKind.drawing.dot.opacity(0.14) : DotNoteTheme.Palette.paper(scheme))

                Circle()
                    .fill(Color(uiColor: color))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.black.opacity(color == .white ? 0.18 : 0), lineWidth: 1))
            }
            .frame(width: 40, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                    .stroke(isSelected ? DotNoteEntryKind.drawing.dot : DotNoteTheme.Palette.hairline(scheme), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct DrawingCustomColorButton: View {
    @Binding var selection: Color
    var currentColor: UIColor
    var isSelected: Bool
    var scheme: ColorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                .fill(isSelected ? DotNoteEntryKind.drawing.dot.opacity(0.14) : DotNoteTheme.Palette.paper(scheme))

            Circle()
                .fill(AngularGradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red], center: .center))
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))

            if isSelected {
                Circle()
                    .fill(Color(uiColor: currentColor))
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }

            ColorPicker("", selection: $selection, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 40, height: 40)
                .opacity(0.04)
        }
        .frame(width: 40, height: 40)
        .overlay(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                .stroke(isSelected ? DotNoteEntryKind.drawing.dot : DotNoteTheme.Palette.hairline(scheme), lineWidth: isSelected ? 2 : 1)
        )
    }
}

private enum DrawingPalette {
    static let colors: [UIColor] = [
        UIColor(red: 58 / 255, green: 48 / 255, blue: 43 / 255, alpha: 1),
        UIColor(red: 208 / 255, green: 69 / 255, blue: 59 / 255, alpha: 1),
        UIColor(red: 224 / 255, green: 169 / 255, blue: 79 / 255, alpha: 1),
        UIColor(red: 91 / 255, green: 139 / 255, blue: 176 / 255, alpha: 1),
        UIColor(red: 123 / 255, green: 160 / 255, blue: 91 / 255, alpha: 1),
        .white
    ]

}

private struct DrawingPhotoPlacement: Equatable {
    var scale: CGFloat = 1
    var offset: CGSize = .zero

    func applying(scale scaleDelta: CGFloat, offset offsetDelta: CGSize) -> DrawingPhotoPlacement {
        DrawingPhotoPlacement(
            scale: (scale * scaleDelta).clamped(to: 0.5...4),
            offset: CGSize(width: offset.width + offsetDelta.width, height: offset.height + offsetDelta.height)
        )
    }
}

private struct DrawingCanvasBoard: View {
    @Binding var canvasView: PKCanvasView
    @Binding var image: UIImage?
    @Binding var photoPlacement: DrawingPhotoPlacement
    @Binding var isPhotoAdjusting: Bool
    var inkColor: UIColor
    var lineWidth: CGFloat
    var isEraser: Bool
    var onClearPhoto: () -> Void

    @Environment(\.colorScheme) private var scheme
    @GestureState private var photoDragDelta: CGSize = .zero
    @GestureState private var photoScaleDelta: CGFloat = 1

    private var effectivePhotoPlacement: DrawingPhotoPlacement {
        photoPlacement.applying(scale: photoScaleDelta, offset: photoDragDelta)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                    .fill(Color.white)

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(DotNoteTheme.Spacing.sm)
                        .scaleEffect(effectivePhotoPlacement.scale)
                        .offset(effectivePhotoPlacement.offset)
                        .gesture(photoAdjustmentGesture)
                        .allowsHitTesting(isPhotoAdjusting)
                        .zIndex(isPhotoAdjusting ? 2 : 0)
                        .accessibilityIdentifier("drawing-canvas-preview")
                }

                DrawingCanvas(canvasView: $canvasView, inkColor: inkColor, lineWidth: lineWidth, isEraser: isEraser)
                    .allowsHitTesting(!isPhotoAdjusting)
                    .zIndex(1)
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                    .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
            )
            .shadow(color: DotNoteTheme.Shadow.cardColor.opacity(scheme == .dark ? 0.45 : 0.12), radius: 10, y: 4)

            if image != nil && isPhotoAdjusting {
                Button {
                    image = nil
                    photoPlacement = DrawingPhotoPlacement()
                    isPhotoAdjusting = false
                    onClearPhoto()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(DotNoteTheme.Palette.ink(scheme).opacity(0.75)))
                }
                .padding(DotNoteTheme.Spacing.xs)
                .accessibilityLabel("사진 제거")
                .accessibilityIdentifier("drawing-photo-clear")
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("drawing-canvas")
    }

    private var photoAdjustmentGesture: some Gesture {
        let drag = DragGesture()
            .updating($photoDragDelta) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                photoPlacement = photoPlacement.applying(scale: 1, offset: value.translation)
            }

        let zoom = MagnificationGesture()
            .updating($photoScaleDelta) { value, state, _ in
                state = value
            }
            .onEnded { value in
                photoPlacement = photoPlacement.applying(scale: value, offset: .zero)
            }

        return drag.simultaneously(with: zoom)
    }
}

private extension UIImage {
    /// The rect for drawing this image inside `bounds`, including the same
    /// scale/offset controls shown in `DrawingCanvasBoard`.
    func placedRect(in bounds: CGRect, placement: DrawingPhotoPlacement) -> CGRect {
        guard size.width > 0, size.height > 0 else { return bounds }
        let scale = min(bounds.width / size.width, bounds.height / size.height)
        let fitSize = CGSize(width: size.width * scale * placement.scale, height: size.height * scale * placement.scale)
        return CGRect(
            x: bounds.midX - fitSize.width / 2 + placement.offset.width,
            y: bounds.midY - fitSize.height / 2 + placement.offset.height,
            width: fitSize.width,
            height: fitSize.height
        )
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

private struct DrawingIconButtonStyle: ButtonStyle {
    var isActive: Bool
    var scheme: ColorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isActive ? DotNoteEntryKind.drawing.dot : DotNoteTheme.Palette.inkSoft(scheme))
            .background(
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                    .fill(isActive ? DotNoteEntryKind.drawing.dot.opacity(0.16) : DotNoteTheme.Palette.paper(scheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                    .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.72 : 1)
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

private extension UIColor {
    func isSameInk(as other: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return abs(r1 - r2) < 0.01
            && abs(g1 - g2) < 0.01
            && abs(b1 - b2) < 0.01
            && abs(a1 - a2) < 0.01
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

// MARK: - Settings

struct DotNoteSettingsView: View {
    var settings: DotNoteSettings?
    var entries: [DotNoteEntry]
    var isSaving: Bool
    var onUpdateSettings: (DotNoteSettings) async -> Void
    var onDeleteAllData: () async -> Void
    var onSelectEntry: (DotNoteEntry) -> Void
    var onClose: () -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.openURL) private var openURL
    @State private var isConfirmingDeleteAllData = false

    private var currentSettings: DotNoteSettings {
        settings ?? DotNoteSettings()
    }

    private var currentFont: DotNoteFontTheme {
        DotNoteType.body(settings)
    }

    private var currentAppearanceMode: DotNoteAppearanceMode {
        currentSettings.appearanceMode
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.lg) {
                    settingsHeader

                    DotNoteSettingsGroup {
                        NavigationLink {
                            DotNoteFontListView(settings: currentSettings, isSaving: isSaving) { font in
                                var updatedSettings = currentSettings
                                updatedSettings.bodyFontName = font.rawValue
                                await onUpdateSettings(updatedSettings)
                            }
                        } label: {
                            DotNoteSettingsRow(
                                icon: "textformat",
                                title: "폰트",
                                detail: currentFont.displayName,
                                tint: DotNoteEntryKind.diary.dot
                            )
                        }
                        .accessibilityIdentifier("settings-font-row")
                    }

                    DotNoteSettingsGroup {
                        DotNoteAppearanceModePicker(selection: currentAppearanceMode, isSaving: isSaving) { mode in
                            var updatedSettings = currentSettings
                            updatedSettings.appearanceMode = mode
                            await onUpdateSettings(updatedSettings)
                        }
                    }

                    DotNoteSettingsGroup {
                        NavigationLink {
                            DotNoteCollectionView(entries: entries, filter: .diary, onSelectEntry: onSelectEntry)
                        } label: {
                            DotNoteSettingsRow(
                                icon: "book.pages",
                                title: "일기보기",
                                detail: "\(entries.filter { $0.kind == .diary }.count)",
                                tint: DotNoteEntryKind.diary.dot
                            )
                        }
                        .accessibilityIdentifier("settings-diary-collection-row")

                        DotNoteSettingsDivider()

                        NavigationLink {
                            DotNoteCollectionView(entries: entries, filter: .drawing, onSelectEntry: onSelectEntry)
                        } label: {
                            DotNoteSettingsRow(
                                icon: "paintpalette",
                                title: "그림보기",
                                detail: "\(entries.filter { $0.kind == .drawing }.count)",
                                tint: DotNoteEntryKind.drawing.dot
                            )
                        }
                        .accessibilityIdentifier("settings-drawing-collection-row")

                        DotNoteSettingsDivider()

                        NavigationLink {
                            DotNoteCollectionView(entries: entries, filter: .memo, onSelectEntry: onSelectEntry)
                        } label: {
                            DotNoteSettingsRow(
                                icon: "note.text",
                                title: "메모보기",
                                detail: "\(entries.filter { $0.kind == .memo }.count)",
                                tint: DotNoteEntryKind.memo.dot
                            )
                        }
                        .accessibilityIdentifier("settings-memo-collection-row")
                    }

                    DotNoteSettingsGroup {
                        Button {
                            openFeedbackMail()
                        } label: {
                            DotNoteSettingsRow(
                                icon: "paperplane",
                                title: "의견보내기",
                                detail: nil,
                                tint: DotNoteTheme.Palette.accent(scheme)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings-feedback-row")

                        DotNoteSettingsDivider()

                        NavigationLink {
                            DotNoteHelpView()
                        } label: {
                            DotNoteSettingsRow(
                                icon: "questionmark.circle",
                                title: "사용법",
                                detail: nil,
                                tint: DotNoteTheme.Palette.accent(scheme)
                            )
                        }
                        .accessibilityIdentifier("settings-help-row")

                        DotNoteSettingsDivider()

                        NavigationLink {
                            DotNoteLicenseView()
                        } label: {
                            DotNoteSettingsRow(
                                icon: "curlybraces",
                                title: "Open-source License",
                                detail: nil,
                                tint: DotNoteTheme.Palette.accent(scheme)
                            )
                        }
                        .accessibilityIdentifier("settings-license-row")
                    }

                    Button(role: .destructive) {
                        isConfirmingDeleteAllData = true
                    } label: {
                        DotNoteSettingsRow(
                            icon: "trash",
                            title: "모든데이터 삭제",
                            detail: nil,
                            tint: DotNoteTheme.Palette.destructive,
                            isDestructive: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                    .accessibilityIdentifier("delete-all-data-button")
                }
                .padding(DotNoteTheme.Spacing.md)
            }
            .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
            .navigationBarHidden(true)
            .confirmationDialog(
                "모든 데이터를 삭제할까요?",
                isPresented: $isConfirmingDeleteAllData,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    Task { await onDeleteAllData() }
                }
                .accessibilityIdentifier("confirm-delete-all-data")
                Button("취소", role: .cancel) {}
            } message: {
                Text("되돌릴 수 없어요.")
            }
            .accessibilityIdentifier("settings-screen")
        }
    }

    private var settingsHeader: some View {
        HStack(alignment: .center, spacing: DotNoteTheme.Spacing.sm) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
            }
            .accessibilityIdentifier("settings-close-button")

            Text("설정")
                .font(DotNoteType.wordmarkFont(size: 36))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))

            Spacer()
        }
    }

    private func openFeedbackMail() {
        let subject = "Dot Note 의견보내기".urlEncodedForMail
        let body = "Dot Note에 대한 불편한 사항이나 개선사항 또는 아이디어가 있다면 보내주시기 바랍니다.\n\n의견: ".urlEncodedForMail
        guard let url = URL(string: "mailto:toffler00@gmail.com?subject=\(subject)&body=\(body)") else {
            return
        }
        openURL(url)
    }
}

/// Shared back-button + title header for settings sub-screens, matching
/// DotNoteSettingsView's own header so pushed screens don't fall back to the
/// system default nav bar's back button (a different, floating-pill style).
private struct SettingsSubscreenHeader: View {
    var title: String
    var titleSize: CGFloat = 36
    var onBack: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(alignment: .center, spacing: DotNoteTheme.Spacing.sm) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
            }
            .accessibilityIdentifier("subscreen-back-button")

            Text(title)
                .font(DotNoteType.wordmarkFont(size: titleSize))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))

            Spacer()
        }
    }
}

private struct DotNoteAppearanceModePicker: View {
    var selection: DotNoteAppearanceMode
    var isSaving: Bool
    var onSelectMode: (DotNoteAppearanceMode) async -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
            HStack(spacing: DotNoteTheme.Spacing.sm) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                            .fill(DotNoteTheme.Palette.accent(scheme).opacity(scheme == .dark ? 0.22 : 0.16))
                    )
                    .foregroundStyle(DotNoteTheme.Palette.accent(scheme))

                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.xxs) {
                    Text("화면 모드")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                    Text(selection.detailText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                }

                Spacer()
            }

            HStack(spacing: DotNoteTheme.Spacing.xs) {
                ForEach(DotNoteAppearanceMode.allCases) { mode in
                    Button {
                        Task { await onSelectMode(mode) }
                    } label: {
                        HStack(spacing: DotNoteTheme.Spacing.xxs) {
                            Image(systemName: mode.symbolName)
                                .font(.system(size: 12, weight: .semibold))
                            Text(mode.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .padding(.horizontal, DotNoteTheme.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(selection == mode ? DotNoteTheme.Palette.ink(scheme) : DotNoteTheme.Palette.paper(scheme))
                        )
                        .foregroundStyle(selection == mode ? DotNoteTheme.Palette.paper(scheme) : DotNoteTheme.Palette.inkSoft(scheme))
                        .overlay(
                            Capsule()
                                .stroke(selection == mode ? DotNoteTheme.Palette.ink(scheme).opacity(0) : DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                    .accessibilityIdentifier("appearance-\(mode.rawValue)")
                }
            }
        }
        .padding(DotNoteTheme.Spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("appearance-mode-picker")
    }
}

private struct DotNoteFontListView: View {
    var settings: DotNoteSettings
    var isSaving: Bool
    var onSelectFont: (DotNoteFontTheme) async -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var selectedFont: DotNoteFontTheme {
        DotNoteType.body(settings)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
                SettingsSubscreenHeader(title: "폰트", onBack: { dismiss() })
                    .padding(.bottom, DotNoteTheme.Spacing.xs)

                ForEach(DotNoteFontTheme.allCases) { font in
                    Button {
                        Task {
                            await onSelectFont(font)
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: DotNoteTheme.Spacing.sm) {
                            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.xxs) {
                                Text(font.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                                Text("\(font.displayName) · 오늘의 기록")
                                    .font(font.font(size: 19))
                                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                                    .lineLimit(1)
                            }

                            Spacer()

                            if selectedFont == font {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(DotNoteEntryKind.diary.dot)
                            }
                        }
                        .padding(DotNoteTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                                .fill(DotNoteTheme.Palette.card(scheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                                .stroke(selectedFont == font ? DotNoteEntryKind.diary.dot.opacity(0.42) : DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                    .accessibilityIdentifier("font-\(font.rawValue)")
                }
            }
            .padding(DotNoteTheme.Spacing.md)
        }
        .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .accessibilityIdentifier("font-list-screen")
    }
}

private struct DotNoteHelpView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private let sections: [(String, String)] = [
        ("기록하기", "홈의 + 버튼을 열고 메모, 그림, 일기 중 하나를 골라 오늘의 기록을 남길 수 있어요."),
        ("찾아보기", "달력에서 날짜를 고르면 그날의 기록이 아래에 모이고, 설정의 모아보기에서는 종류별로 다시 볼 수 있어요."),
        ("꾸미기", "일기에서는 날씨와 정렬을 고르고, 그림에서는 펜 색과 굵기를 바꿔 손그림을 남길 수 있어요."),
        ("글꼴", "설정의 폰트 메뉴에서 본문 글꼴을 바꾸면 새 화면과 기존 기록 보기에도 같은 글꼴이 적용돼요.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                SettingsSubscreenHeader(title: "사용법", onBack: { dismiss() })

                ForEach(sections, id: \.0) { section in
                    VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.xs) {
                        Text(section.0)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                        Text(section.1)
                            .font(DotNoteType.body(nil).font(size: 16))
                            .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DotNoteTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                            .fill(DotNoteTheme.Palette.card(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                            .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
                    )
                }
            }
            .padding(DotNoteTheme.Spacing.md)
        }
        .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .accessibilityIdentifier("help-screen")
    }
}

private struct DotNoteLicenseView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var licenseText: String {
        guard let url = Bundle.main.url(forResource: "opensourceLicense", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8),
              !text.isEmpty else {
            return "Open-source license information is unavailable."
        }
        return text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                SettingsSubscreenHeader(title: "Open-source License", titleSize: 32, onBack: { dismiss() })

                Text("Apache License")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))

                Text(licenseText)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(DotNoteTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                            .fill(DotNoteTheme.Palette.card(scheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                            .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
                    )
            }
            .padding(DotNoteTheme.Spacing.md)
        }
        .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .accessibilityIdentifier("license-screen")
    }
}

private struct DotNoteCollectionView: View {
    enum Filter {
        case diary
        case drawing
        case memo

        var title: String {
            switch self {
            case .diary: return "일기보기"
            case .drawing: return "그림보기"
            case .memo: return "메모보기"
            }
        }

        var kind: DotNoteEntryKind {
            switch self {
            case .diary: return .diary
            case .drawing: return .drawing
            case .memo: return .memo
            }
        }
    }

    var entries: [DotNoteEntry]
    var filter: Filter
    var onSelectEntry: (DotNoteEntry) -> Void

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var filteredEntries: [DotNoteEntry] {
        entries
            .filter { $0.kind == filter.kind }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private let columns = [
        GridItem(.flexible(), spacing: DotNoteTheme.Spacing.sm),
        GridItem(.flexible(), spacing: DotNoteTheme.Spacing.sm)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.md) {
                SettingsSubscreenHeader(title: filter.title, onBack: { dismiss() })

                if filteredEntries.isEmpty {
                    EmptyStateView()
                        .padding(.top, DotNoteTheme.Spacing.xl)
                } else {
                    LazyVGrid(columns: columns, spacing: DotNoteTheme.Spacing.sm) {
                        ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                            Button {
                                onSelectEntry(entry)
                            } label: {
                                DotNoteCollectionCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(entry.accessibilityTitle)
                            .accessibilityIdentifier("collection-\(filter.kind.rawValue)-entry-\(index)")
                        }
                    }
                }
            }
            .padding(DotNoteTheme.Spacing.md)
        }
        .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .accessibilityIdentifier("collection-\(filter.kind.rawValue)-screen")
    }
}

private struct DotNoteCollectionCard: View {
    var entry: DotNoteEntry

    @Environment(\.colorScheme) private var scheme

    private var primaryText: String {
        if !entry.title.isEmpty {
            return entry.title
        }
        if !entry.body.isEmpty {
            return entry.body
        }
        return entry.kind.label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                    .fill(entry.kind.surface(scheme))
                    .aspectRatio(1.08, contentMode: .fit)

                if let data = entry.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous))
                } else {
                    Text(primaryText)
                        .font(DotNoteType.body(nil).font(size: 18))
                        .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                        .lineLimit(4)
                        .padding(DotNoteTheme.Spacing.sm)
                }
            }

            Text(primaryText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                .lineLimit(1)

            HStack(spacing: DotNoteTheme.Spacing.xxs) {
                Circle()
                    .fill(entry.kind.chipForeground(scheme))
                    .frame(width: 6, height: 6)
                Text(Self.dateFormatter.string(from: entry.createdAt))
                    .font(.system(size: 11))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
            }
        }
        .padding(DotNoteTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M.d"
        return f
    }()
}

private extension DotNoteEntry {
    var accessibilityTitle: String {
        if !title.isEmpty {
            return title
        }
        if !body.isEmpty {
            return body
        }
        return kind.label
    }
}

private extension String {
    var urlEncodedForMail: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

private struct DotNoteSettingsGroup<Content: View>: View {
    @ViewBuilder var content: Content

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.lg, style: .continuous)
                .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
        )
    }
}

private struct DotNoteSettingsRow: View {
    var icon: String
    var title: String
    var detail: String?
    var tint: Color
    var isDestructive: Bool = false

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: DotNoteTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous)
                        .fill(tint.opacity(scheme == .dark ? 0.22 : 0.16))
                )
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isDestructive ? DotNoteTheme.Palette.destructive : DotNoteTheme.Palette.ink(scheme))

            Spacer()

            if let detail {
                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DotNoteTheme.Palette.faded(scheme))
        }
        .padding(DotNoteTheme.Spacing.md)
        .contentShape(Rectangle())
    }
}

private struct DotNoteSettingsDivider: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Rectangle()
            .fill(DotNoteTheme.Palette.hairline(scheme))
            .frame(height: 1)
            .padding(.leading, 60)
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

private extension DotNoteAppearanceMode {
    var displayName: String {
        switch self {
        case .system: return "시스템"
        case .light: return "라이트"
        case .dark: return "다크"
        }
    }

    var detailText: String {
        switch self {
        case .system: return "기기 설정을 따라가요."
        case .light: return "항상 밝은 화면으로 표시해요."
        case .dark: return "항상 어두운 화면으로 표시해요."
        }
    }

    var symbolName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

#if DEBUG
struct DotNoteSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DotNoteSettingsView(
                settings: DotNotePreviewData.settings,
                entries: DotNotePreviewData.entries,
                isSaving: false,
                onUpdateSettings: { _ in },
                onDeleteAllData: {},
                onSelectEntry: { _ in },
                onClose: {}
            )
            .preferredColorScheme(.light)
            .previewDisplayName("Settings Light")

            DotNoteSettingsView(
                settings: {
                    var settings = DotNotePreviewData.settings
                    settings.appearanceMode = .dark
                    return settings
                }(),
                entries: DotNotePreviewData.entries,
                isSaving: false,
                onUpdateSettings: { _ in },
                onDeleteAllData: {},
                onSelectEntry: { _ in },
                onClose: {}
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Settings Dark")
        }
    }
}
#endif
