import subprocess, http.server, threading, json, pathlib, plistlib
repo=pathlib.Path(__file__).resolve().parents[1]
root=repo/'.build'/'html-network'
root.mkdir(parents=True,exist_ok=True)
source=root/'main.swift'
source.write_text(r'''import AppKit
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let mode = CommandLine.arguments[1]
let url = CommandLine.arguments[2]
DispatchQueue.main.async {
  let html = """
  <!DOCTYPE html SYSTEM "\(url)/external.dtd">
  <html><head><base href="\(url)/base/"><link rel="stylesheet" href="\(url)/link.css">
  <style>@import url('\(url)/import.css'); body { background-image: url('\(url)/background.gif'); }</style>
  <meta http-equiv="refresh" content="0;url=\(url)/refresh"></head>
  <body background="\(url)/body.gif"><p style="background:url('\(url)/inline.gif')">中文 &amp; café 😀<br><b>bold</b></p>
  <img src="\(url)/image.gif?marker=synthetic-only" srcset="\(url)/srcset.gif 2x">
  <iframe src="\(url)/frame"></iframe><object data="\(url)/object"></object>
  <svg><image href="\(url)/svg.gif" /></svg><script src="\(url)/script.js">hidden</script>
  <p>&lt;img src='\(url)/escaped.gif'&gt;</p><p>done</p></body></html>
  """
  let result = mode == "baseline"
    ? NSAttributedString(html: Data(html.utf8), documentAttributes: nil)
    : NSAttributedString.clipboardHTML(Data(html.utf8))
  let text = result?.string ?? "<nil>"
  print("TEXT " + String(reflecting: text))
  if mode != "baseline" {
    precondition(text.contains("中文 & café 😀") && text.contains("bold") && text.contains("done"))
    precondition(!text.contains("hidden"))
    let xxe = "<!DOCTYPE html [<!ENTITY probe SYSTEM '\(url)/entity.txt'>]><html><body><p>&probe;entity-test</p></body></html>"
    let value = NSAttributedString.clipboardHTML(Data(xxe.utf8))
    print("ENTITY " + String(reflecting: value?.string))
    precondition(value?.string.contains("synthetic-external-entity") != true)
  }
  fflush(stdout)
  DispatchQueue.main.asyncAfter(deadline: .now() + 3) { app.terminate(nil) }
}
app.run()
''')
subprocess.run(['xcrun','swiftc',str(repo/'ClipNest/Extensions/NSAttributedString+ClipboardHTML.swift'),str(source),'-o',str(root/'probe')],check=True)
requests=[]
class Handler(http.server.BaseHTTPRequestHandler):
 def do_GET(self):
  requests.append(self.path)
  self.send_response(200)
  self.send_header('Content-Type','text/css' if self.path.endswith('.css') else 'image/gif')
  self.end_headers()
  self.wfile.write(b'' if self.path.endswith('.css') else bytes.fromhex('47494638396101000100800000000000ffffff21f90401000000002c00000000010001000002024401003b'))
 def log_message(self,*a): pass
server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
threading.Thread(target=server.serve_forever,daemon=True).start()
results=[]
for mode in ['baseline','fixed']:
 start=len(requests)
 p=subprocess.run([str(root/'probe'),mode,f'http://127.0.0.1:{server.server_port}/{mode}'],capture_output=True,text=True,timeout=30)
 results.append({'mode':mode,'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr,'requests':requests[start:]})
 print(json.dumps(results[-1],ensure_ascii=False),flush=True)
server.shutdown();server.server_close()
(root/'results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
assert results[0]['returncode']==0 and results[0]['requests'], 'positive control must fetch'
assert results[1]['returncode']==0 and results[1]['requests']==[], 'fixed path must not fetch'
print('PASS: positive control fetched; fixed HTML previews made zero requests')
