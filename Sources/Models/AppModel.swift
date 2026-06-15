import SwiftUI
import Combine

@MainActor
final class AppModel: ObservableObject {
    let store = EventsStore()
    let entitlements = Entitlements()
    let settings = Settings.shared

    private var bag = Set<AnyCancellable>()

    init() {
        // Re-broadcast nested ObservableObject changes so SwiftUI views update.
        store.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
        entitlements.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
        settings.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &bag)
    }

    var isPro: Bool { entitlements.isPro }

    /// Free tier may keep at most 2 events.
    var canAddEvent: Bool { isPro || store.events.count < 2 }

    /// The text shown in the menu bar, optionally prefixed with the driving
    /// event's emoji.
    var menuBarText: String {
        let count = store.menuBarText
        if settings.showEmojiInMenuBar, let emoji = store.menuBarEvent?.emoji, !emoji.isEmpty {
            return "\(emoji) \(count)"
        }
        return count
    }
}
