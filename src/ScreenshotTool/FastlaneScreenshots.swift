import XCTest
import Accessibility

final class FastlaneScreenshots: XCTestCase {
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

  func testCaptureMainScreen() {
    let app = App().launch()
    app.waitForElement(.startButton)
    app.takeScreenshot(name: "main")
  }

  func testCaptureSettingsScreen() {
    let app = App().launch()
    app.waitForElement(.tabBarSettingsButton).tap()
    app.waitForElement(.settingsRateUsButton)
    app.takeScreenshot(name: "settings")
  }

  func testCaptureHistoryScreen() {
    let app = App().launch()
    app.waitForElement(.tabBarHistoryButton).tap()
    app.waitForElement(.historyCell)
    app.takeScreenshot(name: "history")
  }
}

private struct App {
  let xcApp = XCUIApplication()

  func launch() -> App {
    xcApp.launchArguments = [LaunchArgs.isRunningPreview.rawValue]
    setupSnapshot(xcApp)
    xcApp.launch()
    return self
  }

  @discardableResult func waitForElement(_ accessibility: Accessibility, timeout: TimeInterval = 3) -> XCUIElement {
    let query = xcApp.descendants(matching: .any)[accessibility.rawValue]
    XCTAssertTrue(query.waitForExistence(timeout: timeout))

    return query
  }

  func takeScreenshot(name: String) {
    snapshot(name)
  }
}
