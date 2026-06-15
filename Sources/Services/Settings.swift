import SwiftUI

/// Lightweight, observable user preferences backed by `UserDefaults`.
final class Settings: ObservableObject {
    static let shared = Settings()
    private let d = UserDefaults.standard

    @Published var showEmojiInMenuBar: Bool {
        didSet { d.set(showEmojiInMenuBar, forKey: "untill.showEmojiInMenuBar") }
    }
    @Published var themeID: String {
        didSet { d.set(themeID, forKey: "untill.theme") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            d.set(launchAtLogin, forKey: "untill.launchAtLogin")
            LoginItem.setEnabled(launchAtLogin)
        }
    }

    var theme: AppTheme { AppTheme(rawValue: themeID) ?? .aurora }

    private init() {
        showEmojiInMenuBar = d.object(forKey: "untill.showEmojiInMenuBar") as? Bool ?? true
        themeID = d.string(forKey: "untill.theme") ?? AppTheme.aurora.rawValue
        launchAtLogin = LoginItem.isEnabled
    }
}
