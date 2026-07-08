//
//  DotNoteHomeView.swift
//  Orbit
//
//  Calendar-first home screen and shared components for the redesign.
//  View layer only — all persistence flows through DotNoteAppModel.
//  Colors/fonts/spacing come from DotNoteTheme; none are hardcoded here.
//

import SwiftUI
import UIKit

// MARK: - Calendar used across the home screen (Sunday-first, matching 일~토)

private var dotNoteCalendar: Calendar {
    var c = Calendar(identifier: .gregorian)
    c.firstWeekday = 1
    return c
}

// MARK: - Home

struct CalendarHomeView: View {
    var entries: [DotNoteEntry]
    var settings: DotNoteSettings?
    var onCreate: (DotNoteEntryKind) -> Void
    var onSelectEntry: (DotNoteEntry) -> Void
    var onOpenSettings: () -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var selectedDate: Date = dotNoteCalendar.startOfDay(for: Date())

    private var entriesByDay: [Date: [DotNoteEntry]] {
        Dictionary(grouping: entries) { dotNoteCalendar.startOfDay(for: $0.createdAt) }
    }

    private var entriesForSelectedDay: [DotNoteEntry] {
        (entriesByDay[dotNoteCalendar.startOfDay(for: selectedDate)] ?? [])
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.lg) {
                header
                CreateActionRow(onPick: onCreate)
                MonthCalendar(entriesByDay: entriesByDay, selection: $selectedDate)

                VStack(alignment: .leading, spacing: DotNoteTheme.Spacing.sm) {
                    Text(Self.dayHeaderFormatter.string(from: selectedDate))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))

                    if entriesForSelectedDay.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(entriesForSelectedDay) { entry in
                            Button {
                                onSelectEntry(entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(DotNoteTheme.Spacing.md)
        }
        .background(DotNoteTheme.Palette.paper(scheme).ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Dot Note")
                .font(DotNoteType.wordmarkFont(size: 34))
                .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
            Spacer()
            Button(action: onOpenSettings) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
            }
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("open-settings-button")
        }
    }

    private static let dayHeaderFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 · EEEE"
        return f
    }()
}

// MARK: - Month calendar

struct MonthCalendar: View {
    var entriesByDay: [Date: [DotNoteEntry]]
    @Binding var selection: Date

    @Environment(\.colorScheme) private var scheme
    @State private var month: Date

    private let cal = dotNoteCalendar
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    init(entriesByDay: [Date: [DotNoteEntry]], selection: Binding<Date>) {
        self.entriesByDay = entriesByDay
        self._selection = selection
        let comps = dotNoteCalendar.dateComponents([.year, .month], from: selection.wrappedValue)
        self._month = State(initialValue: dotNoteCalendar.date(from: comps) ?? selection.wrappedValue)
    }

    private var monthStart: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
    }

    private var gridDates: [Date] {
        let leading = cal.component(.weekday, from: monthStart) - cal.firstWeekday
        let offset = (leading + 7) % 7
        let start = cal.date(byAdding: .day, value: -offset, to: monthStart) ?? monthStart
        return (0..<42).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        VStack(spacing: DotNoteTheme.Spacing.sm) {
            HStack {
                Text(Self.titleFormatter.string(from: monthStart))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                Spacer()
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityIdentifier("calendar-prev-month")
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityIdentifier("calendar-next-month")
            }
            .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))

            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(gridDates, id: \.self) { date in
                    let key = cal.startOfDay(for: date)
                    CalendarDayCell(
                        date: date,
                        isCurrentMonth: cal.isDate(date, equalTo: monthStart, toGranularity: .month),
                        isToday: cal.isDateInToday(date),
                        isSelected: cal.isDate(date, inSameDayAs: selection),
                        kinds: (entriesByDay[key] ?? []).map(\.kind)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selection = key }
                }
            }
        }
        .padding(DotNoteTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.xl, style: .continuous)
                .fill(DotNoteTheme.Palette.card(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.xl, style: .continuous)
                .stroke(DotNoteTheme.Palette.hairline(scheme), lineWidth: 1)
        )
        .shadow(color: DotNoteTheme.Shadow.cardColor.opacity(scheme == .dark ? 0 : 1),
                radius: DotNoteTheme.Shadow.cardRadius,
                y: DotNoteTheme.Shadow.cardY)
    }

    private func changeMonth(_ delta: Int) {
        if let next = cal.date(byAdding: .month, value: delta, to: monthStart) {
            withAnimation(.easeInOut(duration: 0.2)) { month = next }
        }
    }

    private static let titleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 yyyy"
        return f
    }()
}

