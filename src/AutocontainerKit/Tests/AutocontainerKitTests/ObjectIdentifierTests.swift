import XCTest
@testable import AutocontainerKit

final class ObjectIdentifierTests: XCTestCase {
  func testBuiltins() {
    var forceUnwrap: Int!
    forceUnwrap = nil
    let ids = [
      ObjectIdentifier(Int.self),
      ObjectIdentifier(Int8.self),
      ObjectIdentifier(UInt.self),
      ObjectIdentifier(String.self),
      ObjectIdentifier(Bool.self),
      ObjectIdentifier(NSObject.self),
      ObjectIdentifier(type(of: forceUnwrap)),
      ObjectIdentifier(CustomStringConvertible.self),
      ObjectIdentifier(Bool?.self),
      ObjectIdentifier(type(of: (1...10))),
      ObjectIdentifier(((Int) -> Bool).self),
    ]
    XCTAssertEqual(Set(ids).count, ids.count)
    XCTAssertEqual(ObjectIdentifier(Bool?.self), ObjectIdentifier(Optional<Bool>.self))
    XCTAssertEqual(ObjectIdentifier(Int?.self), ObjectIdentifier(type(of: forceUnwrap)))
  }

  func testProtocols() {
    XCTAssertEqual(
      ObjectIdentifier((CustomStringConvertible & Error).self),
      ObjectIdentifier((Error & CustomStringConvertible).self)
    )
    XCTAssertNotEqual(ObjectIdentifier((CustomStringConvertible & Error).self), ObjectIdentifier(Error.self))
  }

  func testTypealias() {
    XCTAssertEqual(ObjectIdentifier(IntAlias.self), ObjectIdentifier(Int.self))
  }

  func testNested() {
    let (nested, nested2) = makeNestedObjectIds()
    XCTAssertNotEqual(nested, nested2)
    XCTAssertNotEqual(ObjectIdentifier(Struct.Nested.self), ObjectIdentifier(Class.Nested.self))
  }
}

func makeNestedObjectIds() -> (ObjectIdentifier, ObjectIdentifier) {
  func block() -> ObjectIdentifier {
    struct Block {}
    return ObjectIdentifier(Block.self)
  }
  func block2() -> ObjectIdentifier {
    struct Block {}
    return ObjectIdentifier(Block.self)
  }
  return (block(), block2())
}

private typealias IntAlias = Int
private struct Struct {
  struct Nested {}
}
private class Class {
  struct Nested {}
}
