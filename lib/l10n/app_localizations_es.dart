// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'D&D';

  @override
  String get navCharacters => 'Personajes';

  @override
  String get navDiaries => 'Diarios';

  @override
  String get navSpells => 'Hechizos';

  @override
  String get navInformation => 'Información';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createCharacter => 'Crear personaje';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get retry => 'Reintentar';

  @override
  String get unknown => 'Desconocido';

  @override
  String get language => 'Idioma';

  @override
  String get languageWarningTitle => 'Cambio de idioma';

  @override
  String get languageWarningMessage =>
      'Al cambiar a español, algunos recursos como la información de los hechizos seguirán en inglés.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get signInBackupDescription =>
      'Inicia sesión para guardar tu información y acceder a ella desde cualquier dispositivo';

  @override
  String get edit => 'Editar';

  @override
  String get diary => 'Diario';

  @override
  String get addToGroup => 'Añadir a un grupo';

  @override
  String get modifyGroup => 'Modificar grupo';

  @override
  String get removeFromGroup => 'Quitar del grupo';

  @override
  String get delete => 'Eliminar';

  @override
  String get downloadChanges => 'Descargar cambios';

  @override
  String get downloadChangesDescription =>
      'Hay cambios en otros dispositivos. ¿Deseas descargarlos ahora?\n\nEsto reemplazará tus datos locales con los cambios más recientes de la nube.';

  @override
  String get download => 'Descargar';

  @override
  String get cloudSyncOptions => 'Opciones de sincronización';

  @override
  String signedInAs(Object email) {
    return 'Iniciado como: $email';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncNowDescription => 'Subir todos los cambios locales a la nube';

  @override
  String get downloadFromCloud => 'Descargar desde la nube';

  @override
  String get downloadFromCloudDescription =>
      'Reemplazar los datos locales por los de la nube';

  @override
  String get signOutAndDisableCloudSync =>
      'Cerrar sesión y desactivar la sincronización';

  @override
  String get deleteAccountAndCloudData =>
      'Eliminar permanentemente tu cuenta y todos los datos de la nube';

  @override
  String get confirmSync => 'Confirmar sincronización';

  @override
  String get confirmSyncDescription =>
      'Esta sincronización cambiará permanentemente los datos de la nube. ¿Seguro que quieres continuar?';

  @override
  String get syncLabel => 'Sincronizar';

  @override
  String get deleteAccountQuestion => '¿Eliminar cuenta?';

  @override
  String get deleteAccountWarningTitle => 'Esto borrará permanentemente:';

  @override
  String get deleteAccountWarningAccount => '• Tu cuenta';

  @override
  String get deleteAccountWarningCharacters =>
      '• Todos los personajes sincronizados en la nube';

  @override
  String get deleteAccountWarningDiaries =>
      '• Todos los diarios sincronizados en la nube';

  @override
  String get deleteAccountWarningNote =>
      'Nota: Los datos locales de este dispositivo NO se borrarán.';

  @override
  String get deleteAccountWarningPermanent =>
      'Esta acción no se puede deshacer.';

  @override
  String get accountDeletionConfirmationTitle =>
      '¿Seguro que quieres continuar?';

  @override
  String get accountDeletionConfirmationMessage =>
      'Tu cuenta y todos los datos de la nube se eliminarán permanentemente. Esta acción no se puede deshacer.\n\n¿Quieres continuar?';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get deletingAccount => 'Eliminando cuenta...';

  @override
  String failedToDeleteCloudData(Object error) {
    return 'Error al eliminar los datos de la nube: $error';
  }

  @override
  String get accountDeletedSuccessfully => 'Cuenta eliminada correctamente';

  @override
  String failedToDeleteAccount(Object error) {
    return 'Error al eliminar la cuenta: $error';
  }

  @override
  String errorDeletingAccount(Object error) {
    return 'Error al eliminar la cuenta: $error';
  }

  @override
  String get changesDownloadedSuccessfully =>
      '¡Cambios descargados correctamente!';

  @override
  String get accountCreatedAndSignedInSuccessfully =>
      '¡Cuenta creada e iniciada correctamente!';

  @override
  String get signedInSuccessfully => '¡Inicio de sesión correcto!';

  @override
  String get authenticationFailed => 'Autenticación fallida';

  @override
  String unexpectedError(Object error) {
    return 'Se produjo un error inesperado: $error';
  }

  @override
  String warningWithValue(Object message) {
    return 'Advertencia: $message';
  }

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get signedOutSuccessfully => 'Se ha cerrado la sesión correctamente';

  @override
  String errorSigningOut(Object error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String downloadFailed(Object error) {
    return 'Error al descargar: $error';
  }

  @override
  String downloadError(Object error) {
    return 'Error de descarga: $error';
  }

  @override
  String get castingTime => 'Tiempo de lanzamiento';

  @override
  String get range => 'Alcance';

  @override
  String get components => 'Componentes';

  @override
  String get duration => 'Duración';

  @override
  String get ritual => 'Ritual';

  @override
  String get yes => 'Sí';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get atHigherLevels => 'A niveles superiores';

  @override
  String get dndCharacters => 'Personajes de D&D';

  @override
  String get searchCharacters => 'Buscar personajes...';

  @override
  String get createFirstCharacter =>
      'No se encontraron personajes. ¡Crea tu primer personaje!';

  @override
  String get syncAcrossDevices => 'Sincronizar entre dispositivos';

  @override
  String get characterDiaries => 'Diarios de personajes';

  @override
  String get noCharactersFoundDiary =>
      'No se encontraron personajes.\nCrea tu primer personaje para empezar a escribir diarios.';

  @override
  String get goToCharacters => 'Ir a personajes';

  @override
  String get information => 'Información';

  @override
  String get feats => 'Dotes';

  @override
  String get classes => 'Clases';

  @override
  String get races => 'Razas';

  @override
  String get weapons => 'Armas';

  @override
  String get backgrounds => 'Trasfondos';

  @override
  String get searchBackgrounds => 'Buscar trasfondos...';

  @override
  String get noBackgroundsFound => 'No se encontraron trasfondos.';

  @override
  String get searchClasses => 'Buscar clases...';

  @override
  String get noClassesFound => 'No se encontraron clases';

  @override
  String get hitDieLabel => 'Dado de golpe:';

  @override
  String get searchFeats => 'Buscar rasgos...';

  @override
  String get noFeatsFound => 'No se encontraron rasgos.';

  @override
  String get searchRaces => 'Buscar razas...';

  @override
  String get noRacesFound => 'No se encontraron razas.';

  @override
  String get searchWeapons => 'Buscar armas...';

  @override
  String get noWeaponsFound => 'No se encontraron armas';

  @override
  String get sourceLabel => 'Fuente:';

  @override
  String get activeFilters => 'Filtros activos:';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get searchFilterLabel => 'Búsqueda:';

  @override
  String get typeFilterLabel => 'Tipo:';

  @override
  String get dndSpells => 'Hechizos de D&D';

  @override
  String get filterSpells => 'Filtrar hechizos';

  @override
  String get searchSpells => 'Buscar hechizos...';

  @override
  String get levelFilter => 'Nivel:';

  @override
  String get classFilter => 'Clase:';

  @override
  String get schoolFilter => 'Escuela:';

  @override
  String get all => 'Todo';

  @override
  String get cantrip => 'Truco';

  @override
  String levelLabel(Object level) {
    return 'Nivel $level';
  }

  @override
  String get error => 'Error';

  @override
  String get noSpellsFound =>
      'No se encontraron hechizos. Prueba a ajustar la búsqueda o los filtros.';

  @override
  String get cloudSync => 'Sincronización en la nube';

  @override
  String get signInSyncDescription =>
      'Inicia sesión para sincronizar tus personajes y diarios en todos tus dispositivos';

  @override
  String get email => 'Correo electrónico';

  @override
  String get enterYourEmail => 'Introduce tu correo electrónico';

  @override
  String get pleaseEnterYourEmail => 'Introduce tu correo electrónico';

  @override
  String get pleaseEnterValidEmail => 'Introduce un correo electrónico válido';

  @override
  String get password => 'Contraseña';

  @override
  String get enterYourPassword => 'Introduce tu contraseña';

  @override
  String get pleaseEnterYourPassword => 'Introduce tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get forgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get accountCreationDisabled =>
      'La creación de cuentas está temporalmente desactivada. Inicia sesión con una cuenta existente o vuelve a intentarlo más tarde.';

  @override
  String get accountCreationInfo =>
      'Si aún no tienes una cuenta, la crearemos automáticamente cuando inicies sesión.';

  @override
  String get signingIn => 'Iniciando sesión...';

  @override
  String get syncFeatureTitle => 'Con la sincronización en la nube puedes:';

  @override
  String get cloudSyncFeature1 =>
      'Accede a tus personajes desde cualquier dispositivo';

  @override
  String get cloudSyncFeature2 =>
      'Copia de seguridad automática de todos tus datos';

  @override
  String get cloudSyncFeature3 => 'Sincroniza diarios y fichas de personaje';

  @override
  String get cloudSyncFeature4 => 'Nunca pierdas los datos de tu campaña';

  @override
  String get signInTemporarilyDisabled =>
      'El inicio de sesión está temporalmente deshabilitado. Inténtalo más tarde o contacta con soporte.';

  @override
  String get downloadingCloudData => 'Descargando tus datos de la nube...';

  @override
  String get dataSyncSuccessfully =>
      '¡Sincronización completada correctamente!';

  @override
  String couldNotDownloadCloudData(Object error) {
    return 'No se pudieron descargar los datos de la nube: $error';
  }

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get resetPasswordDescription =>
      'Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get pleaseEnterEmailAddress =>
      'Introduce tu dirección de correo electrónico';

  @override
  String get passwordResetEmailSent =>
      '¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada (o la carpeta de spam).';

  @override
  String get createNewCharacter => 'Crear nuevo personaje';

  @override
  String get fillCharacterDetails =>
      'Rellena los detalles a continuación para crear tu personaje';

  @override
  String get characterName => 'Nombre del personaje';

  @override
  String get characterNameRequired => 'El nombre del personaje es obligatorio';

  @override
  String get characterLevel => 'Nivel del personaje';

  @override
  String get characterLevelRequired => 'El nivel del personaje es obligatorio';

  @override
  String get classLabel => 'Clase';

  @override
  String get customSubclass => 'Subclase personalizada';

  @override
  String get subclassOptional => 'Subclase (opcional)';

  @override
  String get clearSubclass => 'Borrar subclase';

  @override
  String get chooseSubclass => 'Elegir entre subclases predefinidas';

  @override
  String get customSubclassPlaceholder => 'Subclase personalizada...';

  @override
  String get raceOptional => 'Raza (opcional)';

  @override
  String get clearRace => 'Borrar raza';

  @override
  String get backgroundOptional => 'Trasfondo (opcional)';

  @override
  String get clearBackground => 'Borrar trasfondo';

  @override
  String get creatingCharacter => 'Creando...';

  @override
  String validLevelRange(Object min, Object max) {
    return 'Introduce un nivel válido entre $min y $max';
  }
}