// MARK: - Day cell

struct CalendarDayCell: View {
    var date: Date
    var isCurrentMonth: Bool
    var isToday: Bool
    var isSelected: Bool
    var kinds: [DotNoteEntryKind]

    @Environment(\.colorScheme) private var scheme

    private var uniqueKinds: [DotNoteEntryKind] {
        var seen: Set<DotNoteEntryKind> = []
        return kinds.filter { seen.insert($0).inserted }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isToday {
                    Circle().fill(DotNoteTheme.Palette.today)
                } else if isSelected {
                    Circle().strokeBorder(DotNoteTheme.Palette.accent(scheme), lineWidth: 1.5)
                }
                Text("\(dotNoteCalendar.component(.day, from: date))")
                    .font(.system(size: 15, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(dayColor)
            }
            .frame(width: 30, height: 30)

            HStack(spacing: 3) {
                ForEach(uniqueKinds.prefix(3), id: \.self) { kind in
                    Circle().fill(kind.dot).frame(width: 4, height: 4)
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }

    private var dayColor: Color {
        if isToday { return .white }
        return isCurrentMonth ? DotNoteTheme.Palette.ink(scheme) : DotNoteTheme.Palette.faded(scheme)
    }
}

// MARK: - Entry row

struct EntryRow: View {
    var entry: DotNoteEntry

    @Environment(\.colorScheme) private var scheme

    private var primaryText: String {
        entry.title.isEmpty ? entry.body : entry.title
    }

    var body: some View {
        HStack(spacing: DotNoteTheme.Spacing.sm) {
            if let data = entry.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(RoundedRectangle(cornerRadius: DotNoteTheme.Radius.sm, style: .continuous))
            } else {
                Circle().fill(entry.kind.dot).frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(primaryText.isEmpty ? entry.kind.label : primaryText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DotNoteTheme.Palette.ink(scheme))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(entry.kind.label)
                        .foregroundStyle(entry.kind.chipForeground(scheme))
                    if !entry.weather.isEmpty {
                        Image(systemName: DotNoteWeather.symbolName(for: entry.weather))
                            .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
                    }
                }
                .font(.system(size: 11))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DotNoteTheme.Palette.faded(scheme))
        }
        .padding(DotNoteTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DotNoteTheme.Radius.md, style: .continuous)
                .fill(entry.kind.chipBackground(scheme))
        )
    }
}

// MARK: - Create action row

struct CreateActionRow: View {
    var onPick: (DotNoteEntryKind) -> Void

    @Environment(\.colorScheme) private var scheme
    @State private var expanded = false

    private let kinds: [DotNoteEntryKind] = [.memo, .drawing, .diary]

    var body: some View {
        HStack(spacing: DotNoteTheme.Spacing.xs) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { expanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .rotationEffect(.degrees(expanded ? 45 : 0))
                    Text("새 기록")
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, DotNoteTheme.Spacing.md)
                .padding(.vertical, DotNoteTheme.Spacing.xs)
                .background(Capsule().fill(DotNoteTheme.Palette.ink(scheme)))
                .foregroundStyle(DotNoteTheme.Palette.paper(scheme))
            }
            .accessibilityIdentifier("create-toggle")

            if expanded {
                ForEach(kinds) { kind in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { expanded = false }
                        onPick(kind)
                    } label: {
                        HStack(spacing: 5) {
                            Circle().fill(kind.chipForeground(scheme)).frame(width: 7, height: 7)
                            Text(kind.label)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, DotNoteTheme.Spacing.sm)
                        .padding(.vertical, DotNoteTheme.Spacing.xs)
                        .background(Capsule().fill(kind.chipBackground(scheme)))
                        .foregroundStyle(kind.chipForeground(scheme))
                    }
                    .accessibilityIdentifier("create-\(kind.rawValue)")
                    .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer()
        }
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: DotNoteTheme.Spacing.sm) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(DotNoteTheme.Palette.faded(scheme))
            Text("아직 기록이 없어요")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DotNoteTheme.Palette.inkSoft(scheme))
            Text("＋ 새 기록으로 오늘을 남겨보세요.")
                .font(.system(size: 12))
                .foregroundStyle(DotNoteTheme.Palette.faded(scheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DotNoteTheme.Spacing.xl)
        .accessibilityIdentifier("empty-state")
    }
}
