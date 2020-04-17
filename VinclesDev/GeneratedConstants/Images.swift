// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  enum AppRTC {
    static let audioOff = ImageAsset(name: "audioOff")
    static let audioOn = ImageAsset(name: "audioOn")
    static let hangup = ImageAsset(name: "hangup")
    static let icSwitchVideoBlack24dp = ImageAsset(name: "ic_switch_video_black_24dp")
    static let videoOff = ImageAsset(name: "videoOff")
    static let videoOn = ImageAsset(name: "videoOn")
  }
  enum Icons {
    enum Agenda {
      static let anteriorAgenda = ImageAsset(name: "AnteriorAgenda")
      static let anteriorAgendaHover = ImageAsset(name: "AnteriorAgenda_hover")
      static let checkmark = ImageAsset(name: "Checkmark")
      static let convidarAltres = ImageAsset(name: "Convidar_altres")
      static let convidarAtresHover = ImageAsset(name: "Convidar_atres_hover")
      static let crearCita = ImageAsset(name: "Crear_cita")
      static let editarCita = ImageAsset(name: "Editar_cita")
      static let novaCita = ImageAsset(name: "Nova_cita")
      static let novaCitaHover = ImageAsset(name: "Nova_cita_hover")
      static let seguentAgenda = ImageAsset(name: "SeguentAgenda")
      static let seguentAgendaHover = ImageAsset(name: "SeguentAgenda_hover")
      static let checkGreen = ImageAsset(name: "check_green")
      static let meetingBack = ImageAsset(name: "meetingBack")
    }
    enum Call {
      static let calling = ImageAsset(name: "calling")
      static let chat = ImageAsset(name: "chat")
      static let endcall = ImageAsset(name: "endcall")
    }
    enum Chat {
      static let enviar = ImageAsset(name: "Enviar")
      static let enviarInvitacio = ImageAsset(name: "EnviarInvitacio")
      static let trucar = ImageAsset(name: "Trucar")
      static let trucarHover = ImageAsset(name: "Trucar_hover")
      static let album = ImageAsset(name: "album")
      static let audio = ImageAsset(name: "audio")
      static let identificadorDinamitzador = ImageAsset(name: "identificador_dinamitzador")
      static let pause = ImageAsset(name: "pause")
      static let play = ImageAsset(name: "play")
      static let tancar = ImageAsset(name: "tancar")
      static let text = ImageAsset(name: "text")
    }
    enum Contactes {
      static let afegirContacte = ImageAsset(name: "Afegir_contacte")
      static let eliminarContacte = ImageAsset(name: "Eliminar_contacte")
      static let noEliminar = ImageAsset(name: "No_eliminar")
      static let veureCodi = ImageAsset(name: "Veure_codi")
    }
    enum Galeria {
      static let anterior = ImageAsset(name: "Anterior")
      static let anteriorHover = ImageAsset(name: "Anterior_hover")
      static let anteriorUltima = ImageAsset(name: "Anterior_ultima")
      static let compartir = ImageAsset(name: "Compartir")
      static let infoHora = ImageAsset(name: "Info_hora")
      static let nouVideo = ImageAsset(name: "Nou_video")
      static let seguent = ImageAsset(name: "Seguent")
      static let seguentHover = ImageAsset(name: "Seguent_hover")
      static let seguentUltima = ImageAsset(name: "Seguent_ultima")
      static let tornarNoCompartir = ImageAsset(name: "Tornar_no_compartir")
      static let video = ImageAsset(name: "Video")
      static let checkFiltre = ImageAsset(name: "check_filtre")
      static let download = ImageAsset(name: "download")
      static let downloadpetit = ImageAsset(name: "downloadpetit")
      static let eliminar = ImageAsset(name: "eliminar")
      static let filtrar = ImageAsset(name: "filtrar")
      static let novaFoto = ImageAsset(name: "nova_foto")
    }
    static let image1 = ImageAsset(name: "Image-1")
    static let image = ImageAsset(name: "Image")
    enum Menu {
      static let menuCalendari = ImageAsset(name: "menu_calendari")
      static let menuConfiguracio = ImageAsset(name: "menu_configuracio")
      static let menuGaleria = ImageAsset(name: "menu_galeria")
      static let menuInici = ImageAsset(name: "menu_inici")
      static let menuLogout = ImageAsset(name: "menu_logout")
      static let menuNotifications = ImageAsset(name: "menu_notifications")
      static let menuSobrevincles = ImageAsset(name: "menu_sobrevincles")
      static let menuXarxes = ImageAsset(name: "menu_xarxes")
    }
    enum Navigation {
      static let tornar = ImageAsset(name: "tornar")
      static let tornarHover = ImageAsset(name: "tornar_hover")
    }
    static let ajuda = ImageAsset(name: "ajuda")
    static let alert = ImageAsset(name: "alert")
    static let bell = ImageAsset(name: "bell")
    static let calendariIcon = ImageAsset(name: "calendari_icon")
    static let calnot = ImageAsset(name: "calnot")
    static let camara = ImageAsset(name: "camara")
    static let cancel = ImageAsset(name: "cancel")
    static let contactes = ImageAsset(name: "contactes")
    static let contactesnot = ImageAsset(name: "contactesnot")
    static let edit = ImageAsset(name: "edit")
    static let groups = ImageAsset(name: "groups")
    static let grupsnot = ImageAsset(name: "grupsnot")
    static let menu = ImageAsset(name: "menu")
    static let perfilplaceholder = ImageAsset(name: "perfilplaceholder")
    static let stop = ImageAsset(name: "stop")
    static let test = ImageAsset(name: "test")
    static let test2 = ImageAsset(name: "test2")
    static let triangleincoming = ImageAsset(name: "triangleincoming")
    static let triangleoutgoing = ImageAsset(name: "triangleoutgoing")
  }
  enum Logos {
    static let bloomberg = ImageAsset(name: "bloomberg")
    static let footerSplashscreen = ImageAsset(name: "footer-splashscreen")
    static let logoBarcelona = ImageAsset(name: "logo-barcelona")
    static let logoBig = ImageAsset(name: "logo-big")
    static let logoWhite = ImageAsset(name: "logo_white")
    static let logoabout = ImageAsset(name: "logoabout")
    static let navBarLogo = ImageAsset(name: "navBarLogo")
  }
  enum TestImages {
    static let homealbum = ImageAsset(name: "Homealbum")
    static let calendari = ImageAsset(name: "calendari")
    static let woman1138435640 = ImageAsset(name: "woman-1138435_640")
  }
  enum Tutorial {
    static let mobile1LandscapeCast = ImageAsset(name: "Mobile_1_landscape_cast")
    static let mobile1LandscapeCat = ImageAsset(name: "Mobile_1_landscape_cat")
    static let mobile1PortraitCast = ImageAsset(name: "Mobile_1_portrait_cast")
    static let mobile1PortraitCat = ImageAsset(name: "Mobile_1_portrait_cat")
    static let mobile2LandscapeCast = ImageAsset(name: "Mobile_2_landscape_cast")
    static let mobile2LandscapeCat = ImageAsset(name: "Mobile_2_landscape_cat")
    static let mobile2PortraitCast = ImageAsset(name: "Mobile_2_portrait_cast")
    static let mobile2PortraitCat = ImageAsset(name: "Mobile_2_portrait_cat")
    static let mobile3LandscapeCast = ImageAsset(name: "Mobile_3_landscape_cast")
    static let mobile3LandscapeCat = ImageAsset(name: "Mobile_3_landscape_cat")
    static let mobile3PortraitCast = ImageAsset(name: "Mobile_3_portrait_cast")
    static let mobile3PortraitCat = ImageAsset(name: "Mobile_3_portrait_cat")
    static let mobile4LandscapeCast = ImageAsset(name: "Mobile_4_landscape_cast")
    static let mobile4LandscapeCat = ImageAsset(name: "Mobile_4_landscape_cat")
    static let mobile4PortraitCast = ImageAsset(name: "Mobile_4_portrait_cast")
    static let mobile4PortraitCat = ImageAsset(name: "Mobile_4_portrait_cat")
    static let mobile5LandscapeCast = ImageAsset(name: "Mobile_5_landscape_cast")
    static let mobile5LandscapeCat = ImageAsset(name: "Mobile_5_landscape_cat")
    static let mobile5PortraitCast = ImageAsset(name: "Mobile_5_portrait_cast")
    static let mobile5PortraitCat = ImageAsset(name: "Mobile_5_portrait_cat")
    static let tablet1LandscapeCast = ImageAsset(name: "Tablet_1_landscape_cast")
    static let tablet1LandscapeCat = ImageAsset(name: "Tablet_1_landscape_cat")
    static let tablet1PortraitCast = ImageAsset(name: "Tablet_1_portrait_cast")
    static let tablet1PortraitCat = ImageAsset(name: "Tablet_1_portrait_cat")
    static let tablet2LandscapeCast = ImageAsset(name: "Tablet_2_landscape_cast")
    static let tablet2LandscapeCat = ImageAsset(name: "Tablet_2_landscape_cat")
    static let tablet2PortraitCast = ImageAsset(name: "Tablet_2_portrait_cast")
    static let tablet2PortraitCat = ImageAsset(name: "Tablet_2_portrait_cat")
    static let tablet3LandscapeCast = ImageAsset(name: "Tablet_3_landscape_cast")
    static let tablet3LandscapeCat = ImageAsset(name: "Tablet_3_landscape_cat")
    static let tablet3PortraitCast = ImageAsset(name: "Tablet_3_portrait_cast")
    static let tablet3PortraitCat = ImageAsset(name: "Tablet_3_portrait_cat")
    static let tablet4LandscapeCast = ImageAsset(name: "Tablet_4_landscape_cast")
    static let tablet4LandscapeCat = ImageAsset(name: "Tablet_4_landscape_cat")
    static let tablet4PortraitCast = ImageAsset(name: "Tablet_4_portrait_cast")
    static let tablet4PortraitCat = ImageAsset(name: "Tablet_4_portrait_cat")
    static let tablet5LandscapeCast = ImageAsset(name: "Tablet_5_landscape_cast")
    static let tablet5LandscapeCat = ImageAsset(name: "Tablet_5_landscape_cat")
    static let tablet5PortraitCast = ImageAsset(name: "Tablet_5_portrait_cast")
    static let tablet5PortraitCat = ImageAsset(name: "Tablet_5_portrait_cat")
  }
  static let photoCircle = ImageAsset(name: "photo-circle")
  static let test4 = ImageAsset(name: "test4")

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    AppRTC.audioOff,
    AppRTC.audioOn,
    AppRTC.hangup,
    AppRTC.icSwitchVideoBlack24dp,
    AppRTC.videoOff,
    AppRTC.videoOn,
    Icons.Agenda.anteriorAgenda,
    Icons.Agenda.anteriorAgendaHover,
    Icons.Agenda.checkmark,
    Icons.Agenda.convidarAltres,
    Icons.Agenda.convidarAtresHover,
    Icons.Agenda.crearCita,
    Icons.Agenda.editarCita,
    Icons.Agenda.novaCita,
    Icons.Agenda.novaCitaHover,
    Icons.Agenda.seguentAgenda,
    Icons.Agenda.seguentAgendaHover,
    Icons.Agenda.checkGreen,
    Icons.Agenda.meetingBack,
    Icons.Call.calling,
    Icons.Call.chat,
    Icons.Call.endcall,
    Icons.Chat.enviar,
    Icons.Chat.enviarInvitacio,
    Icons.Chat.trucar,
    Icons.Chat.trucarHover,
    Icons.Chat.album,
    Icons.Chat.audio,
    Icons.Chat.identificadorDinamitzador,
    Icons.Chat.pause,
    Icons.Chat.play,
    Icons.Chat.tancar,
    Icons.Chat.text,
    Icons.Contactes.afegirContacte,
    Icons.Contactes.eliminarContacte,
    Icons.Contactes.noEliminar,
    Icons.Contactes.veureCodi,
    Icons.Galeria.anterior,
    Icons.Galeria.anteriorHover,
    Icons.Galeria.anteriorUltima,
    Icons.Galeria.compartir,
    Icons.Galeria.infoHora,
    Icons.Galeria.nouVideo,
    Icons.Galeria.seguent,
    Icons.Galeria.seguentHover,
    Icons.Galeria.seguentUltima,
    Icons.Galeria.tornarNoCompartir,
    Icons.Galeria.video,
    Icons.Galeria.checkFiltre,
    Icons.Galeria.download,
    Icons.Galeria.downloadpetit,
    Icons.Galeria.eliminar,
    Icons.Galeria.filtrar,
    Icons.Galeria.novaFoto,
    Icons.image1,
    Icons.image,
    Icons.Menu.menuCalendari,
    Icons.Menu.menuConfiguracio,
    Icons.Menu.menuGaleria,
    Icons.Menu.menuInici,
    Icons.Menu.menuLogout,
    Icons.Menu.menuNotifications,
    Icons.Menu.menuSobrevincles,
    Icons.Menu.menuXarxes,
    Icons.Navigation.tornar,
    Icons.Navigation.tornarHover,
    Icons.ajuda,
    Icons.alert,
    Icons.bell,
    Icons.calendariIcon,
    Icons.calnot,
    Icons.camara,
    Icons.cancel,
    Icons.contactes,
    Icons.contactesnot,
    Icons.edit,
    Icons.groups,
    Icons.grupsnot,
    Icons.menu,
    Icons.perfilplaceholder,
    Icons.stop,
    Icons.test,
    Icons.test2,
    Icons.triangleincoming,
    Icons.triangleoutgoing,
    Logos.bloomberg,
    Logos.footerSplashscreen,
    Logos.logoBarcelona,
    Logos.logoBig,
    Logos.logoWhite,
    Logos.logoabout,
    Logos.navBarLogo,
    TestImages.homealbum,
    TestImages.calendari,
    TestImages.woman1138435640,
    Tutorial.mobile1LandscapeCast,
    Tutorial.mobile1LandscapeCat,
    Tutorial.mobile1PortraitCast,
    Tutorial.mobile1PortraitCat,
    Tutorial.mobile2LandscapeCast,
    Tutorial.mobile2LandscapeCat,
    Tutorial.mobile2PortraitCast,
    Tutorial.mobile2PortraitCat,
    Tutorial.mobile3LandscapeCast,
    Tutorial.mobile3LandscapeCat,
    Tutorial.mobile3PortraitCast,
    Tutorial.mobile3PortraitCat,
    Tutorial.mobile4LandscapeCast,
    Tutorial.mobile4LandscapeCat,
    Tutorial.mobile4PortraitCast,
    Tutorial.mobile4PortraitCat,
    Tutorial.mobile5LandscapeCast,
    Tutorial.mobile5LandscapeCat,
    Tutorial.mobile5PortraitCast,
    Tutorial.mobile5PortraitCat,
    Tutorial.tablet1LandscapeCast,
    Tutorial.tablet1LandscapeCat,
    Tutorial.tablet1PortraitCast,
    Tutorial.tablet1PortraitCat,
    Tutorial.tablet2LandscapeCast,
    Tutorial.tablet2LandscapeCat,
    Tutorial.tablet2PortraitCast,
    Tutorial.tablet2PortraitCat,
    Tutorial.tablet3LandscapeCast,
    Tutorial.tablet3LandscapeCat,
    Tutorial.tablet3PortraitCast,
    Tutorial.tablet3PortraitCat,
    Tutorial.tablet4LandscapeCast,
    Tutorial.tablet4LandscapeCat,
    Tutorial.tablet4PortraitCast,
    Tutorial.tablet4PortraitCat,
    Tutorial.tablet5LandscapeCast,
    Tutorial.tablet5LandscapeCat,
    Tutorial.tablet5PortraitCast,
    Tutorial.tablet5PortraitCat,
    photoCircle,
    test4,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
