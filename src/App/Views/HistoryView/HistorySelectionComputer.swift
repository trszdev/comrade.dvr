protocol HistorySelectionComputer {
  func computeSelection<T>(cells: [T], selectedIndex: Int, indexToRemove: Int) -> Int
}

struct HistorySelectionComputerImpl: HistorySelectionComputer {
  func computeSelection<T>(cells: [T], selectedIndex: Int, indexToRemove: Int) -> Int {
    indexToRemove > selectedIndex || (indexToRemove == 0 && selectedIndex == 0) ?
      selectedIndex :
      selectedIndex - 1
  }
}
