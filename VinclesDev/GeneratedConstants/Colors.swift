// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable operator_usage_whitespace
extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

// swiftlint:disable identifier_name line_length type_body_length
struct ColorName {
  let rgbaValue: UInt32
  var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#32b140"></span>
  /// Alpha: 100% <br/> (0x32b140ff)
  static let acceptGreen = ColorName(rgbaValue: 0x32b140ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e6e6e6"></span>
  /// Alpha: 100% <br/> (0xe6e6e6ff)
  static let clearGray = ColorName(rgbaValue: 0xe6e6e6ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f2f2f2"></span>
  /// Alpha: 100% <br/> (0xf2f2f2ff)
  static let clearGrayChat = ColorName(rgbaValue: 0xf2f2f2ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f5d0d7"></span>
  /// Alpha: 100% <br/> (0xf5d0d7ff)
  static let clearPink = ColorName(rgbaValue: 0xf5d0d7ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#666666"></span>
  /// Alpha: 100% <br/> (0x666666ff)
  static let darkGray = ColorName(rgbaValue: 0x666666ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#333333"></span>
  /// Alpha: 100% <br/> (0x333333ff)
  static let darkGrayWelcome = ColorName(rgbaValue: 0x333333ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#d41536"></span>
  /// Alpha: 100% <br/> (0xd41536ff)
  static let darkRed = ColorName(rgbaValue: 0xd41536ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#cccccc"></span>
  /// Alpha: 100% <br/> (0xccccccff)
  static let grayChatReceived = ColorName(rgbaValue: 0xccccccff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#333333"></span>
  /// Alpha: 100% <br/> (0x333333ff)
  static let grayChatSent = ColorName(rgbaValue: 0x333333ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#eea1af"></span>
  /// Alpha: 100% <br/> (0xeea1afff)
  static let redNew = ColorName(rgbaValue: 0xeea1afff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f6d0d7"></span>
  /// Alpha: 100% <br/> (0xf6d0d7ff)
  static let redNotifications = ColorName(rgbaValue: 0xf6d0d7ff)
}
// swiftlint:enable identifier_name line_length type_body_length

extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
