define({
  root: {
    // UserList
    usersTitle: 'Benutzer',
    createUser: 'Benutzer erstellen',
    updateUser: 'Benutzer bearbeiten',
    updateUserShort: 'Bearbeiten',
    deleteUser: 'Benutzer löschen',
    deleteUserShort: 'Löschen',
    passwordReset: 'Passwort zurücksetzen',
    passwordResetResult: 'Passwort zurückgesetzt',
    userListTitle: 'Benutzerliste',
    gridPositionGroup: 'Sta~tus',
    gridAdminGroup: 'Ad~min',
    quotaUsed: 'Spei~cher~platz',

    // UserForm
    formLegendCommon: 'Persönliche Daten',
    formLegendPosition: 'Status',
    formLegendAdmin: 'Administrator-Status',

    validateFullName: 'Ungültiger Name.',
    validateBirthdate: 'Bitte Geburtsdatum im Format TT.MM.JJJJ eingeben.',
    validateUserClass: 'Bitte Schulklasse auswählen.',

    // Position + Admin
    positionStudent: 'Schüler',
    positionStudentText: 'Der Benutzer ist Schüler an der Schule.',
    positionStudentUserClass: 
    'Er ist dieser <strong>Schulklasse zugeordnet</strong>:',
    positionTeacher: 'Lehrer',
    positionTeacherText: 'Der Benutzer ist Lehrer an der Schule. Er hat ' +
      'Zugriff auf die <strong>pädagogischen Funktionen</strong> und kann ' +
      '<strong>Benutzergruppen anlegen</strong>. ' +
      'Außerdem kann er <strong>Schülerpasswörter zurücksetzen</strong>.',
    positionPerson: 'Person',
    positionPersonText: 'Der Benutzer ist weder Schüler noch Lehrer.',

    adminNone: 'Kein Administrator',
    adminNoneShort: 'Nein',
    adminNoneText: 'Der Benutzer hat keine Administratorrechte.',

    adminJunior: 'Junioradmin',
    adminJuniorShort: 'Junior',
    adminJuniorText: 'Der Benutzer hat ' +
      '<strong>stark eingeschränkte</strong> ' +
      'Administratorrechte. Diese beinhalten Schreibzugriff auf ' +
      'Internetfilter, Rechner und Schülerpasswörter. Außerdem sind ' +
      'Lesezugriffe auf fast alle Bereiche erlaubt.',

    adminSenior: 'Senioradmin',
    adminSeniorShort: 'Senior',
    adminSeniorText: 'Der Benutzer hat <strong>nahezu alle</strong> ' +
      'Administratorrechte. ' +
      'Diese beinhalten neben denen des Junioradmins und des Lehrers ' +
      'auch Schreibzugriff auf Benutzer, Software und Drucker. ' +
      'Vergeben Sie diese Admin-Stufe nur an <strong>sorgfältig ' +
      'ausgewählte</strong> Personen.',

    adminSuper: 'Superadmin',
    adminSuperShort: 'Super',
    adminSuperText: 'Dieser Benutzer hat <strong>alle</strong> ' +
      'Administratorrechte.  ' +
      'Vergeben Sie diese Admin-Stufe <strong>nur an Personen, denen Sie ' +
      'absolut vertrauen!</strong> ' +
      'Sie sollten diese Admin-Stufe <strong>nie an Schüler oder Personen ' +
      'ohne fundierte IT-Kenntnisse</strong> vergeben.',


    // UserClasses
    userClassesTitle: 'Schulklassen',
    createUserClass: 'Schulklasse erstellen',
    deleteUserClass: 'Schulklasse löschen',

    userClass: 'Schul~klas~se',
    userClassShort: 'Klas~se',
    userClassChoose: '(Bitte auswählen)',
    userClassName: 'Schul~klas~se',
    userClassGrade: 'Jahr~gang',
    userClassUsers: 'Schü~ler',
    createUserClassAlert: 'Schulklasse erstellt.',
    userClassDeleteText: 'Die Schulklasse <strong>{{data.name}}</strong> ' +
      ' hat keine Schüler. Wollen Sie die Schulklasse löschen?',
    userClassDeleteButton: 'Ja, <strong>{{data.name}}</strong> löschen!',
    userClassDeletedAlert: 'Schulklasse gelöscht.',
    userClassDeleteEmptyAlert: 'Es sind noch Schüler in dieser Klasse ' +
      'vorhanden. Die Schulklasse kann nicht gelöscht werden.<br><br>' +
      'Schulklassen können nicht nachträglich bearbeitet werden. Benutzen ' +
      'Sie die Benutzerliste, um Schüler anderen Klassen zuzuordnen.',


    // UserGroupList
    userGroupListTitle: 'Benutzergruppen',
    createUserGroup: 'Benutzergruppe erstellen',
    userGroupName: 'Grup~pen~na~me',
    userGroupOwner: 'Ei~gen~tü~mer',
    userGroupUsers: 'Mit~glie~der',
    deleteUserGroup: 'Benutzergruppe löschen',
    userGroupDeleteText: 'Wollen Sie die Benutzergruppe <strong>' +
      '{{userGroup.name}}</strong> ' +
      'von <strong>{{userGroup.owner}}</strong> löschen? ' +
      'Es werden <strong>alle Gruppendateien gelöscht</strong>!',
    userGroupDeleteButton: 'Ja, <strong>{{userGroup.name}}</strong> löschen!',
    deleteUserGroupShort: 'Löschen',
    updateUserGroup: 'Benutzergruppe bearbeiten',
    updateUserGroupShort: 'Bearbeiten',
    userGroupDeletedAlert: 'Benutzergruppe gelöscht.',

    // UserGroupForm
    formLegendGroupCommon: 'Allgemein',
    formLegendGroupMembers: 'Mitglieder',
    formAddGroupMember: 'Benutzer hinzufügen...',
    formNoGroupMembers: 'Keine Mitglieder',
    formGroupUserPlaceholder: 'Namen eingeben...',
    validateUserGroupName: 'Ungültiger Gruppenname.',
    validateUserGroupOwner: 'Bitte Benutzer auswählen.',
    userGroupCreatedAlert: 'Benutzergruppe erstellt.',
    userGroupUpdatedAlert: 'Änderungen gespeichert.',

    // UserImport
    userImportTitle: 'Benutzerimport',
    importLegendGroup: 'Welche Benutzer sollen importiert werden?',
    importLegendDelete: 'Alte Benutzer löschen?',
    importLegendData: 'Importliste',
    importLegendResult: 'Ergebnis',

    importBtnCheck: 'Daten auswerten',
    importBtnConfirm: 'Import ausführen',
    importActionTitle: 'Aktion',

    importDeleteTrue: 'Alte Benutzer löschen',
    importDeleteFalse: 'Alte Benutzer behalten',

    importDeleteTrueText: 'Alle Benutzer mit dem gewählten Personenstatus, ' +
      'die nicht in der Importliste vorhanden sind, werden gelöscht. ' +
      'Bestehende Benutzer, die in der Importliste vorhanden sind, ' +
      'werden aktualisiert.<br><br>Leere Schulklassen werden gelöscht. ' +
      'Es werden keine Benutzer mit Administratorstatus gelöscht.<br><br>' +
      'Benutzen Sie diese Option, wenn Sie <strong>am Anfang des ' + 
      'Schuljahres alle Schüler und Lehrer importieren</strong> möchten.',

    importDeleteFalseText: 'Bestehende Benutzer werden nicht gelöscht, ' +
      'wenn sie nicht mehr in der Importliste vorhanden sind. ' +
      'Bestehende Benutzer, die in der Importliste vorhanden sind, ' +
      'werden aktualisiert.<br><br> ' +
      'Benutzen Sie diese Option, wenn Sie nur <strong>einige Benutzer ' + 
      'hinzufügen</strong> möchten.',

    importDataTextStudent: '<strong>Format:</strong> ' +
      'Nachname;Vorname;Geburtsdatum;Klasse<br>' +
      '<strong>Beispiel:</strong> <em>Meier;Jan;15.09.1995;7c</em>',

    importDataTextTeacher: '<strong>Format:</strong> ' +
      'Nachname;Vorname;Geburtsdatum<br>' +
      '<strong>Beispiel:</strong> <em>Hoffmann;Sabine;11.08.1974</em>',

    importActionNewText: 'Neu',
    importActionNewTitle: 'Der Benutzer wird neu erstellt.',
    importActionUpdatedText: 'Aktualisiert',
    importActionUpdatedTitle: 
    'Die Schulklasse des Benutzers wurde aktualisiert.',
    importActionDeletedText: 'Gelöscht',
    importActionDeletedTitle: 'Der Benutzer wird gelöscht.',

    importAlert: 'Benutzer wurden importiert.',

    // InitialPasswords
    initialPasswordsTitle: 'Erstanmeldung / Initiale Passwörter',
    initialPasswordsOutput: 'Ausgabe / Druckvorschau',
    initialPasswordsBtnPrint: 'Anmeldedaten drucken',
    initialPasswordsSelectAll: 'Alle',
    initialPasswordsSelectNone: 'Keine',
    initialPasswordsHelpText: 
    'Jedem neu erstellten Benutzer wird aus Sicherheitsgründen ein ' +
      'zufälliges Passwort zugewiesen, das beim ersten Login ' +
      'geändert werden muss.<br><br>' +
      'Mit dieser Funktion können Sie Listen mit den initialen Zugangsdaten ' +
      'ausdrucken. <br><br> ' + 
      'Es werden nur Benutzer angezeigt, die ihr Passwort noch nicht geändert ' +
      'haben. Außerdem werden keine Benutzer mit Administratorrechten ' + 
      'angezeigt. <br><br>' +
      'Bitte achten Sie darauf, dass Unbefugte keine Einsicht in die ' +
      'ausgedruckten Listen haben. Der Ausdruck ist so konzipiert, dass er ' +
      'zerschnitten und an die jeweiligen Benutzer verteilt werden kann.' +
      '<br><br>' +
      'Bitte wählen Sie aus, für welche Klassen Sie die Anmeldedaten ' + 
      'ausdrucken möchten:',

    initialPasswordEntryHelpText: 
    'Bitte melden Sie sich mit diesen Zugangsdaten in den nächsten Tagen am ' +
      'Schulnetzwerk an. Sie können dann ein neues Passwort vergeben.',


    // UserList + UserForm alerts
    userCreatedAlert: 
    'Benutzer <strong>{{username}}</strong> erstellt.',
    userDeletedAlert: 
    'Benutzer <strong>{{username}}</strong> gelöscht.',
    passwordResetAlert:
    'Passwort von <strong>{{username}}</strong> zurückgesetzt.',

    userUpdatedAlert: 
    'Änderungen an <strong>{{username}}</strong> gespeichert.',

    passwordResetText: 
    'Wollen Sie das Passwort von <strong>{{user.username}}</strong> ' +
      'zurücksetzen?',
    passwordResetButton: 'Ja, Passwort zurücksetzen!',
    passwordResetResultText:
    'Das neue Passwort von <strong>{{user.username}}</strong>:<br>' +
      '<p class="text-center user-selectable">' +
      '<strong>{{password}}</strong></p>',
    passwordResetResultButton: 'Ja, habe ich mir gemerkt!',

    userDeleteText: 'Wollen Sie den Benutzer ' +
      '<strong>{{user.first_name}} {{user.last_name}}</strong> ' + 
      'wirklich löschen?',
    userDeleteButton: 'Ja, <strong>{{user.username}}</strong> löschen!',

    usernameChange: 'Benutzername geändert',
    usernameChangeText: 
    'Benutzer <strong>{{oldName}}</strong> wird nun ' + 
      '<strong>{{newName}}</strong> heißen.',
    usernameChangeButton: 'Ja, Benutzer umbenennen!',

    duplicateUsername: 'Doppelter Benutzername',
    duplicateUsernameText:
    'Es ist bereits ein Benutzer <strong>{{basename}}</strong> vorhanden.',
    duplicateUsernameButton:
    'Ja, {{username}} erstellen!',

    adminConfirmTitle: 'Admin-Status geändert',
    adminConfirmText: 'Soll der Benutzer wirklich die gewählte Admin-Stufe ' +
      'erhalten?', 
    adminConfirmButton: 'Ja, Admin-Status ändern!'
  }
});

