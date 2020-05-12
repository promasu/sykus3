define({
  root: {
    // HostList
    hostListTitle: 'Rechnerliste',
    hostGroup: 'Grup~pe',
    hostName: 'Name',
    ip: 'IP-Ad~res~se',
    mac: 'MAC-Ad~res~se',
    cpuSpeed: 'CPU',
    ramMB: 'RAM',
    online: 'Sta~tus',
    ready: 'Be~reit~?',

    onlineTrue: 'Online',
    onlineFalse: 'Offline',

    cpuSpeedTitle: 'Referenzwert: Pentium 4, 2 GHz (100 %)',
    readyTrueTitle: 'Der Rechner kann benutzt werden.',
    readyFalseTitle: 'Das Image muss noch installiert werden werden.',

    createHost: 'Rechner hinzufügen',
    createHostTitle: 'Rechner hinzufügen',
    createHostText: 'Bitte binden Sie neue Rechner direkt über die ' + 
      'Netzwerkinstallation in das System ein. Starten Sie dazu den ' +
      'Rechner mit Netzwerk-Boot (PXE).<br><br>Private Rechner müssen ' +
      'nicht eingetragen werden.',
    reinstallHost: 'Image neu installieren',
    reinstallHostShort: 'Neu installieren',
    updateHost: 'Rechner bearbeiten',
    updateHostShort: 'Bearbeiten',
    deleteHost: 'Rechner löschen',
    deleteHostShort: 'Löschen',

    // HostGroupList
    hostGroupListTitle: 'Rechnergruppen',
    createHostGroup: 'Rechnergruppe erstellen',
    hostGroupName: 'Grup~pen~na~me',
    hostGroupNameShort: 'Name',
    hostGroupMembers: 'Rech~ner',

    deleteHostGroup: 'Rechnergruppe löschen',
    hostGroupDeleteText: 'Wollen Sie die Rechnergruppe <strong>' +
      '{{hostGroup.name}}</strong> mit <strong>' +
      'allen enthaltenen Rechnern</strong> löschen?',
    hostGroupDeleteButton: 'Ja, <strong>{{hostGroup.name}}</strong> löschen!',
    deleteHostGroupShort: 'Löschen',
    updateHostGroup: 'Rechnergruppe bearbeiten',
    updateHostGroupShort: 'Bearbeiten',
    hostGroupUpdatedAlert: 'Änderungen gespeichert.',
    hostGroupCreatedAlert: 'Rechnergruppe erstellt.',
    hostGroupDeletedAlert: 'Rechnergruppe gelöscht.',

    // PackageList
    packageListTitle: 'Softwarepakete',
    packageName: 'Name',
    packageCategory: 'Ka~te~go~rie',
    packageText: 'Be~schrei~bung',
    packageDefault: 'Sta~tus',
    packageSelected: 'Aus~ge~wählt?',
    packageInstalled: 'In~stal~liert?',

    packageSelect: 'Paket installieren',
    packageUnselect: 'Paket deinstallieren',

    packageDefaultTrue: 'Empfohlen',
    packageDefaultFalse: 'Optional',
    packageDefaultTrueTitle: 
    'Dieses Paket gehört zum Standardumfang und wird oft verwendet.',
    packageDefaultFalseTitle:
    'Dieses Paket sollte nur installiert werden, wenn Sie es benötigen.',

    packageSelectedTrueTitle: 
    'Dieses Paket wird in das nächste Image aufgenommen.',
    packageSelectedFalseTitle:
    'Dieses Paket wird nicht in das nächste Image aufgenommen.',

    packageInstalledTrueTitle:
    'Dieses Paket ist im aktuellen Image installiert.',
    packageInstalledFalseTitle:
    'Dieses Paket ist nicht im aktuellen Image vorhanden.',

    packageSelectedAlert: 
    'Auswahl für <strong>{{name}}</strong> gespeichert.',

    // Image
    imageStateIdle: 'Image erstellen',
    imageStateScheduled: 'Image geplant',
    imageStateRunning: 'Image wird erstellt',
    createImageAlert: 'Das Image wird erstellt.',
    abortImageAlert: 'Die Erstellung des Images wird abgebrochen.',

    imagePopoverIdleText:
    'Soll das Image sofort oder heute Nacht erstellt werden?',

    imagePopoverCreateNow: 'Image jetzt erstellen',
    imagePopoverCreateLater: 'Image nachts erstellen',

    imagePopoverRunningText:
    'Wollen Sie den Vorgang abbrechen?',

    imagePopoverAbort: 'Image abbrechen',

    // HostList alerts
    hostDeletedAlert: 
    'Rechner <strong>{{name}}</strong> gelöscht.',
    reinstallHostAlert:
    'Das Image wird auf <strong>{{name}}</strong> neu installiert.',
    hostUpdatedAlert: 
    'Änderungen an <strong>{{name}}</strong> gespeichert.',

    reinstallHostText: 
    'Wollen Sie das Image auf <strong>{{host.name}}</strong> ' +
      'neu installieren lassen?',
    reinstallHostButton: 'Ja, Image neu installieren!',
    hostDeleteText: 'Wollen Sie den Rechner ' +
      '<strong>{{host.name}}</strong> wirklich löschen?',
    hostDeleteButton: 'Ja, <strong>{{host.name}}</strong> löschen!'
  }
});

