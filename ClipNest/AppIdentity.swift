import Foundation

nonisolated enum AppIdentity {
  static let name = "ClipNest"
  static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "io.github.cyprusky.ClipNest"
  static let repositoryURL = URL(string: "https://github.com/Cyprusky/ClipNest")!
  static let upstreamURL = URL(string: "https://github.com/p0deje/Maccy")!
  static let storageURL = URL.applicationSupportDirectory.appending(path: "\(name)/Storage.sqlite")
}
