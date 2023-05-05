import XCTest
@testable import Util

final class DatedFileManagerTests: XCTestCase {
  private let fileManager: FileManager = .default
  private lazy var sut = DatedFileManagerImpl(fileManager: fileManager, rootDirectory: fileManager.recordingsDirectory)

  func testTotalFileSizeEmpty() {
    XCTAssertEqual(sut.totalFileSize, .zero)
  }

  func testTotalFileSizeKilobyte() throws {
    let data = Data(count: 1024)
    let path = sut.rootDirectory.appendingPathComponent("test.txt", isDirectory: false)
    try data.write(to: path)

    XCTAssertEqual(sut.totalFileSize, .kilobytes(1))
    try fileManager.removeItem(at: path)
  }

  func testURL() {
    NSTimeZone.default = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    let url = sut.url(name: "qwe123", date: Date(timeIntervalSince1970: 0))

    XCTAssertEqual(url.pathComponents.suffix(2), ["qwe123", "1-Jan-1970_00-00-00"])
  }

  func testEnumerateEmpty() {
    let files = sut.entries(name: "qwe123")

    XCTAssert(files.isEmpty)
  }

  func testEnumerate() throws {
    let date = Date().addingTimeInterval(.seconds(-1))
    let data = Data(count: 1024)
    let url = sut.url(name: "qwe123", date: Date(timeIntervalSince1970: 0))
    try data.write(to: url)

    let entries = sut.entries(name: "qwe123")
    let entry = entries[0]

    XCTAssertEqual(entries.count, 1)
    XCTAssertEqual(entry.url, url)
    XCTAssertEqual(entry.size, .kilobytes(1))
    XCTAssertEqual(entry.name, "qwe123")
    XCTAssert(date <= entry.date)
    try fileManager.removeItem(at: url)
  }

  func testRemoveFiles() throws {
    let oldURL = sut.url(name: "asd", date: Date(timeIntervalSince1970: 0))
    let newURL = sut.url(name: "asd", date: Date(timeIntervalSinceReferenceDate: 0))
    try Data(count: 1024).write(to: oldURL)
    try Data(count: 1024).write(to: newURL)
    try fileManager.setAttributes([.creationDate: Date(timeIntervalSince1970: 0)], ofItemAtPath: oldURL.path)

    sut.removeFiles(toFit: .kilobytes(1))
    let oldExists = fileManager.fileExists(atPath: oldURL.path)
    let newExists = fileManager.fileExists(atPath: newURL.path)

    XCTAssert(newExists)
    XCTAssertFalse(oldExists)
    try? fileManager.removeItem(at: oldURL)
    try? fileManager.removeItem(at: newURL)
  }
}
