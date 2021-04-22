import XCTest
@testable import CameraKit

class CKNearestConfigurationPickerTests: CKTestCase {
  override var isAbstractTestCase: Bool { true }

  var nonExistingConfiguration: CKConfiguration {
    notImplemented()
  }

  var existingConfiguration: CKConfiguration {
    notImplemented()
  }

  var requestedConfiguration: CKConfiguration {
    notImplemented()
  }

  var resultConfiguration: CKConfiguration {
    notImplemented()
  }

  func makePicker() -> CKNearestConfigurationPicker {
    notImplemented()
  }

  func makeEmptyPicker() -> CKNearestConfigurationPicker {
    notImplemented()
  }

  func testNonExistingDevice() {
    let picker = makePicker()
    let conf = picker.nearestConfiguration(for: nonExistingConfiguration)
    XCTAssertEqual(conf, .empty)
  }

  func testNonExistingDevice2() {
    let picker = makeEmptyPicker()
    let conf = picker.nearestConfiguration(for: nonExistingConfiguration)
    XCTAssertEqual(conf, .empty)
  }

  func testExistingConfiguration() {
    let picker = makePicker()
    let conf = picker.nearestConfiguration(for: existingConfiguration)
    XCTAssertEqual(conf, existingConfiguration)
  }

  func testNearestConfiguration() {
    let picker = makePicker()
    let conf = picker.nearestConfiguration(for: requestedConfiguration)
    XCTAssertEqual(conf, resultConfiguration)
  }
}
