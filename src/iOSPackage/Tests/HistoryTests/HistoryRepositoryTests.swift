import XCTest
import Util
@testable import History

final class HistoryRepositoryTests: XCTestCase {
  private var datedFileManagerMock = DatedFileManagerMock()
  private lazy var sut = HistoryRepositoryImpl(datedFileManager: datedFileManagerMock)

  private let url1 = Bundle.module.url(forResource: "file_example_MOV_480_700kB", withExtension: "mov")!
  private let url2 = Bundle.module.url(forResource: "SampleVideo_360x240_1mb", withExtension: "mp4")!
  private let url3 = Bundle.module.url(forResource: "SampleAudio_0.4mb", withExtension: "mp3")!
  private let day1 = Date(timeIntervalSince1970: 0)
  private let day2 = Date(timeIntervalSince1970: 0).addingTimeInterval(.days(1))

  func testGroupingByDate() async {
    let entry1 = DatedFileManagerEntry(name: "kok", url: url1, date: day1, size: .zero)
    let entry2 = DatedFileManagerEntry(name: "xyz", url: url2, date: day1.addingTimeInterval(.hours(1)), size: .zero)
    let entry3 = DatedFileManagerEntry(name: "aaa", url: url3, date: day2, size: .zero)
    datedFileManagerMock.allEntries = {[ entry1, entry2, entry3 ]}

    let history = await sut.loadHistory()

    XCTAssertEqual(history.count, 2)
    XCTAssertEqual(history[0].items.map(\.url), [url1, url2])
    XCTAssertEqual(history[0].items.map(\.createdAt), [day1, day1.addingTimeInterval(.hours(1))])
    XCTAssertEqual(history[0].items.map(\.previewType), [.video, .video])
    XCTAssert(history[0].items.map(\.duration).allSatisfy { $0 > 2 })
    XCTAssertEqual(history[1].items.map(\.url), [url3])
    XCTAssertEqual(history[1].items.map(\.createdAt), [day2])
    XCTAssertEqual(history[1].items.map(\.previewType), [.audio])
    XCTAssert(history[1].items.map(\.duration).allSatisfy { $0 > 2 })
  }
}

private struct DatedFileManagerMock: DatedFileManager {

  var totalFileSize: FileSize = .zero
  var remove: (URL) -> Void = { _ in }
  var removeFiles: (FileSize?) -> Void = { _ in }
  var url: (String, Date) -> URL = { _, _ in URL(string: "http://example.com")! }
  var namedEntries: (String) -> [DatedFileManagerEntry] = { _ in [] }
  var allEntries: () -> [DatedFileManagerEntry] = { [] }

  func remove(url: URL) {
    self.remove(url)
  }

  func removeFiles(toFit capacity: FileSize?) {
    self.removeFiles(capacity)
  }

  func url(name: String, date: Date) -> URL {
    self.url(name, date)
  }

  func entries(name: String) -> [DatedFileManagerEntry] {
    self.namedEntries(name)
  }

  func entries() -> [DatedFileManagerEntry] {
    self.allEntries()
  }
}
