import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewcontrollers = FlutterViewcontrollers()
    let windowFrame = self.frame
    self.contentViewcontrollers = flutterViewcontrollers
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewcontrollers)

    super.awakeFromNib()
  }
}
