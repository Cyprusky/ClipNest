import Cocoa

class About {
  @objc
  func openAbout(_ sender: NSMenuItem?) {
    let credits = NSMutableAttributedString(
      string: "ClipNest · Cyprusky\nPersonal fork of Maccy, by Alex Rodionov and contributors.\n\n",
      attributes: [.foregroundColor: NSColor.labelColor]
    )
    credits.append(NSAttributedString(string: "GitHub", attributes: [.link: AppIdentity.repositoryURL]))
    credits.append(NSAttributedString(string: " · "))
    credits.append(NSAttributedString(string: "Maccy (MIT)", attributes: [.link: AppIdentity.upstreamURL]))
    credits.setAlignment(.center, range: NSRange(location: 0, length: credits.length))
    NSApp.activate(ignoringOtherApps: true)
    NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
  }
}
