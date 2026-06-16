import SwiftUI

struct MenuView: View {
    @EnvironmentObject var model: AppModel
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var editorEvent: CountdownEvent?   // existing event being edited
    @State private var showNewEditor = false          // adding a new event

    private var theme: AppTheme { model.settings.theme }

    var body: some View {
        VStack(spacing: 0) {
            if showPaywall {
                PaywallView(onClose: { showPaywall = false })
                    .environmentObject(model)
            } else if showSettings {
                SettingsView(onBack: { showSettings = false },
                             showPaywall: { showSettings = false; showPaywall = true })
                    .environmentObject(model)
            } else if showNewEditor {
                EventEditorView(event: nil, onClose: { showNewEditor = false })
                    .environmentObject(model)
            } else if let ev = editorEvent {
                EventEditorView(event: ev, onClose: { editorEvent = nil })
                    .environmentObject(model)
            } else {
                main
            }
        }
        .frame(width: 320)
    }

    private var main: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Text("Untill").font(.headline)
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape").foregroundStyle(Color.secondary)
                }.buttonStyle(.plain)
            }

            // Events
            if model.store.upcoming.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(model.store.upcoming) { ev in
                        eventCard(ev)
                    }
                }
            }

            // Add event
            Button(action: addTapped) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add event").font(.system(size: 13, weight: .medium))
                    Spacer()
                    if !model.canAddEvent {
                        Image(systemName: "crown.fill").font(.system(size: 10)).foregroundStyle(theme.accent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9).padding(.horizontal, 12)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }.buttonStyle(.plain)

            Divider()

            // Unlock Pro
            if !model.isPro {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Unlock Untill Pro").bold()
                        Spacer()
                        if !model.entitlements.priceText.isEmpty {
                            Text(model.entitlements.priceText).font(.caption).opacity(0.9)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9).padding(.horizontal, 12)
                    .background(LinearGradient(colors: theme.gradient, startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }.buttonStyle(.plain)
            }

            HStack {
                Button("Settings") { showSettings = true }.buttonStyle(.link)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }.buttonStyle(.link)
            }
            .font(.caption)
        }
        .padding(16)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 30))
                .foregroundStyle(theme.accent)
            Text("No upcoming events")
                .font(.system(size: 14, weight: .semibold))
            Text("Add a day to count down to.")
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
    }

    private func eventCard(_ ev: CountdownEvent) -> some View {
        let isPinned = model.store.menuBarEvent?.id == ev.id

        return Button {
            // Tapping a card pins it to the menu bar (Pro). Free → paywall.
            if model.isPro {
                model.store.pinnedEventID = ev.id
            } else {
                showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                Text(ev.emoji.isEmpty ? "📅" : ev.emoji)
                    .font(.system(size: 26))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(ev.title)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                        if isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(ev.color)
                        }
                    }
                    Text(ev.formattedDate)
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(ev.daysRemaining)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(ev.color)
                    Text(ev.daysRemaining == 1 ? "day" : "days")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.vertical, 9).padding(.horizontal, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isPinned ? ev.color.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
            .contextMenu {
                Button("Edit") { editorEvent = ev }
                Button("Delete", role: .destructive) { model.store.remove(ev) }
            }
        }
        .buttonStyle(.plain)
    }

    private func addTapped() {
        if model.canAddEvent {
            showNewEditor = true
        } else {
            showPaywall = true
        }
    }
}
