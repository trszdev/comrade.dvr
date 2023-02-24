import Foundation
import Util

struct URLMaker {
  let datedFileManager: DatedFileManager

  var frontCamera: () -> URL {
    return { datedFileManager.url(name: "selfie", date: Date()) }
  }

  var backCamera: () -> URL {
    return { datedFileManager.url(name: "camera", date: Date()) }
  }

  var microphone: () -> URL {
    return { datedFileManager.url(name: "microphone", date: Date()) }
  }
}
