import XCTest
import Combine
@testable import ComradeDVR

final class TestHistorySelectionComputerImpl: XCTestCase, HistorySelectionComputer {
  func testRemoveAfterSelection() {
    let cells = [1, 2, 3]
    let selection = computeSelection(cells: cells, selectedIndex: 0, indexToRemove: 1)
    XCTAssertEqual(0, selection)
  }

  func testRemoveBeforeSelection() {
    let cells = [1, 2, 3]
    let selection = computeSelection(cells: cells, selectedIndex: 2, indexToRemove: 1)
    XCTAssertEqual(1, selection)
  }

  func testRemoveSelectedSelectsPrevious() {
    let cells = [1, 2, 3]
    let selection = computeSelection(cells: cells, selectedIndex: 1, indexToRemove: 1)
    XCTAssertEqual(0, selection)
  }

  func testRemoveSelectedSelectsPrevious2() {
    let cells = [1, 2, 3]
    let selection = computeSelection(cells: cells, selectedIndex: 2, indexToRemove: 2)
    XCTAssertEqual(1, selection)
  }

  func testRemoveSelectedSelectsNext() {
    let cells = [1, 2, 3]
    let selection = computeSelection(cells: cells, selectedIndex: 0, indexToRemove: 0)
    XCTAssertEqual(0, selection)
  }

  func computeSelection<T>(cells: [T], selectedIndex: Int, indexToRemove: Int) -> Int {
    locator
      .resolve(HistorySelectionComputerImpl.self)
      .computeSelection(cells: cells, selectedIndex: selectedIndex, indexToRemove: indexToRemove)
  }
}
