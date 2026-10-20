import AppKit
import libxml2

extension NSAttributedString {
  // Only locally generated markup reaches AppKit: its HTML importer can fetch
  // external resources, even when the host application has no network entitlement.
  nonisolated static func clipboardHTML(_ data: Data) -> NSAttributedString? {
    guard !data.isEmpty, data.count <= Int32.max else { return nil }

    let options = Int32(HTML_PARSE_RECOVER.rawValue | HTML_PARSE_NONET.rawValue |
                        HTML_PARSE_NOERROR.rawValue | HTML_PARSE_NOWARNING.rawValue)
    let encoding = String(data: data, encoding: .utf8) == nil ? nil : "UTF-8"
    let document = data.withUnsafeBytes { buffer in
      htmlReadMemory(buffer.bindMemory(to: CChar.self).baseAddress, Int32(data.count), nil, encoding, options)
    }
    guard let document else { return nil }
    defer { xmlFreeDoc(document) }

    let body = localMarkup(document.pointee.children)
    let html = "<html><head><meta charset='utf-8'></head><body>\(body)</body></html>"
    return NSAttributedString(html: Data(html.utf8), documentAttributes: nil)
  }

  nonisolated private static func localMarkup(_ first: xmlNodePtr?) -> String {
    let allowedTags: Set<String> = [
      "a", "b", "blockquote", "br", "caption", "code", "dd", "del", "div", "dl", "dt", "em",
      "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "li", "ol", "p", "pre", "s", "small",
      "span", "strike", "strong", "sub", "sup", "table", "tbody", "td", "tfoot", "th", "thead",
      "tr", "u", "ul"
    ]
    let excludedTags: Set<String> = ["head", "script", "style", "template"]
    var markup = ""
    var node = first
    while let current = node {
      defer { node = current.pointee.next }
      switch current.pointee.type {
      case XML_TEXT_NODE, XML_CDATA_SECTION_NODE:
        if let content = current.pointee.content {
          markup += String(cString: content)
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        }
      case XML_ELEMENT_NODE:
        let tag = String(cString: current.pointee.name).lowercased()
        guard !excludedTags.contains(tag) else { continue }
        let children = localMarkup(current.pointee.children)
        if allowedTags.contains(tag) {
          // Never copy attributes (src, href, style, srcdoc, etc.) or unknown tags.
          markup += ["br", "hr"].contains(tag) ? "<\(tag)>" : "<\(tag)>\(children)</\(tag)>"
        } else {
          markup += children
        }
      default:
        break
      }
    }
    return markup
  }
}
