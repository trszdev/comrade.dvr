import Foundation

struct StartViewModelDevice: Identifiable {
  let id = UUID()
  let name: String
  let details: [String]
  let sfSymbol: SFSymbol
  let isActive: Bool
}
