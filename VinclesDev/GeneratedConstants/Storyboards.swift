// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum About: StoryboardType {
    static let storyboardName = "About"

    static let aboutViewController = SceneType<VinclesDev.AboutViewController>(storyboard: About.self, identifier: "AboutViewController")
  }
  enum Agenda: StoryboardType {
    static let storyboardName = "Agenda"

    static let agendaContactsViewController = SceneType<VinclesDev.AgendaContactsViewController>(storyboard: Agenda.self, identifier: "AgendaContactsViewController")

    static let agendaContainerViewController = SceneType<VinclesDev.AgendaContainerViewController>(storyboard: Agenda.self, identifier: "AgendaContainerViewController")

    static let agendaEventDetailViewController = SceneType<VinclesDev.AgendaEventDetailViewController>(storyboard: Agenda.self, identifier: "AgendaEventDetailViewController")

    static let agendaMonthViewController = SceneType<VinclesDev.AgendaMonthViewController>(storyboard: Agenda.self, identifier: "AgendaMonthViewController")

    static let newScheduleViewController = SceneType<VinclesDev.NewScheduleViewController>(storyboard: Agenda.self, identifier: "NewScheduleViewController")

    static let ndaDayViewController = SceneType<VinclesDev.AgendaDayViewController>(storyboard: Agenda.self, identifier: "ndaDayViewController")
  }
  enum Auth: StoryboardType {
    static let storyboardName = "Auth"

    static let initialScene = InitialSceneType<VinclesDev.LoginViewController>(storyboard: Auth.self)

    static let forgotPasswordViewController = SceneType<VinclesDev.ForgotPasswordViewController>(storyboard: Auth.self, identifier: "ForgotPasswordViewController")

    static let loginViewController = SceneType<VinclesDev.LoginViewController>(storyboard: Auth.self, identifier: "LoginViewController")

    static let loginViewController2 = SceneType<VinclesDev.LoginViewController>(storyboard: Auth.self, identifier: "LoginViewController2")

    static let registerValidateViewController = SceneType<VinclesDev.RegisterValidateViewController>(storyboard: Auth.self, identifier: "RegisterValidateViewController")

    static let registerViewController = SceneType<VinclesDev.RegisterViewController>(storyboard: Auth.self, identifier: "RegisterViewController")

    static let termsConditionsViewController = SceneType<VinclesDev.TermsConditionsViewController>(storyboard: Auth.self, identifier: "TermsConditionsViewController")
  }
  enum Base: StoryboardType {
    static let storyboardName = "Base"

    static let baseViewController = SceneType<VinclesDev.BaseViewController>(storyboard: Base.self, identifier: "BaseViewController")
  }
  enum Call: StoryboardType {
    static let storyboardName = "Call"

    static let callViewController = SceneType<VinclesDev.CallViewController>(storyboard: Call.self, identifier: "CallViewController")

    static let incomingCallViewController = SceneType<VinclesDev.IncomingCallViewController>(storyboard: Call.self, identifier: "IncomingCallViewController")

    static let outgoingCallViewController = SceneType<VinclesDev.OutgoingCallViewController>(storyboard: Call.self, identifier: "OutgoingCallViewController")
  }
  enum Chat: StoryboardType {
    static let storyboardName = "Chat"

    static let chatContainerViewController = SceneType<VinclesDev.ChatContainerViewController>(storyboard: Chat.self, identifier: "ChatContainerViewController")

    static let groupInfoViewController = SceneType<VinclesDev.GroupInfoViewController>(storyboard: Chat.self, identifier: "GroupInfoViewController")
  }
  enum Configuracio: StoryboardType {
    static let storyboardName = "Configuracio"

    static let configMainViewController = SceneType<VinclesDev.ConfigMainViewController>(storyboard: Configuracio.self, identifier: "ConfigMainViewController")

    static let configPersonalDataViewController = SceneType<VinclesDev.ConfigPersonalDataViewController>(storyboard: Configuracio.self, identifier: "ConfigPersonalDataViewController")
  }
  enum Contacts: StoryboardType {
    static let storyboardName = "Contacts"

    static let addContactViewController = SceneType<VinclesDev.AddContactViewController>(storyboard: Contacts.self, identifier: "AddContactViewController")

    static let contactsViewController = SceneType<VinclesDev.ContactsViewController>(storyboard: Contacts.self, identifier: "ContactsViewController")

    static let dropDownViewController = SceneType<VinclesDev.DropDownViewController>(storyboard: Contacts.self, identifier: "DropDownViewController")
  }
  enum Gallery: StoryboardType {
    static let storyboardName = "Gallery"

    static let galleryCompartirContactsViewController = SceneType<VinclesDev.GalleryCompartirContactsViewController>(storyboard: Gallery.self, identifier: "GalleryCompartirContactsViewController")

    static let galleryDetailViewController = SceneType<VinclesDev.GalleryDetailViewController>(storyboard: Gallery.self, identifier: "GalleryDetailViewController")

    static let gallerySwipeViewController = SceneType<VinclesDev.GallerySwipeViewController>(storyboard: Gallery.self, identifier: "GallerySwipeViewController")

    static let galleryViewController = SceneType<VinclesDev.GalleryViewController>(storyboard: Gallery.self, identifier: "GalleryViewController")
  }
  enum LaunchScreen: StoryboardType {
    static let storyboardName = "LaunchScreen"

    static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let homeViewController = SceneType<VinclesDev.HomeViewController>(storyboard: Main.self, identifier: "HomeViewController")
  }
  enum Menu: StoryboardType {
    static let storyboardName = "Menu"

    static let leftMenuTableViewController = SceneType<VinclesDev.LeftMenuTableViewController>(storyboard: Menu.self, identifier: "LeftMenuTableViewController")
  }
  enum Notifications: StoryboardType {
    static let storyboardName = "Notifications"

    static let notificationsViewController = SceneType<VinclesDev.NotificationsViewController>(storyboard: Notifications.self, identifier: "NotificationsViewController")
  }
  enum Popup: StoryboardType {
    static let storyboardName = "Popup"

    static let popupViewController = SceneType<VinclesDev.PopupViewController>(storyboard: Popup.self, identifier: "PopupViewController")
  }
  enum Splash: StoryboardType {
    static let storyboardName = "Splash"

    static let splashScreenViewController = SceneType<VinclesDev.SplashScreenViewController>(storyboard: Splash.self, identifier: "SplashScreenViewController")
  }
  enum Tutorial: StoryboardType {
    static let storyboardName = "Tutorial"

    static let tutorialViewController = SceneType<VinclesDev.TutorialViewController>(storyboard: Tutorial.self, identifier: "TutorialViewController")
  }
}

enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
