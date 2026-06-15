import SwiftUI

/// Persists and manages countdown events locally in `UserDefaults` (JSON).
@MainActor
final class EventsStore: ObservableObject {
    private let d = UserDefaults.standard
    private let eventsKey = "untill.events"
    private let pinnedKey = "untill.pinned"

    @Published var events: [CountdownEvent] = [] {
        didSet { save() }
    }

    /// Pro-only: id of the event that should drive the menu bar. When nil (or
    /// the event no longer exists) the nearest upcoming event is used.
    @Published var pinnedEventID: UUID? {
        didSet {
            if let id = pinnedEventID { d.set(id.uuidString, forKey: pinnedKey) }
            else { d.removeObject(forKey: pinnedKey) }
        }
    }

    init() {
        if let raw = d.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: raw) {
            events = decoded
        } else {
            events = EventsStore.seedEvents()
        }
        if let raw = d.string(forKey: pinnedKey) {
            pinnedEventID = UUID(uuidString: raw)
        }
    }

    // MARK: - CRUD

    func add(_ event: CountdownEvent) {
        events.append(event)
    }

    func update(_ event: CountdownEvent) {
        if let i = events.firstIndex(where: { $0.id == event.id }) {
            events[i] = event
        }
    }

    func remove(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        if pinnedEventID == event.id { pinnedEventID = nil }
    }

    // MARK: - Derived

    /// Future or today, sorted ascending by date.
    var upcoming: [CountdownEvent] {
        events
            .filter { $0.daysRemaining >= 0 }
            .sorted { $0.date < $1.date }
    }

    /// The nearest upcoming event (today or later).
    var nextEvent: CountdownEvent? { upcoming.first }

    /// The event that drives the menu bar: the pinned one if it still exists
    /// and is upcoming, otherwise the nearest upcoming event.
    var menuBarEvent: CountdownEvent? {
        if let id = pinnedEventID, let pinned = events.first(where: { $0.id == id }) {
            return pinned
        }
        return nextEvent
    }

    /// Short label shown in the menu bar, e.g. "12d", "Today" — or a friendly
    /// placeholder when there are no events yet.
    var menuBarText: String {
        guard let e = menuBarEvent else { return "—" }
        return e.shortCount
    }

    // MARK: - Persistence

    private func save() {
        if let raw = try? JSONEncoder().encode(events) {
            d.set(raw, forKey: eventsKey)
        }
    }

    // MARK: - Seed

    private static func seedEvents() -> [CountdownEvent] {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)

        // Next New Year's Day (Jan 1). If we're already past this year's, use next year.
        var nyComps = DateComponents()
        nyComps.year = year + 1
        nyComps.month = 1
        nyComps.day = 1
        let newYear = cal.date(from: nyComps) ?? now

        // Seed a single friendly example so a free user still has room to add one.
        return [
            CountdownEvent(title: "New Year", date: newYear, emoji: "🎉", colorIndex: 0)
        ]
    }
}
