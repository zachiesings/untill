import SwiftUI

struct EventEditorView: View {
    @EnvironmentObject var model: AppModel
    let onClose: () -> Void

    /// nil when adding a new event; otherwise the event being edited.
    let event: CountdownEvent?

    @State private var title: String
    @State private var date: Date
    @State private var emoji: String
    @State private var colorIndex: Int

    private var theme: AppTheme { model.settings.theme }
    private var isEditing: Bool { event != nil }

    /// Emojis available to free users.
    private let freeEmojis = ["🎉", "🎂", "✈️", "📅", "❤️", "🎄", "🎓", "🏆"]
    /// Additional emojis unlocked with Pro.
    private let proEmojis = ["🎈", "🍾", "🌸", "🎁", "💍", "🏖️", "🚀", "⭐️",
                             "🎯", "🩺", "🏠", "💼", "📦", "🐣", "🌙", "☀️"]

    init(event: CountdownEvent?, onClose: @escaping () -> Void) {
        self.event = event
        self.onClose = onClose
        _title = State(initialValue: event?.title ?? "")
        _date = State(initialValue: event?.date ?? Calendar.current.startOfDay(for: Date()))
        _emoji = State(initialValue: event?.emoji ?? "🎉")
        _colorIndex = State(initialValue: event?.colorIndex ?? 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit event" : "New event").font(.headline)
                Spacer()
                Button { onClose() } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.secondary)
                }.buttonStyle(.plain)
            }
            .padding(16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Title").font(.caption).foregroundStyle(Color.secondary)
                        TextField("Birthday, trip, deadline…", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Date").font(.caption).foregroundStyle(Color.secondary)
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    // Emoji
                    emojiSection

                    // Accent color (Pro)
                    colorSection
                }
                .padding(16)
            }

            Divider()

            // Footer actions
            VStack(spacing: 8) {
                if !canSave {
                    Text("Free plan is limited to 2 events. Unlock Pro for unlimited.")
                        .font(.caption2).foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                HStack {
                    if isEditing {
                        Button(role: .destructive) {
                            if let e = event { model.store.remove(e) }
                            onClose()
                        } label: {
                            Text("Delete")
                        }.buttonStyle(.bordered)
                    }
                    Spacer()
                    Button("Save", action: save)
                        .buttonStyle(.borderedProminent)
                        .tint(theme.accent)
                        .disabled(!canSave)
                }
            }
            .padding(16)
        }
        .frame(width: 320)
    }

    // MARK: - Sections

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("Emoji").font(.caption).foregroundStyle(Color.secondary)
                if !model.isPro {
                    Image(systemName: "crown.fill").font(.system(size: 9)).foregroundStyle(theme.accent)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 6) {
                ForEach(availableEmojis, id: \.self) { e in
                    Button {
                        emoji = e
                    } label: {
                        Text(e)
                            .font(.system(size: 20))
                            .frame(width: 30, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(emoji == e ? theme.accent.opacity(0.25) : Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(emoji == e ? theme.accent : Color.clear, lineWidth: 1.5)
                            )
                    }.buttonStyle(.plain)
                }
            }
            if !model.isPro {
                Text("More emojis with Pro").font(.caption2).foregroundStyle(Color.secondary)
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("Accent color").font(.caption).foregroundStyle(Color.secondary)
                if !model.isPro {
                    Image(systemName: "crown.fill").font(.system(size: 9)).foregroundStyle(theme.accent)
                }
            }
            HStack(spacing: 8) {
                ForEach(Array(CountdownEvent.palette.enumerated()), id: \.offset) { idx, color in
                    Button {
                        if model.isPro { colorIndex = idx }
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 26, height: 26)
                            .overlay(Circle().strokeBorder(.white, lineWidth: colorIndex == idx ? 2 : 0))
                            .overlay(alignment: .bottomTrailing) {
                                if !model.isPro {
                                    Image(systemName: "lock.fill").font(.system(size: 7)).foregroundStyle(.white)
                                }
                            }
                            .opacity(model.isPro || colorIndex == idx ? 1 : 0.55)
                    }.buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private var availableEmojis: [String] {
        model.isPro ? (freeEmojis + proEmojis) : freeEmojis
    }

    /// When adding, respect the free-tier limit; when editing it's always allowed.
    private var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if isEditing { return true }
        return model.canAddEvent
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        guard !cleanTitle.isEmpty else { return }
        let day = Calendar.current.startOfDay(for: date)

        if var existing = event {
            existing.title = cleanTitle
            existing.date = day
            existing.emoji = emoji
            existing.colorIndex = colorIndex
            model.store.update(existing)
        } else {
            guard model.canAddEvent else { return }
            let new = CountdownEvent(title: cleanTitle, date: day, emoji: emoji, colorIndex: colorIndex)
            model.store.add(new)
        }
        onClose()
    }
}
