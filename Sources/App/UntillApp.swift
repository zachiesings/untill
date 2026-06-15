import SwiftUI

@main
struct UntillApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuView()
                .environmentObject(model)
        } label: {
            Text(model.menuBarText)
        }
        .menuBarExtraStyle(.window)
    }
}
