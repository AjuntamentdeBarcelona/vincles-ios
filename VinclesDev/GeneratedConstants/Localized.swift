// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  /// La teva sol.licitud de contacte s'ha enviat correctament
  static var afegirContacteDesc : String { return  L10n.tr("Localizable", "AfegirContacteDesc") }
  /// Sol.licitud de contacte
  static var afegirContacteTitol : String { return  L10n.tr("Localizable", "AfegirContacteTitol") }
  /// Avui, 
  static var agendaAvui : String { return  L10n.tr("Localizable", "AgendaAvui") }
  /// Demà, 
  static var agendaDema : String { return  L10n.tr("Localizable", "AgendaDema") }
  /// DIU
  static var agendaDomingo : String { return  L10n.tr("Localizable", "AgendaDomingo") }
  /// Veure avui
  static var agendaHoy : String { return  L10n.tr("Localizable", "AgendaHoy") }
  /// DIJ
  static var agendaJueves : String { return  L10n.tr("Localizable", "AgendaJueves") }
  /// DIL
  static var agendaLunes : String { return  L10n.tr("Localizable", "AgendaLunes") }
  /// Veure demà
  static var agendaManana : String { return  L10n.tr("Localizable", "AgendaManana") }
  /// DIM
  static var agendaMartes : String { return  L10n.tr("Localizable", "AgendaMartes") }
  /// Veure mes sencer
  static var agendaMes : String { return  L10n.tr("Localizable", "AgendaMes") }
  /// DX
  static var agendaMiercoles : String { return  L10n.tr("Localizable", "AgendaMiercoles") }
  /// Crear nova cita
  static var agendaNuevaCita : String { return  L10n.tr("Localizable", "AgendaNuevaCita") }
  /// DIS
  static var agendaSabado : String { return  L10n.tr("Localizable", "AgendaSabado") }
  /// DIV
  static var agendaViernes : String { return  L10n.tr("Localizable", "AgendaViernes") }
  /// Has de tenir 14 anys com a mínim per poder registrat-te
  static var ageRequired : String { return  L10n.tr("Localizable", "AgeRequired") }
  /// Vincles BCN
  static var appName : String { return  L10n.tr("Localizable", "AppName") }
  /// Avisos
  static var avisos : String { return  L10n.tr("Localizable", "Avisos") }
  /// Ajuda
  static var ayuda : String { return  L10n.tr("Localizable", "Ayuda") }
  /// La bateria està al %@
  static func batteryLow(_ p1: String) -> String {
    return L10n.tr("Localizable", "BatteryLow", p1)
  }
  /// Calendari
  static var calendario : String { return  L10n.tr("Localizable", "Calendario") }
  /// Rebutjar
  static var callCancel : String { return  L10n.tr("Localizable", "CallCancel") }
  /// No es pot establir la trucada, si us plau, torni a intentar-ho
  static var callConnection : String { return  L10n.tr("Localizable", "CallConnection") }
  /// Penjar
  static var callEnd : String { return  L10n.tr("Localizable", "CallEnd") }
  /// Trucada de
  static var callFrom : String { return  L10n.tr("Localizable", "CallFrom") }
  /// Despenjar
  static var callGet : String { return  L10n.tr("Localizable", "CallGet") }
  /// Trucant a
  static var calling : String { return  L10n.tr("Localizable", "Calling") }
  /// Enviar missatge
  static var callMessage : String { return  L10n.tr("Localizable", "CallMessage") }
  /// Enviar\nmissatge
  static var callMessagePhone : String { return  L10n.tr("Localizable", "CallMessagePhone") }
  /// no està disponible
  static var callNoContesta : String { return  L10n.tr("Localizable", "CallNoContesta") }
  /// Reintentar
  static var callRetry : String { return  L10n.tr("Localizable", "CallRetry") }
  /// Cancel·lar
  static var cancelar : String { return  L10n.tr("Localizable", "Cancelar") }
  /// Carregant
  static var cargando : String { return  L10n.tr("Localizable", "Cargando") }
  /// Àudio
  static var chatAudio : String { return  L10n.tr("Localizable", "ChatAudio") }
  /// Ahir
  static var chatAyer : String { return  L10n.tr("Localizable", "ChatAyer") }
  /// Enviar
  static var chatEnviar : String { return  L10n.tr("Localizable", "ChatEnviar") }
  /// No pots enregistrar sense donar el pemís.
  static var chatErrorGrabacio : String { return  L10n.tr("Localizable", "ChatErrorGrabacio") }
  /// Ha succeït un error al enviar l'àudio. Vol tornar a intentar-ho?
  static var chatErrorSubirAudio : String { return  L10n.tr("Localizable", "ChatErrorSubirAudio") }
  /// Ha succeït un error al enviar la imatge. Vol tornar a intentar-ho?
  static var chatErrorSubirImagen : String { return  L10n.tr("Localizable", "ChatErrorSubirImagen") }
  /// Ha succeït un error al enviar el text. Vol tornar a intentar-ho?
  static var chatErrorSubirTexto : String { return  L10n.tr("Localizable", "ChatErrorSubirTexto") }
  /// Ha succeït un error al enviar el vídeo. Vol tornar a intentar-ho?
  static var chatErrorSubirVideo : String { return  L10n.tr("Localizable", "ChatErrorSubirVideo") }
  /// Foto
  static var chatFoto : String { return  L10n.tr("Localizable", "ChatFoto") }
  /// Triar\nde l'àlbum
  static var chatGaleria : String { return  L10n.tr("Localizable", "ChatGaleria") }
  /// Enregistrant
  static var chatGrabando : String { return  L10n.tr("Localizable", "ChatGrabando") }
  /// Avui
  static var chatHoy : String { return  L10n.tr("Localizable", "ChatHoy") }
  /// %@ %@ t'ha trucat el %@ a les %@
  static func chatNotification(_ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
    return L10n.tr("Localizable", "ChatNotification", p1, p2, p3, p4)
  }
  /// Missatges no llegits
  static var chatNuevosMensajes : String { return  L10n.tr("Localizable", "ChatNuevosMensajes") }
  /// Escriu aquí el teu text
  static var chatPlaceholder : String { return  L10n.tr("Localizable", "ChatPlaceholder") }
  /// Nou missatge d'àudio
  static var chatPushAudio : String { return  L10n.tr("Localizable", "ChatPushAudio") }
  /// Nova imatge
  static var chatPushImagen : String { return  L10n.tr("Localizable", "ChatPushImagen") }
  /// Nous items compartits
  static var chatPushItems : String { return  L10n.tr("Localizable", "ChatPushItems") }
  /// Nou vídeo
  static var chatPushVideo : String { return  L10n.tr("Localizable", "ChatPushVideo") }
  /// Cancel.lar
  static var chatSortirAudio : String { return  L10n.tr("Localizable", "ChatSortirAudio") }
  /// Sortir de text
  static var chatSortirText : String { return  L10n.tr("Localizable", "ChatSortirText") }
  /// Text
  static var chatText : String { return  L10n.tr("Localizable", "ChatText") }
  /// Tu
  static var chatTu : String { return  L10n.tr("Localizable", "ChatTu") }
  /// Vídeo
  static var chatVideo : String { return  L10n.tr("Localizable", "ChatVideo") }
  /// Acceptar la cita
  static var citaAccepta : String { return  L10n.tr("Localizable", "CitaAccepta") }
  /// Acceptar
  static var citaAcceptaPhone : String { return  L10n.tr("Localizable", "CitaAcceptaPhone") }
  /// Cancel·la la cita
  static var citaCancela : String { return  L10n.tr("Localizable", "CitaCancela") }
  /// Cancel·la
  static var citaCancelaPhone : String { return  L10n.tr("Localizable", "CitaCancelaPhone") }
  /// Rebutjar
  static var citaCitaRebutjarPhone : String { return  L10n.tr("Localizable", "CitaCitaRebutjarPhone") }
  /// Cita creada per: 
  static var citaCreadaPer : String { return  L10n.tr("Localizable", "CitaCreadaPer") }
  /// Tu
  static var citaCreadaTi : String { return  L10n.tr("Localizable", "CitaCreadaTi") }
  /// Assistirà
  static var citaDescAssistira : String { return  L10n.tr("Localizable", "CitaDescAssistira") }
  /// Convidat
  static var citaDescConvidat : String { return  L10n.tr("Localizable", "CitaDescConvidat") }
  /// No assistirà
  static var citaDescNoAssistira : String { return  L10n.tr("Localizable", "CitaDescNoAssistira") }
  /// Convidats
  static var citaDetallConvidats : String { return  L10n.tr("Localizable", "CitaDetallConvidats") }
  /// Data i hora
  static var citaDetallDataHora : String { return  L10n.tr("Localizable", "CitaDetallDataHora") }
  /// Detalls de la cita
  static var citaDetallDetallCita : String { return  L10n.tr("Localizable", "CitaDetallDetallCita") }
  /// Edita la cita
  static var citaEdita : String { return  L10n.tr("Localizable", "CitaEdita") }
  /// Edita
  static var citaEditaPhone : String { return  L10n.tr("Localizable", "CitaEditaPhone") }
  /// Ha succeït un error al eliminar la cita. Vol tornar a intentar-ho?
  static var citaEliminarError : String { return  L10n.tr("Localizable", "CitaEliminarError") }
  /// Eliminar
  static var citaEliminarPopUpTitle : String { return  L10n.tr("Localizable", "CitaEliminarPopUpTitle") }
  /// Ha succeït un error al guardar la cita. Vol tornar a intentar-ho?
  static var citaGuardarError : String { return  L10n.tr("Localizable", "CitaGuardarError") }
  /// No assistiré
  static var citaNoAsistire : String { return  L10n.tr("Localizable", "CitaNoAsistire") }
  /// Participants: 
  static var citaParticipants : String { return  L10n.tr("Localizable", "CitaParticipants") }
  /// Durada
  static var citaPopUpDurada : String { return  L10n.tr("Localizable", "CitaPopUpDurada") }
  /// Segur que vol eliminar la cita?
  static var citaPopUpEliminar : String { return  L10n.tr("Localizable", "CitaPopUpEliminar") }
  /// minuts
  static var citaPopUpMinutos : String { return  L10n.tr("Localizable", "CitaPopUpMinutos") }
  /// Segur que vol rebutjar la cita?
  static var citaPopUpRechazar : String { return  L10n.tr("Localizable", "CitaPopUpRechazar") }
  /// Rebutjar la cita
  static var citaRebutjar : String { return  L10n.tr("Localizable", "CitaRebutjar") }
  /// Rebutjar
  static var citaRebutjarPopUpTitle : String { return  L10n.tr("Localizable", "CitaRebutjarPopUpTitle") }
  /// Recordatori
  static var citaRecordatori : String { return  L10n.tr("Localizable", "CitaRecordatori") }
  /// No tens cites programades per aquest dia
  static var citesNo : String { return  L10n.tr("Localizable", "CitesNo") }
  /// Descàrrega automàtica d’arxius
  static var condifuracioDescarrega : String { return  L10n.tr("Localizable", "CondifuracioDescarrega") }
  /// Ha succeït un error al guardar les dades. Vol tornar a intentar-ho?
  static var configGuardarError : String { return  L10n.tr("Localizable", "ConfigGuardarError") }
  /// Configuració
  static var configuracio : String { return  L10n.tr("Localizable", "Configuracio") }
  /// Nom d'usuari
  static var configuracioAlias : String { return  L10n.tr("Localizable", "ConfiguracioAlias") }
  /// Contrasenya actual
  static var configuracioContrasenyaActual : String { return  L10n.tr("Localizable", "ConfiguracioContrasenyaActual") }
  /// Les contrasenyes no coincideixen
  static var configuracioContrasenyaNoCoincideixen : String { return  L10n.tr("Localizable", "ConfiguracioContrasenyaNoCoincideixen") }
  /// Si us plau, escriu la teva contrasenya actual al camp pertinent
  static var configuracioFaltaContrasenyaActual : String { return  L10n.tr("Localizable", "ConfiguracioFaltaContrasenyaActual") }
  /// Copiar imatges i videos a la galeria del dispositiu
  static var configuracioGaleria : String { return  L10n.tr("Localizable", "ConfiguracioGaleria") }
  /// Configuració
  static var configuracion : String { return  L10n.tr("Localizable", "Configuracion") }
  /// Resident fora de Barcelona
  static var configuracioNoResident : String { return  L10n.tr("Localizable", "ConfiguracioNoResident") }
  /// Nova contrasenya
  static var configuracioNovaContrasenya : String { return  L10n.tr("Localizable", "ConfiguracioNovaContrasenya") }
  /// Repeteix la contrasenya
  static var configuracioRepeteixContrasenya : String { return  L10n.tr("Localizable", "ConfiguracioRepeteixContrasenya") }
  /// Resident a Barcelona
  static var configuracioResident : String { return  L10n.tr("Localizable", "ConfiguracioResident") }
  /// Sincronitzar cites amb el calendari del mòbil
  static var configuracioSincronitzar : String { return  L10n.tr("Localizable", "ConfiguracioSincronitzar") }
  /// Mida de la lletra
  static var configuracioTamany : String { return  L10n.tr("Localizable", "ConfiguracioTamany") }
  /// Gran
  static var configuracioTamanyGran : String { return  L10n.tr("Localizable", "ConfiguracioTamanyGran") }
  /// Guardar
  static var configuracioTamanyGuardar : String { return  L10n.tr("Localizable", "ConfiguracioTamanyGuardar") }
  /// Mitjana
  static var configuracioTamanyMitja : String { return  L10n.tr("Localizable", "ConfiguracioTamanyMitja") }
  /// Petita
  static var configuracioTamanyPetit : String { return  L10n.tr("Localizable", "ConfiguracioTamanyPetit") }
  /// L'usuari 
  static var contacteAfegit1 : String { return  L10n.tr("Localizable", "ContacteAfegit1") }
  ///  ha estat afegit correctament
  static var contacteAfegit2 : String { return  L10n.tr("Localizable", "ContacteAfegit2") }
  /// Contacte afegit
  static var contacteAfegitTitle : String { return  L10n.tr("Localizable", "ContacteAfegitTitle") }
  /// Eliminar contacte
  static var contacteEliminar : String { return  L10n.tr("Localizable", "ContacteEliminar") }
  /// Contactes
  static var contactos : String { return  L10n.tr("Localizable", "Contactos") }
  /// No afegir i tornar a contactes
  static var contactsAfegirCancelar : String { return  L10n.tr("Localizable", "ContactsAfegirCancelar") }
  /// Vull veure el meu codi de vinculació perquè un altre contacte m'afegeixi
  static var contactsAfegirCodi : String { return  L10n.tr("Localizable", "ContactsAfegirCodi") }
  /// Afegir contacte
  static var contactsAfegirContacte : String { return  L10n.tr("Localizable", "ContactsAfegirContacte") }
  /// Escriu aquí el codi
  static var contactsAfegirEscriuCodi : String { return  L10n.tr("Localizable", "ContactsAfegirEscriuCodi") }
  ///  Relación
  static var contactsAfegirRelacionButton : String { return  L10n.tr("Localizable", "ContactsAfegirRelacionButton") }
  /// Por favor, seleccione la relación de parentesco.
  static var contactsAfegirRelacionError : String { return  L10n.tr("Localizable", "ContactsAfegirRelacionError") }
  /// Opciones
  static var contactsAfegirRelacionOptionTitle : String { return  L10n.tr("Localizable", "ContactsAfegirRelacionOptionTitle") }
  /// Tengo el código de vinculación de otro usuario y el quiero añadir (incluya, por favor, la relación de parentesco)
  static var contactsAfegirTincCodi : String { return  L10n.tr("Localizable", "ContactsAfegirTincCodi") }
  /// Veure el meu codi
  static var contactsAfegirVeureCodiButton : String { return  L10n.tr("Localizable", "ContactsAfegirVeureCodiButton") }
  /// No vull eliminar cap contacte
  static var contactsCancelar : String { return  L10n.tr("Localizable", "ContactsCancelar") }
  /// Veure els dinamitzadors
  static var contactsFilterVerDinamizadores : String { return  L10n.tr("Localizable", "ContactsFilterVerDinamizadores") }
  /// Veure grups Vincles
  static var contactsFilterVerGrupos : String { return  L10n.tr("Localizable", "ContactsFilterVerGrupos") }
  /// Veure tots els contactes
  static var contactsFilterVerTodos : String { return  L10n.tr("Localizable", "ContactsFilterVerTodos") }
  /// Dinamitzadors
  static var contactsFiltradoDinamizadores : String { return  L10n.tr("Localizable", "ContactsFiltradoDinamizadores") }
  /// Família i amics
  static var contactsFiltradoFamilia : String { return  L10n.tr("Localizable", "ContactsFiltradoFamilia") }
  /// Grups Vincles
  static var contactsFiltradoGrupos : String { return  L10n.tr("Localizable", "ContactsFiltradoGrupos") }
  /// Tots els contactes
  static var contactsFiltradoTodos : String { return  L10n.tr("Localizable", "ContactsFiltradoTodos") }
  /// Veure família i amics
  static var contactsVerFamilia : String { return  L10n.tr("Localizable", "ContactsVerFamilia") }
  /// Convidar a altres contactes a la cita
  static var convidarCita : String { return  L10n.tr("Localizable", "ConvidarCita") }
  /// Convidar-los a la cita
  static var convidarCitaAcceptar : String { return  L10n.tr("Localizable", "ConvidarCitaAcceptar") }
  /// Tornar i no convidar
  static var convidarCitaCancelar : String { return  L10n.tr("Localizable", "ConvidarCitaCancelar") }
  /// Clica els contactes que vulguis convidar a la cita
  static var convidarCitaContactes : String { return  L10n.tr("Localizable", "ConvidarCitaContactes") }
  /// Deixar de\nconvidar
  static var convidarCitaDeixar : String { return  L10n.tr("Localizable", "ConvidarCitaDeixar") }
  /// Crear la cita
  static var crearCita : String { return  L10n.tr("Localizable", "CrearCita") }
  /// Les contrasenyes no coincideixen
  static var differentPasswords : String { return  L10n.tr("Localizable", "DifferentPasswords") }
  /// Durada de la cita
  static var duracionCita : String { return  L10n.tr("Localizable", "DuracionCita") }
  /// 2 hores
  static var duracionDosHoras : String { return  L10n.tr("Localizable", "DuracionDosHoras") }
  /// 1 hora 30 minuts
  static var duracionHoraMedia : String { return  L10n.tr("Localizable", "DuracionHoraMedia") }
  /// 30 minuts
  static var duracionMediaHora : String { return  L10n.tr("Localizable", "DuracionMediaHora") }
  /// 1 hora
  static var duracionUnaHora : String { return  L10n.tr("Localizable", "DuracionUnaHora") }
  /// Editar la cita
  static var editarLaCita : String { return  L10n.tr("Localizable", "EditarLaCita") }
  /// No. Tornar i no eliminar
  static var eliminarPopupButton1 : String { return  L10n.tr("Localizable", "EliminarPopupButton1") }
  /// Sí. Eliminar contacte
  static var eliminarPopupButton2 : String { return  L10n.tr("Localizable", "EliminarPopupButton2") }
  /// Estàs a punt d'eliminar a 
  static var eliminarPopupDesc1 : String { return  L10n.tr("Localizable", "EliminarPopupDesc1") }
  ///  de la teva xarxa de contactes. N'estàs segur?
  static var eliminarPopupDesc2 : String { return  L10n.tr("Localizable", "EliminarPopupDesc2") }
  /// Eliminar contacte
  static var eliminarPopupTitle : String { return  L10n.tr("Localizable", "EliminarPopupTitle") }
  /// Reintentar eliminar contacte
  static var eliminarPopupTitleReintentar : String { return  L10n.tr("Localizable", "EliminarPopupTitleReintentar") }
  /// L’usuari no pot accedir a aquest contingut
  static var error1001 : String { return  L10n.tr("Localizable", "Error1001") }
  /// L’usuari no pot accedir a les dades d’aquest altre usuari
  static var error1002 : String { return  L10n.tr("Localizable", "Error1002") }
  /// No s’ha pogut generar el contrasenya.
  static var error1003 : String { return  L10n.tr("Localizable", "Error1003") }
  /// Format de contrasenya incorrecte. La contrasenya ha de tenir entre 8 i 16 caràcters, un format alfanumèric i pot incloure els següents caràcters:  _!&%$-@
  static var error1004 : String { return  L10n.tr("Localizable", "Error1004") }
  /// El contrasenya s’ha fet servir amb anterioritat i no es pot tornar a fer servir.
  static var error1005 : String { return  L10n.tr("Localizable", "Error1005") }
  /// Contrasenya incorrecta
  static var error1006 : String { return  L10n.tr("Localizable", "Error1006") }
  /// Usuari no trobat
  static var error1101 : String { return  L10n.tr("Localizable", "Error1101") }
  /// L’usuari no és un usuari vincles
  static var error1102 : String { return  L10n.tr("Localizable", "Error1102") }
  /// L’usuari no pot ser un usuari vincles
  static var error1103 : String { return  L10n.tr("Localizable", "Error1103") }
  /// Un usuari no pot ser vincles i vinculat a la vegada
  static var error1106 : String { return  L10n.tr("Localizable", "Error1106") }
  /// L’usuari ha de ser vinculat
  static var error1107 : String { return  L10n.tr("Localizable", "Error1107") }
  /// L’usuari no pot ser un usuari vinculat
  static var error1108 : String { return  L10n.tr("Localizable", "Error1108") }
  /// L’usuari no és manager
  static var error1109 : String { return  L10n.tr("Localizable", "Error1109") }
  /// El email es troba en ús
  static var error1110 : String { return  L10n.tr("Localizable", "Error1110") }
  /// El dni/nie es troba en ús
  static var error1111 : String { return  L10n.tr("Localizable", "Error1111") }
  /// El nom d’usuari es troba en ús
  static var error1112 : String { return  L10n.tr("Localizable", "Error1112") }
  /// El telèfon és obligatori
  static var error1113 : String { return  L10n.tr("Localizable", "Error1113") }
  /// Els usuaris han de ser majors de 14 anys
  static var error1114 : String { return  L10n.tr("Localizable", "Error1114") }
  /// El codi de registre és invàlid
  static var error1301 : String { return  L10n.tr("Localizable", "Error1301") }
  /// El codi de registre ha caducat
  static var error1302 : String { return  L10n.tr("Localizable", "Error1302") }
  /// Cercle no trobat
  static var error1310 : String { return  L10n.tr("Localizable", "Error1310") }
  /// L’usuari no és part del cercle
  static var error1320 : String { return  L10n.tr("Localizable", "Error1320") }
  /// L’usuari ja està en aquest cercle
  static var error1321 : String { return  L10n.tr("Localizable", "Error1321") }
  /// Un usuari no es pot afegit al seu propi cercle
  static var error1322 : String { return  L10n.tr("Localizable", "Error1322") }
  /// Contingut no trobat
  static var error1401 : String { return  L10n.tr("Localizable", "Error1401") }
  /// Només el propietari d’un contingut el pot eliminar
  static var error1402 : String { return  L10n.tr("Localizable", "Error1402") }
  /// El contingut no es troba a la biblioteca
  static var error1501 : String { return  L10n.tr("Localizable", "Error1501") }
  /// L’usuari no pot enviar aquest missatge
  static var error1601 : String { return  L10n.tr("Localizable", "Error1601") }
  /// Els missatges només es poden enviar entre usuaris vincles i usuaris vinculats del mateix cercle
  static var error1602 : String { return  L10n.tr("Localizable", "Error1602") }
  /// Els missatges han de tenir text o tenir un o més adjunts
  static var error1603 : String { return  L10n.tr("Localizable", "Error1603") }
  /// Missatge no trobat
  static var error1604 : String { return  L10n.tr("Localizable", "Error1604") }
  /// L’usuari no pot accedir a aquest missatge
  static var error1605 : String { return  L10n.tr("Localizable", "Error1605") }
  /// Només el receptor del missatge el pot marcar com a llegit
  static var error1606 : String { return  L10n.tr("Localizable", "Error1606") }
  /// Només el receptor del missatge el pot esborrar
  static var error1607 : String { return  L10n.tr("Localizable", "Error1607") }
  /// Només un usuari logat pot afegir una instal·lació
  static var error1701 : String { return  L10n.tr("Localizable", "Error1701") }
  /// Ja tens una instal·lació
  static var error1702 : String { return  L10n.tr("Localizable", "Error1702") }
  /// No tens cap instal·lació
  static var error1703 : String { return  L10n.tr("Localizable", "Error1703") }
  /// No tens cap instal·lació
  static var error1704 : String { return  L10n.tr("Localizable", "Error1704") }
  /// La notificació no existeix
  static var error1801 : String { return  L10n.tr("Localizable", "Error1801") }
  /// L’usuari no pot accedir a aquesta notificació
  static var error1802 : String { return  L10n.tr("Localizable", "Error1802") }
  /// Calendari no trobat
  static var error1901 : String { return  L10n.tr("Localizable", "Error1901") }
  /// Esdeveniment no trobat
  static var error1902 : String { return  L10n.tr("Localizable", "Error1902") }
  /// L’esdeveniment no pertany al calendari
  static var error1903 : String { return  L10n.tr("Localizable", "Error1903") }
  /// L’usuari no pot accedir aquest calendari
  static var error1904 : String { return  L10n.tr("Localizable", "Error1904") }
  /// Només els esdeveniments pendents poden ser recordats
  static var error1905 : String { return  L10n.tr("Localizable", "Error1905") }
  /// Només el propietari d’un calendari pot acceptar o rebutjar un esdeveniment
  static var error1906 : String { return  L10n.tr("Localizable", "Error1906") }
  /// L’usuari no pot accedir a aquest esdeveniment
  static var error1907 : String { return  L10n.tr("Localizable", "Error1907") }
  /// L’usuari no pot modificar a aquest esdeveniment
  static var error1908 : String { return  L10n.tr("Localizable", "Error1908") }
  /// L’usuari no pot eliminar a aquest esdeveniment
  static var error1909 : String { return  L10n.tr("Localizable", "Error1909") }
  /// L’usuari no pot afegir esdeveniments a aquest calendari
  static var error1910 : String { return  L10n.tr("Localizable", "Error1910") }
  /// L’usuari que ha creat un esdeveniment és l’únic que el pot recordar
  static var error1911 : String { return  L10n.tr("Localizable", "Error1911") }
  /// No s’ha trobat el grup
  static var error2001 : String { return  L10n.tr("Localizable", "Error2001") }
  /// El usuari no és dinamitzador
  static var error2002 : String { return  L10n.tr("Localizable", "Error2002") }
  /// L’usuari no pot enviar la invitació
  static var error2003 : String { return  L10n.tr("Localizable", "Error2003") }
  /// Invitació no trobada
  static var error2004 : String { return  L10n.tr("Localizable", "Error2004") }
  /// La invitació no és per aquest grup
  static var error2005 : String { return  L10n.tr("Localizable", "Error2005") }
  /// La invitació no és per aquest usuari
  static var error2006 : String { return  L10n.tr("Localizable", "Error2006") }
  /// L’usuari ja forma part del grup
  static var error2007 : String { return  L10n.tr("Localizable", "Error2007") }
  /// L’usuari no pot accedir a la informació d’aquest grup
  static var error2008 : String { return  L10n.tr("Localizable", "Error2008") }
  /// L’usuari no està autoritzat a afegir usuaris en aquest grup
  static var error2009 : String { return  L10n.tr("Localizable", "Error2009") }
  /// L'usuari no pertany al grup
  static var error2011 : String { return  L10n.tr("Localizable", "Error2011") }
  /// No s’ha trobat el xat
  static var error2101 : String { return  L10n.tr("Localizable", "Error2101") }
  /// L’usuari no pot accedir a aquest xat
  static var error2102 : String { return  L10n.tr("Localizable", "Error2102") }
  /// Missatge de xat no trobat
  static var error2103 : String { return  L10n.tr("Localizable", "Error2103") }
  /// El missatge no forma part d’aquest xat
  static var error2104 : String { return  L10n.tr("Localizable", "Error2104") }
  /// El missatge de xat no té cap contingut
  static var error2105 : String { return  L10n.tr("Localizable", "Error2105") }
  /// Els missatges han de tenir text o un adjunt
  static var error2106 : String { return  L10n.tr("Localizable", "Error2106") }
  /// L’usuari no pot realitzar aquesta trucada
  static var error2201 : String { return  L10n.tr("Localizable", "Error2201") }
  /// Mail no enviat
  static var error2601 : String { return  L10n.tr("Localizable", "Error2601") }
  /// Format de mail invàlid
  static var error2602 : String { return  L10n.tr("Localizable", "Error2602") }
  /// Codi de registre d’usuari incorrecte
  static var error2701 : String { return  L10n.tr("Localizable", "Error2701") }
  /// Només es poden migrar els usuaris vincles
  static var error2801 : String { return  L10n.tr("Localizable", "Error2801") }
  /// L’usuari ja està migrat
  static var error2802 : String { return  L10n.tr("Localizable", "Error2802") }
  /// Codi de migració d’usuari incorrecte
  static var error2803 : String { return  L10n.tr("Localizable", "Error2803") }
  /// Ho sentim, hi ha hagut un error.
  static var errorGenerico : String { return  L10n.tr("Localizable", "ErrorGenerico") }
  /// Hem enviat un correu amb instruccions del procés per recuperar la seva contrasenya, si us plau revisa el teu correu electrònic per completar el procés
  static var forgotAlert : String { return  L10n.tr("Localizable", "ForgotAlert") }
  /// Hi ha hagut un error enviant el correu electrònic de recuperació de contrasenya
  static var forgotAlertError : String { return  L10n.tr("Localizable", "ForgotAlertError") }
  /// Recuperar contrasenya
  static var forgotButton : String { return  L10n.tr("Localizable", "ForgotButton") }
  /// Correu electrònic
  static var forgotEmail : String { return  L10n.tr("Localizable", "ForgotEmail") }
  /// RECUPERAR CONTRASENYA
  static var forgotHeader : String { return  L10n.tr("Localizable", "ForgotHeader") }
  /// Galeria
  static var galeria : String { return  L10n.tr("Localizable", "Galeria") }
  /// Tornar
  static var galeriaCancelarCompartir : String { return  L10n.tr("Localizable", "GaleriaCancelarCompartir") }
  /// Continguts compartits correctament
  static var galeriaCompartido : String { return  L10n.tr("Localizable", "GaleriaCompartido") }
  /// Arxius rebuts
  static var galeriaCompartidos : String { return  L10n.tr("Localizable", "GaleriaCompartidos") }
  /// Compartir
  static var galeriaCompartir : String { return  L10n.tr("Localizable", "GaleriaCompartir") }
  /// Clica el contacte amb el que vulguis compartir els arxius
  static var galeriaCompartirContactesTitle : String { return  L10n.tr("Localizable", "GaleriaCompartirContactesTitle") }
  /// Ha succeït un error al compartir. Vol tornar a intentar-ho?
  static var galeriaCompartirError : String { return  L10n.tr("Localizable", "GaleriaCompartirError") }
  /// Clica sobre l'arxiu que vulguis compartir
  static var galeriaCompartirTitle : String { return  L10n.tr("Localizable", "GaleriaCompartirTitle") }
  /// Compartir l'arxiu
  static var galeriaConfirmarCompartirUn : String { return  L10n.tr("Localizable", "GaleriaConfirmarCompartirUn") }
  /// Compartir els arxius
  static var galeriaConfirmarCompartirVaris : String { return  L10n.tr("Localizable", "GaleriaConfirmarCompartirVaris") }
  /// Eliminar
  static var galeriaEliminar : String { return  L10n.tr("Localizable", "GaleriaEliminar") }
  /// Hi ha hagut un error al eliminar l'arxiu. Vol tornar a intentar-ho?
  static var galeriaEliminarErrorUn : String { return  L10n.tr("Localizable", "GaleriaEliminarErrorUn") }
  /// Hi ha hagut un error al eliminar els arxius. Vol tornar a intentar-ho?
  static var galeriaEliminarErrorVaris : String { return  L10n.tr("Localizable", "GaleriaEliminarErrorVaris") }
  /// Segur que vol eliminar l'arxiu?
  static var galeriaEliminarTitle : String { return  L10n.tr("Localizable", "GaleriaEliminarTitle") }
  /// Hi ha hagut un error al guardar l'arxiu. Vol tornar a intentar-ho?
  static var galeriaErrorSubir : String { return  L10n.tr("Localizable", "GaleriaErrorSubir") }
  /// Reintentar
  static var galeriaErrorSubirReintentar : String { return  L10n.tr("Localizable", "GaleriaErrorSubirReintentar") }
  /// Filtrar
  static var galeriaFiltrar : String { return  L10n.tr("Localizable", "GaleriaFiltrar") }
  /// Els meus arxius
  static var galeriaMios : String { return  L10n.tr("Localizable", "GaleriaMios") }
  /// Nova foto
  static var galeriaNuevaFoto : String { return  L10n.tr("Localizable", "GaleriaNuevaFoto") }
  /// Nou video
  static var galeriaNuevoVideo : String { return  L10n.tr("Localizable", "GaleriaNuevoVideo") }
  /// Seleccionar
  static var galeriaSeleccionar : String { return  L10n.tr("Localizable", "GaleriaSeleccionar") }
  /// Galeria
  static var galeriaTitle : String { return  L10n.tr("Localizable", "GaleriaTitle") }
  /// Tots els arxius
  static var galeriaTodos : String { return  L10n.tr("Localizable", "GaleriaTodos") }
  /// Veure només els meus arxius
  static var galeriaVerMios : String { return  L10n.tr("Localizable", "GaleriaVerMios") }
  /// Veure només els arxius rebuts
  static var galeriaVerRecibidos : String { return  L10n.tr("Localizable", "GaleriaVerRecibidos") }
  /// Veure tots els arxius
  static var galeriaVerTodos : String { return  L10n.tr("Localizable", "GaleriaVerTodos") }
  /// Dinamitzador
  static var grupEnviarDinamitzador : String { return  L10n.tr("Localizable", "GrupEnviarDinamitzador") }
  /// Enviar invitació
  static var grupEnviarInvitacio : String { return  L10n.tr("Localizable", "GrupEnviarInvitacio") }
  /// Consulta els avisos
  static var homeAvisos : String { return  L10n.tr("Localizable", "HomeAvisos") }
  /// Benvinguda a Vincles,
  static var homeBienvenida : String { return  L10n.tr("Localizable", "HomeBienvenida") }
  /// Benvingut a Vincles,
  static var homeBienvenido : String { return  L10n.tr("Localizable", "HomeBienvenido") }
  /// Calendari
  static var homeCalendario : String { return  L10n.tr("Localizable", "HomeCalendario") }
  /// Veure tots els contactes
  static var homeContactos : String { return  L10n.tr("Localizable", "HomeContactos") }
  /// Fotos i vídeos
  static var homeFotos : String { return  L10n.tr("Localizable", "HomeFotos") }
  /// Encara no tens contactes
  static var homeNoContacts : String { return  L10n.tr("Localizable", "HomeNoContacts") }
  /// Família i amics
  static var homeVinclesFamilia : String { return  L10n.tr("Localizable", "HomeVinclesFamilia") }
  /// Grups Vincles
  static var homeVinclesGrups : String { return  L10n.tr("Localizable", "HomeVinclesGrups") }
  /// Inici de la cita
  static var iniciCita : String { return  L10n.tr("Localizable", "IniciCita") }
  /// El correu electrònic introduït no és vàlid
  static var invalidEmail : String { return  L10n.tr("Localizable", "InvalidEmail") }
  /// La contrasenya ha de tenir un mínim de 8 caràcters i un màxim de 16
  static var invalidPassword : String { return  L10n.tr("Localizable", "InvalidPassword") }
  /// Introdueix les teves credencials per accedir a Vincles BCN:
  static var loginDescription : String { return  L10n.tr("Localizable", "LoginDescription") }
  /// Usuari o correu electrònic
  static var loginEmail : String { return  L10n.tr("Localizable", "LoginEmail") }
  /// Entrar
  static var loginEntrar : String { return  L10n.tr("Localizable", "LoginEntrar") }
  /// Dades d'accés incorrectes
  static var loginErrorData : String { return  L10n.tr("Localizable", "LoginErrorData") }
  /// Hi ha hagut un error recuperant les teves dades. Si us plau, intenta-ho de nou
  static var loginErrorRecuperant : String { return  L10n.tr("Localizable", "LoginErrorRecuperant") }
  /// Error recuperant les dades de l'usuari
  static var loginErrorServer : String { return  L10n.tr("Localizable", "LoginErrorServer") }
  /// Recuperar contrasenya
  static var loginForgot : String { return  L10n.tr("Localizable", "LoginForgot") }
  /// Guardar dades d'accés
  static var loginGuardarDades : String { return  L10n.tr("Localizable", "LoginGuardarDades") }
  /// ENTRAR
  static var loginHeader : String { return  L10n.tr("Localizable", "LoginHeader") }
  /// Enviant informació al servidor
  static var loginLoadingEnviant : String { return  L10n.tr("Localizable", "LoginLoadingEnviant") }
  /// Recuperant informació d’usuari
  static var loginLoadingRecuperant : String { return  L10n.tr("Localizable", "LoginLoadingRecuperant") }
  /// Contrasenya
  static var loginPassword : String { return  L10n.tr("Localizable", "LoginPassword") }
  /// Registrar un nou usuari
  static var loginRegistrar : String { return  L10n.tr("Localizable", "LoginRegistrar") }
  /// Cancel·lar
  static var logoutPopupButton1 : String { return  L10n.tr("Localizable", "LogoutPopupButton1") }
  /// Tancar sessió
  static var logoutPopupButton2 : String { return  L10n.tr("Localizable", "LogoutPopupButton2") }
  /// Segur que vol tancar la sessió?
  static var logoutPopupDesc : String { return  L10n.tr("Localizable", "LogoutPopupDesc") }
  /// Tancar sessió
  static var logoutPopupTitle : String { return  L10n.tr("Localizable", "LogoutPopupTitle") }
  /// Trucada perduda de
  static var lostCall : String { return  L10n.tr("Localizable", "LostCall") }
  /// Menú
  static var menu : String { return  L10n.tr("Localizable", "Menu") }
  /// No tens connectivitat amb la xarxa
  static var noNetwork : String { return  L10n.tr("Localizable", "NoNetwork") }
  /// Encara no tens avisos
  static var noNotifications : String { return  L10n.tr("Localizable", "NoNotifications") }
  /// Anar al calendari
  static var notificacioButtonCalendari : String { return  L10n.tr("Localizable", "NotificacioButtonCalendari") }
  /// Anar al xat
  static var notificacioButtonChat : String { return  L10n.tr("Localizable", "NotificacioButtonChat") }
  /// Veure cita
  static var notificacioButtonCita : String { return  L10n.tr("Localizable", "NotificacioButtonCita") }
  /// Veure contactes
  static var notificacioButtonContacts : String { return  L10n.tr("Localizable", "NotificacioButtonContacts") }
  /// Veure grups
  static var notificacioButtonGroups : String { return  L10n.tr("Localizable", "NotificacioButtonGroups") }
  /// Trucar ara
  static var notificacioButtonTrucar : String { return  L10n.tr("Localizable", "NotificacioButtonTrucar") }
  /// Afegir usuari
  static var notificacioButtonUserInvitation : String { return  L10n.tr("Localizable", "NotificacioButtonUserInvitation") }
  /// %@ ha actualitzat la cita del dia %@ a les %@
  static func notificacioChangedMeeting(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "NotificacioChangedMeeting", p1, p2, p3)
  }
  /// T’han eliminat del grup %@
  static func notificacioEliminatGrup(_ p1: String) -> String {
    return L10n.tr("Localizable", "NotificacioEliminatGrup", p1)
  }
  /// %@ ha acceptat la invitació del dia %@ a les %@
  static func notificacioIAcceptedMeeting(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "NotificacioIAcceptedMeeting", p1, p2, p3)
  }
  /// %@ ha rebutjat la invitació del dia %@ a les %@
  static func notificacioIDeclinedMeeting(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "NotificacioIDeclinedMeeting", p1, p2, p3)
  }
  /// %@ ha cancel·lat la invitació del dia %@ a les %@
  static func notificacioInvitationRevokedMeeting(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "NotificacioInvitationRevokedMeeting", p1, p2, p3)
  }
  /// %@ t'ha convidat a una cita el dia %@ a les %@
  static func notificacioInvitedMeeting(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "NotificacioInvitedMeeting", p1, p2, p3)
  }
  /// Notificacions
  static var notificaciones : String { return  L10n.tr("Localizable", "Notificaciones") }
  /// Nou àudio
  static var notificacioNouAudio : String { return  L10n.tr("Localizable", "NotificacioNouAudio") }
  /// T’han convidat al grup %@
  static func notificacioNouGrup(_ p1: String) -> String {
    return L10n.tr("Localizable", "NotificacioNouGrup", p1)
  }
  /// Nou missatge
  static var notificacioNouMulti : String { return  L10n.tr("Localizable", "NotificacioNouMulti") }
  /// %i missatge nou de %@
  static func notificacioNousMissatge(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatge", p1, p2)
  }
  /// %i missatges nous de %@
  static func notificacioNousMissatges(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatges", p1, p2)
  }
  /// %i missatges nous de %@
  static func notificacioNousMissatgesDinam(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatgesDinam", p1, p2)
  }
  /// %i missatge nou de %@
  static func notificacioNousMissatgesDinamUn(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatgesDinamUn", p1, p2)
  }
  /// %i missatges nous al xat de grup %@
  static func notificacioNousMissatgesGrup(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatgesGrup", p1, p2)
  }
  /// %i missatge nou al xat de grup %@
  static func notificacioNousMissatgesGrupUn(_ p1: Int, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioNousMissatgesGrupUn", p1, p2)
  }
  /// Nou vídeo
  static var notificacioNouVideo : String { return  L10n.tr("Localizable", "NotificacioNouVideo") }
  /// Nova foto
  static var notificacioNovaImage : String { return  L10n.tr("Localizable", "NotificacioNovaImage") }
  /// %@ t'ha convidat a formar part dels seus contactes. El seu codi de vinculació és %@
  static func notificacioUserInvitation(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "NotificacioUserInvitation", p1, p2)
  }
  /// %@ és el teu nou contacte
  static func notificacioUserLinked(_ p1: String) -> String {
    return L10n.tr("Localizable", "NotificacioUserLinked", p1)
  }
  /// %@ ja no és el teu contacte
  static func notificacioUserUnlinked(_ p1: String) -> String {
    return L10n.tr("Localizable", "NotificacioUserUnlinked", p1)
  }
  /// La descripció de la cita és obligatoria
  static var novaCitaTitleObligatorio : String { return  L10n.tr("Localizable", "NovaCitaTitleObligatorio") }
  /// Escriu aquí el títol de la cita
  static var nuevaCitaPlaceholder : String { return  L10n.tr("Localizable", "NuevaCitaPlaceholder") }
  /// Entesos
  static var ok : String { return  L10n.tr("Localizable", "Ok") }
  /// El número de telèfon no pot contenir lletres o símbols
  static var phoneNumeric : String { return  L10n.tr("Localizable", "PhoneNumeric") }
  /// Inici
  static var principal : String { return  L10n.tr("Localizable", "Principal") }
  /// Vius a Barcelona?
  static var registerBcn : String { return  L10n.tr("Localizable", "RegisterBcn") }
  /// Data de naixement
  static var registerBirthdate : String { return  L10n.tr("Localizable", "RegisterBirthdate") }
  /// Registrar
  static var registerButton : String { return  L10n.tr("Localizable", "RegisterButton") }
  /// Castellà
  static var registerCastellano : String { return  L10n.tr("Localizable", "RegisterCastellano") }
  /// Català
  static var registerCatala : String { return  L10n.tr("Localizable", "RegisterCatala") }
  /// Correu electrònic
  static var registerEmail : String { return  L10n.tr("Localizable", "RegisterEmail") }
  /// El correu indicat ja està vinculat a un usuari
  static var registerErrorData : String { return  L10n.tr("Localizable", "RegisterErrorData") }
  /// Error al registrar l'usuari
  static var registerErrorServer : String { return  L10n.tr("Localizable", "RegisterErrorServer") }
  /// Escull una foto
  static var registerEscogeFoto : String { return  L10n.tr("Localizable", "RegisterEscogeFoto") }
  /// La meva foto
  static var registerFoto : String { return  L10n.tr("Localizable", "RegisterFoto") }
  /// Càmera
  static var registerFotoCamara : String { return  L10n.tr("Localizable", "RegisterFotoCamara") }
  /// Galeria
  static var registerFotoGaleria : String { return  L10n.tr("Localizable", "RegisterFotoGaleria") }
  /// Fotografia
  static var registerFotoTitle : String { return  L10n.tr("Localizable", "RegisterFotoTitle") }
  /// Gènere
  static var registerGender : String { return  L10n.tr("Localizable", "RegisterGender") }
  /// DONA
  static var registerGenderFem : String { return  L10n.tr("Localizable", "RegisterGenderFem") }
  /// HOME
  static var registerGenderMasc : String { return  L10n.tr("Localizable", "RegisterGenderMasc") }
  /// REGISTRAR
  static var registerHeader : String { return  L10n.tr("Localizable", "RegisterHeader") }
  /// Idioma de l'app Vincles BCN
  static var registerLanguage : String { return  L10n.tr("Localizable", "RegisterLanguage") }
  /// Nom
  static var registerName : String { return  L10n.tr("Localizable", "RegisterName") }
  /// Contrasenya
  static var registerPassword : String { return  L10n.tr("Localizable", "RegisterPassword") }
  /// Dades personals
  static var registerPersonalData : String { return  L10n.tr("Localizable", "RegisterPersonalData") }
  /// Telèfon
  static var registerPhone : String { return  L10n.tr("Localizable", "RegisterPhone") }
  /// Repetir contrasenya
  static var registerRepeatPassword : String { return  L10n.tr("Localizable", "RegisterRepeatPassword") }
  /// Cognoms
  static var registerSurname : String { return  L10n.tr("Localizable", "RegisterSurname") }
  /// El camp és obligatori
  static var requiredField : String { return  L10n.tr("Localizable", "RequiredField") }
  /// Sortir
  static var salir : String { return  L10n.tr("Localizable", "Salir") }
  /// Sobre Vincles BCN
  static var sobreVincles : String { return  L10n.tr("Localizable", "SobreVincles") }
  /// Vincles és un servei de suport i acompanyament en la conservació, enfortiment i creació de vincles relacionals de les persones grans usuàries del servei.\n\nD'una banda, el servei Vincles consisteix en donar suport en la dinamització de la xarxa personal de la persona gran; tot incorporant familiars, amics, veïns i persones del seu entorn de confiança a la seva xarxa. D'altra banda, el servei Vincles pretén incorporar la persona gran en grups creats amb altres usuaris del servei, tot fomentant la interacció i promovent la participació en activitats tant online com presencials.\n\nAjuntament de Barcelona\n\nEn cas de consultes, queixes, suggeriments o incidències, si us plau, utilitzeu el formulari disponible a la següent web: http://www.bcn.cat/cgi-bin/queixesIRIS?id=391\n\nVersió de l'aplicació: %@
  static func sobreVinclesText(_ p1: String) -> String {
    return L10n.tr("Localizable", "SobreVinclesText", p1)
  }
  /// Tancar
  static var tancar : String { return  L10n.tr("Localizable", "Tancar") }
  /// Acceptar
  static var termsAccept : String { return  L10n.tr("Localizable", "TermsAccept") }
  /// Cancel·lar
  static var termsCancel : String { return  L10n.tr("Localizable", "TermsCancel") }
  /// TERMES I CONDICIONS
  static var termsHeader : String { return  L10n.tr("Localizable", "TermsHeader") }
  /// Has d'acceptar els termes i condicions per poder continuar
  static var termsMustAccept : String { return  L10n.tr("Localizable", "TermsMustAccept") }
  /// Entesos
  static var termsOk : String { return  L10n.tr("Localizable", "TermsOk") }
  /// Condicions Generals d’ús dels participants de la xarxa personal de les persones usuàries del servei Vincles BCN\n\n\nVINCLES BCN és un nou servei de l'Ajuntament de Barcelona adreçat a persones de 65 anys o més. VINCLES BCN vol reforçar les relacions socials de les persones grans que se senten soles i millorar el seu benestar, utilitzant la tecnologia com a eina. Podeu trobar més informació a http://www.barcelona.cat/vinclesbcn.\n\n\nAquestes Condicions Generals d’ús (d’ara endavant, les “Condicions Generals”) regeixen l’accés i l’ús del servei que s’ofereix amb l’aplicació mòbil VINCLES BCN (d’ara endavant, “VINCLES BCN”), titularitat de l’Ajuntament de Barcelona.\n\nL’ús de VINCLES BCN atribueix a qui en faci ús la condició de participant, segons correspongui, i implica l’acceptació de tots els termes inclosos en aquestes Condicions Generals. En cas de no estar d’acord amb aquestes Condicions Generals, el participant ha de deixar d’utilitzar VINCLES BCN immediatament.\n\nEn acceptar aquestes Condicions Generals, el participant manifesta:\n\nQue ha llegit, entén i compren el que s’exposa aquí;\nque té mes de 14 anys; i\nque assumeix totes les obligacions que es disposen aquí.\n\n\n1.    Definicions:\n\n1.1.    VINCLES BCN: fa referència al servei de suport social que l’Ajuntament de Barcelona ofereix a les persones grans per a la conservació, l’enfortiment i la creació de vincles relacionals. Actualment, aquest servei és un pilot en fase de proves.\n\n1.2.     Ajuntament: l’Ajuntament de Barcelona, titular de VINCLES BCN.\n\n1.3.     Participant: persona física que utilitza VINCLES BCN i que té relació directa amb la persona usuària del servei Vincles BCN.\n\n\n2.    Contacte:\n\n2.1.     Si vol contactar amb el servei d’atenció de VINCLES BCN, pot:\n\nTrucar al número de telèfon d’informació i tramitació 010\nenviar un missatge a través del servei d’atenció en línia del web http://www.barcelona.cat/; o\nconsultar informació general sobre el projecte VINCLES BCN a la pàgina web http://www.barcelona.cat/vinclesbcn\n\n\n3.    Modificacions:\n\n3.1.    Tenint en compte l’esforç per mantenir en constant evolució el projecte VINCLES BCN, l’Ajuntament de Barcelona es reserva la facultat de modificar-lo o actualitzar-lo en qualsevol moment, així com de modificar o actualitzar aquestes Condicions Generals. Quan la modificació o actualització impliqui una modificació substancial de les condicions del servei, se n’informarà al participant, com a mínim enviant un missatge per mitjans electrònics.\n\nL’última versió d’aquestes Condicions Generals es pot consultar a la pàgina web següent:\nhttp://ajuntament.barcelona.cat/vinclesbcn/.\n\n\n4.    Accés a VINCLES BCN:\n\n4.1.    Per poder utilitzar VINCLES BCN, és necessari haver rebut una invitació de la persona usuària, disposar de connexió a Internet, descarregar l’aplicació mòbil titularitat de l’Ajuntament de Barcelona i instal·lar-la en un dispositiu mòbil que reuneixi els requisits tècnics mínimament necessaris per fer-ho. Per accedir a VINCLES BCN, el participant s’hi ha d’haver registrat, proporcionant, com a mínim, les dades assenyalades com a obligatòries que se li sol·licitin.\n\n4.2.    El participant registrat serà responsable en tot moment de la custòdia del seu password, assumint en conseqüència qualsevol dany i perjudici que es pogués derivar del seu ús indegut, així com de la cessió, revelació o pèrdua del mateix. A aquests efectes, l’accés a àrees restringides i/o l’ús dels serveis i continguts realitzats sota el password d’un participant registrat es reputaran realitzats per aquest participant registrat, qui respondrà en tot cas d’aquest accés i ús.\n\n4.3.    L’aplicació mòbil esmentada només està disponible per als dispositius que tinguin el sistema operatiu Android o iOS. Al web del servei VINCLES BCN es podrà consultar més detall de les versions dels dispositius compatibles amb l'aplicació mòbil.\n\n4.4.    L’Ajuntament de Barcelona es reserva el dret a restringir o cancel·lar, en qualsevol moment i sense avís previ, l’accés de qualsevol participant a VINCLES BCN. De la mateixa manera, l’Ajuntament podrà cancel·lar o donar per finalitzat en qualsevol moment el projecte VINCLES BCN. En aquests supòsits, l’Ajuntament no estarà obligat a indemnitzar ni a compensar de cap manera el participant.\n\n4.5.     Es recorda al participant que l’ús d’Internet des d’un dispositiu electrònic pot suposar-li un cost addicional.\n\n4.6.     Els requisits tècnics mínims es poden consultar a la pàgina web següent:\nhttp://ajuntament.barcelona.cat/vinclesbcn/ca/\n\n\n5.    Analítica d’ús:\n\nAmb la finalitat de fer seguiment de l'ús del servei VINCLES BCN, els participants saben i accepten que l’Ajuntament podrà dur a terme anàlisis estadístiques de l’ús de l’activitat amb relació a les comunicacions que s’estableixin a través de VINCLES BCN.\n\n6.    Informació facilitada pel participant:\n\nLes dades i la informació personal indicades pel participant han de ser exactes, actuals i veraces. El participant serà responsable a cada moment de les dades i la informació que proporcioni a través de VINCLES BCN.\n\n\n7.    Normes d’ús de VINCLES BCN:\n\n7.1.    El participant s’obliga a utilitzar VINCLES BCN conforme al que s’estableix a la Llei, la moral, l’ordre públic i en aquestes Condicions Generals.\n\n7.2.    A tall enunciatiu, però en cap cas limitatiu o excloent, el participant es compromet a:\n\nNo introduir o difondre contingut o propaganda de caràcter racista, xenòfob, pornogràfic, relatius a l’apologia del terrorisme o que atemptin contra els drets humans;\nno introduir o difondre virus o software nocius susceptibles de provocar danys als sistemes informàtics de l’Ajuntament, a d’altres participants o a qualsevol altre tercer;\nNo difondre, transmetre o posar a disposició de tercers:\nCap tipus d’informació, element o contingut que atempti contra els drets fonamentals i les llibertats públiques reconegudes constitucionalment i en els tractats internacionals;\ninformació, elements o continguts que constitueixin publicitat il·lícita o deslleial;\npublicitat no sol·licitada o no autoritzada, material publicitari, “correu brossa”, “cartes en cadena” o “estructures piramidals”;\ninformació o continguts falsos, ambigus o inexactes, que indueixin a error als receptors de la informació;\ninformació, elements o continguts que suposin una violació dels drets de propietat intel·lectual o industrial;\ninformació, elements o continguts que suposin una violació del secret de les comunicacions o de la legislació sobre la protecció de dades personals.\nno suplantar altres participants.\n\n\n8.    Propietat intel·lectual i industrial:\n\n8.1.    VINCLES BCN i tots els elements que el componen (entesos aquests, a tall merament enunciatiu, com els textos, fotografies, gràfics, imatges, icones, tecnologia, software, enllaços i d’altres continguts audiovisuals o sonors, així com el seu disseny gràfic i els codis font) són propietat intel·lectual de l’Ajuntament de Barcelona o de tercers llicenciants d’aquest.\n\n8.2.    L’Ajuntament de Barcelona concedeix al participant una llicència no exclusiva d’ús sobre VINCLES BCN. El participant podrà utilitzar l'aplicació tant dins del territori espanyol com fora d'aquest.\n\n8.3.     Amb relació als continguts introduïts o publicats pel participant a VINCLES BCN, conserva tots els drets sobre aquests i assumeix tota la responsabilitat en cas que els continguts vulnerin els drets de tercers. En aquest sentit, el participant es fa responsable dels continguts que carregui o introdueixi a VINCLES BCN.\n\n8.4.    La marca VINCLES BCN® és titularitat de l’Ajuntament de Barcelona, sense que es pugui entendre que s’ha cedit cap dret sobre la marca al participant.\n\n\n9.    Responsabilitat:\n\n9.1.    VINCLES BCN no és un mitjà oficial de comunicació amb l’Ajuntament\n\n9.2.    El participant s’obliga a mantenir completament indemne l’Ajuntament en el cas de qualsevol possible reclamació, multa, pena o sanció que pugui estar obligat a suportar com a conseqüència del seu incompliment del que s’estableix en aquestes Condicions Generals. L’Ajuntament també es reserva el dret a sol·licitar la indemnització per danys i perjudicis que li pugui correspondre.\n\n9.3.    El participant no podrà fer cap tipus de reclamació a l’Ajuntament de Barcelona en cas que la persona usuària decideixi donar-se de baixa de VINCLES BCN.\n\n9.4.    L’Ajuntament de Barcelona no es responsabilitza dels danys i/o perjudicis produïts al dispositiu mòbil del participant durant l’ús de VINCLES BCN, ni dels danys o perjudicis de qualsevol tipus produïts al participant com a conseqüència d’errors o desconnexions de les xarxes de telecomunicacions que produeixin la suspensió, cancel·lació, interrupció o mal funcionament de VINCLES BCN.\n\n9.5.     L’Ajuntament no garanteix ni efectua cap manifestació sobre la idoneïtat de VINCLES BCN amb relació a les expectatives o les finalitats perseguides pel participant.\n\n9.6.    Sense perjudici de les limitacions de responsabilitat establertes en aquestes Condicions Generals, i en la mesura en què la legislació aplicable ho permeti, la responsabilitat màxima de l’Ajuntament per qualsevol perjudici derivat de l’ús de VINCLES BCN estarà limitada als danys dolosos i directes que pugui sofrir el participant, sempre que hagin estat causats directament per l’Ajuntament.\n\n\n10.        Protecció de dades personals:\n\n10.1.    Les dades personals que el participant faciliti durant el seu registre a VINCLES BCN, i les que proporcioni en el transcurs de la seva participació, així com el tractament posterior, s’inclouran en un fitxer titularitat de l’Ajuntament de Barcelona per a les següents finalitats: (i) gestionar la seva participació a VINCLES BCN; (ii) monitoritzar i dur a terme anàlisis estadístiques de l’activitat dels participants; i (iii) mantenir informat el participant, fins i tot per mitjans electrònics, dels serveis socials i les notícies de temàtica social relacionades amb l’Ajuntament.\n\n10.2.    El fet d’utilitzar VINCLES BCN implica l’acceptació en bloc de totes les finalitats de tractament indicades al paràgraf anterior.\n\n10.3.    En cas que sigui necessari prestar suport social a la persona gran usuària principal del servei, l'Ajuntament de Barcelona pot accedir a la informació que el participant publiqui i comparteixi a VINCLES BCN. Pel fet d’utilitzar una aplicació mòbil que té per objecte prestar serveis socials de suport, el participant del projecte sap i accepta que l’Ajuntament de Barcelona pot tenir accés a la informació que publiqui i comparteixi a VINCLES BCN. Les finalitats de l'accés són prestar el suport social necessari a les persones grans en l'ús de les tecnologies de la informació i optimitzar la prestació dels serveis socials adreçats a l'usuari en el marc del projecte. Aquests accessos es realitzaran sempre garantint la confidencialitat de la informació.\n\n10.4.     El participant pot exercir els seus drets d’accés, rectificació, cancel·lació i oposició, així com els que la normativa de protecció de dades vigent reconegui, enviant una sol·licitud escrita, indicant “Exercici de drets LOPD” al\nRegistre General de l’Ajuntament de Barcelona, Pl. Sant Jaume, 1, 08002 Barcelona\nPer obtenir-ne més informació, pot consultar la pàgina web de la Seu electrònica municipal: https://ajuntament.barcelona.cat/protecciodedades\n\n\n11.    Baixa del participant:\n\n11.1.    Perfil del participant: el participant pot donar-se de baixa de VINCLES BCN desinstal·lant l’aplicació mòbil. En el moment en què el participant desinstal·li VINCLES BCN, perdrà l’accés a les dades contingudes a l’aplicació i tot el contingut s’esborrarà automàticament, exceptuant les que l’Ajuntament hagi de conservar per motius legals durant un termini de 5 anys. Un cop transcorregut aquest termini, es procedirà a la cancel·lació de les dades, i només quedaran a disposició de l’Ajuntament les que siguin necessàries per a finalitats estadístiques.\n\n11.2.    En cas que el participant pertanyi a més d’una xarxa personal dins de VINCLES BCN, podrà donar-se de baixa de qualsevol d’aquestes mitjançant la funcionalitat per a aquest objectiu.\n\n11.3.    L’aplicació VINCLES BCN no està dissenyada per ser utilitzada com a sistema de backup o d’emmagatzematge de dades i continguts, de manera que el participant haurà d’abstenir-se d’utilitzar-la amb aquesta finalitat, d’acord amb el que s’estableix en el contracte d’alta de l’usuari.\n\n12.    Nul·litat i ineficàcia de les clàusules\n\nSi qualsevol clàusula inclosa en aquestes Condicions Generals fos declarada nul·la o ineficaç de manera total o parcial, aquesta nul·litat o ineficàcia només afectarà la clàusula o la part de la clàusula que resulti nul·la o ineficaç; la resta d’aquestes Condicions Generals romandrà inalterada i la disposició en qüestió es considerarà no inclosa de manera total o parcial.\n\n13.        Legislació aplicable i jurisdicció competent\n\nAquestes Condicions Generals es regiran i interpretaran d’acord amb les lleis espanyoles. Qualsevol controvèrsia que es pogués suscitar sobre VINCLES BCN o sobre aquestes Condicions Generals es sotmetrà als Jutjats i Tribunals de la ciutat de Barcelona, Espanya, tret que la llei estableixi obligatòriament una altra cosa.\n\n\nEl projecte VINCLES BCN, titularitat de l’Ajuntament de Barcelona, ha estat una de les cinc idees guanyadores del premi Mayors Challenge, atorgat per Bloomberg Philanthropies ( http://www.bloomberg.org ).
  static var termsText : String { return  L10n.tr("Localizable", "TermsText") }
  /// Trucar
  static var trucar : String { return  L10n.tr("Localizable", "Trucar") }
  /// Prem aquí per vuere la ajuda
  static var tutorialAyuda : String { return  L10n.tr("Localizable", "TutorialAyuda") }
  /// Tancar
  static var tutorialCerrar : String { return  L10n.tr("Localizable", "TutorialCerrar") }
  /// Prem aquí per veure el menú d'opcions
  static var tutorialMenu : String { return  L10n.tr("Localizable", "TutorialMenu") }
  /// Si us plau, introdueix en el següent camp el codi que has rebut per email per a validar el teu usuari.
  static var validacionDescripcion : String { return  L10n.tr("Localizable", "ValidacionDescripcion") }
  /// S'ha enviat el codi de confirmació al correu electrònic indicat al registrar.
  static var validacionEnviado : String { return  L10n.tr("Localizable", "ValidacionEnviado") }
  /// Error a l'enviar el codi de confirmació al correu electrònic
  static var validacionErrorEmail : String { return  L10n.tr("Localizable", "ValidacionErrorEmail") }
  /// La clau de validació no és correcta.
  static var validacionErrorIncorrect : String { return  L10n.tr("Localizable", "ValidacionErrorIncorrect") }
  /// CLAU DE VALIDACIÓ
  static var validacionHeader : String { return  L10n.tr("Localizable", "ValidacionHeader") }
  /// Clau de validació
  static var validacionPlaceholder : String { return  L10n.tr("Localizable", "ValidacionPlaceholder") }
  /// Reenviar correu
  static var validacionReenviar : String { return  L10n.tr("Localizable", "ValidacionReenviar") }
  /// Validar
  static var validacionValidar : String { return  L10n.tr("Localizable", "ValidacionValidar") }
  /// Tornar
  static var validacionVolver : String { return  L10n.tr("Localizable", "ValidacionVolver") }
  /// Tornar
  static var volver : String { return  L10n.tr("Localizable", "Volver") }
  /// En polsar aquí, podràs veure les cites d'avui.
  static var wtCalendariAvui : String { return  L10n.tr("Localizable", "WTCalendariAvui") }
  /// Polsant aquí, podràs afegir esdeveniments al calendari i convidar a qualsevol dels nostres contactes.
  static var wtCalendariCrear : String { return  L10n.tr("Localizable", "WTCalendariCrear") }
  /// En polsar aquí, podràs veure les cites de demà.
  static var wtCalendariDema : String { return  L10n.tr("Localizable", "WTCalendariDema") }
  /// En polsar aquí, podràs veure el mes sencer i navegar pel calendari, consultar altres cites en altres dies i crear-ne de noves.
  static var wtCalendariMes : String { return  L10n.tr("Localizable", "WTCalendariMes") }
  /// En polsar aquí, es podrà enviar missatges d'àudio al moment.
  static var wtChatAudio : String { return  L10n.tr("Localizable", "WTChatAudio") }
  /// En polsar aquí podrà accedir al xat privat amb el dinamitzador.
  static var wtChatCompte : String { return  L10n.tr("Localizable", "WTChatCompte") }
  /// En polsar aquí, es podrà fer una foto per enviar-la al moment.
  static var wtChatFoto : String { return  L10n.tr("Localizable", "WTChatFoto") }
  /// En polsar aquí, es podrà compartir arxius de la galeria del dispositiu.
  static var wtChatGaleria : String { return  L10n.tr("Localizable", "WTChatGaleria") }
  /// Aquí veurà els controls per gravar el missatge d'àudio.
  static var wtChatRecord : String { return  L10n.tr("Localizable", "WTChatRecord") }
  /// Aquí veurà els controls per escriure un missatge de text.
  static var wtChatSendText : String { return  L10n.tr("Localizable", "WTChatSendText") }
  /// En polsar aquí, es podrà desplegar el teclat i enviar missatges de text al moment.
  static var wtChatText : String { return  L10n.tr("Localizable", "WTChatText") }
  /// En polsar aquí, es podrà s'iniciarà una videotrucada amb el contacte del xat.
  static var wtChatTrucar : String { return  L10n.tr("Localizable", "WTChatTrucar") }
  /// En polsar aquí, es podrà crear un vídeo per a enviar-lo al moment.
  static var wtChatVideo : String { return  L10n.tr("Localizable", "WTChatVideo") }
  /// En polsar aquí, es pot accedir a les opcions per afegir un nou contacte.
  static var wtContactesAfegir : String { return  L10n.tr("Localizable", "WTContactesAfegir") }
  /// En polsar aquí, es podrà seleccionar els contactes que es volen eliminar.
  static var wtContactesEliminar : String { return  L10n.tr("Localizable", "WTContactesEliminar") }
  /// En polsar aquí, tornaràs sense eliminar cap contacte
  static var wtContactesEliminarBoto : String { return  L10n.tr("Localizable", "WTContactesEliminarBoto") }
  /// Polsant aquí, es poden filtrar els contactes per grups, dinamitzadors o familiars i amics.
  static var wtContactesFiltrar : String { return  L10n.tr("Localizable", "WTContactesFiltrar") }
  /// En polsar aquí, es podrà seleccionar el contingut que es vol esborrar o compartir, i amb quin dels nostres contactes es vol compartir.
  static var wtGaleriaCompartir : String { return  L10n.tr("Localizable", "WTGaleriaCompartir") }
  /// En polsar aquí, es podrà seleccionar els contactes amb els quals compartir les fotos i vídeos.
  static var wtGaleriaCompartirContactes : String { return  L10n.tr("Localizable", "WTGaleriaCompartirContactes") }
  /// En polsar aquí,  podrà eliminar els elements seleccionats
  static var wtGaleriaEliminar : String { return  L10n.tr("Localizable", "WTGaleriaEliminar") }
  /// Polsant aquí, es poden filtrar el contingut en fitxers propis o rebuts.
  static var wtGaleriaFiltrar : String { return  L10n.tr("Localizable", "WTGaleriaFiltrar") }
  /// En polsar aquí, podrà crear vídeos que s'afegiran a la seva galeria.
  static var wtGaleriaNouVideo : String { return  L10n.tr("Localizable", "WTGaleriaNouVideo") }
  /// En polsar aquí, podrà fer fotos que s'afegiran a la seva galeria.
  static var wtGaleriaNovaFoto : String { return  L10n.tr("Localizable", "WTGaleriaNovaFoto") }
  /// En polsar aquí, tornaràs sense compartir o esborrar cap element.
  static var wtGaleriaTornar : String { return  L10n.tr("Localizable", "WTGaleriaTornar") }
  /// En polsar aquí, podràs accedir al teu calendari i crear noves cites.
  static var wtHomeCalendari : String { return  L10n.tr("Localizable", "WTHomeCalendari") }
  /// En polsar aquí, podràs accedir a tots els contactes des d'aquí.
  static var wtHomeContactes : String { return  L10n.tr("Localizable", "WTHomeContactes") }
  /// En polsar aquí, podràs accedir a tot el contingut multimèdia creat per tu o compartit pels teus contactes.
  static var wtHomeGaleria : String { return  L10n.tr("Localizable", "WTHomeGaleria") }
  /// Polsant aquí, podràs veure tots els avisos pendents de revisar. Cites pendents, missatges i/o trucades perdudes.
  static var wtHomeNotificacions : String { return  L10n.tr("Localizable", "WTHomeNotificacions") }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let lang = UserDefaults.standard.string(forKey: "i18n_language")
    let path = Bundle.main.path(forResource: lang, ofType: "lproj")
    let bundle = Bundle(path: path!)
    let format = NSLocalizedString(key, tableName: table, bundle: bundle!, comment: "")
    let locale = Locale(identifier: lang!)
    return String(format: format, locale: locale, arguments: args)
  }
}

private final class BundleToken {}
