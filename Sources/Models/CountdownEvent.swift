import SwiftUI

/// A single countdown to an important day. Fully local & Codable.
struct CountdownEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var date: Date
    var emoji: String
    var colorIndex: Int

    /// Whole calendar days from the start of *today* to the start of the
    /// event's day. Negative for days that have already passed.
    var daysRemaining: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: date)
        let comps = cal.dateComponents([.day], from: today, to: target)
        return comps.day ?? 0
    }

    /// Human-friendly label: "Today", "Tomorrow", "in 12 days", "12 days ago".
    var displayCount: String {
        let d = daysRemaining
        switch d {
        case 0: return "Today"
        case 1: return "Tomorrow"
        case -1: return "Yesterday"
        default:
            if d > 1 { return "in \(d) days" }
            return "\(-d) days ago"
        }
    }

    /// Compact menu-bar style count: "12d", "Today", "1d".
    var shortCount: String {
        let d = daysRemaining
        if d == 0 { return "Today" }
        if d > 0 { return "\(d)d" }
        return "\(d)d" // negative already carries the minus sign
    }

    /// The accent color for this event from the shared palette.
    var color: Color { CountdownEvent.palette[safe: colorIndex] ?? CountdownEvent.palette[0] }

    /// Date formatted for display, e.g. "Mon, Jan 1, 2027".
    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d, yyyy"
        return f.string(from: date)
    }

    /// ~6 accent colors selectable by `colorIndex`.
    static let palette: [Color] = [
        Color(red: 0.36, green: 0.49, blue: 0.98), // blue
        Color(red: 0.98, green: 0.45, blue: 0.42), // coral
        Color(red: 0.16, green: 0.78, blue: 0.62), // mint
        Color(red: 0.96, green: 0.62, blue: 0.30), // amber
        Color(red: 0.62, green: 0.31, blue: 0.87), // purple
        Color(red: 0.20, green: 0.60, blue: 0.86)  // sky
    ]
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
