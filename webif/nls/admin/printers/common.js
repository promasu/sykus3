define({
  root: {
    // PrinterList
    name: 'Name',
    driver: 'Druck~er~mo~dell',
    url: 'URL',
    hostGroups: 'Rech~ner~grup~pen',
    printersTitle: 'Drucker',
    createPrinter: 'Drucker hinzufügen',
    updatePrinter: 'Drucker bearbeiten',
    updatePrinterShort: 'Bearbeiten',
    deletePrinter: 'Drucker löschen',
    deletePrinterShort: 'Löschen',
    resetPrinter: 'Drucker zurücksetzen',
    resetResult: 'Drucker zurückgesetzt',
    printerListTitle: 'Druckerliste',

    // PrinterForm
    formLegendCommon: 'Allgemein',
    formLegendHostGroups: 'Rechnergruppen',
    formAddGroup: 'Rechnergruppe hinzufügen...',
    formDriver: 'Modellname eingeben...',

    urlDiscoveredText: 'Folgende Drucker wurden automatisch erkannt:',

    urlHelpText: 'Alle Drucker müssen im IP-Adressenbereich ' + 
      '<em>10.42.2.1</em> - <em>10.42.99.255</em> liegen. ' + 
      'Folgende Protokolle sind erlaubt: ' + 
      '<em>ipp, lpd, socket</em>.' + 
      '<br><br><strong>Beispiele:</strong><br>' +
      '<em>socket://10.42.20.1</em><br>' +
      '<em>lpd://10.42.40.12/lp1</em><br>' +
      '<em>ipp://10.42.40.90/printers/pr1</em>',

    validateName: 'Ungültiger Name.',
    validateURL: 'Bitte URL eingeben.',
    validateDriver: 'Bitte gültiges Modell aussuchen.',

    // PrinterList + PrinterForm alerts
    printerCreatedAlert: 
    'Drucker <strong>{{name}}</strong> erstellt.',
    printerDeletedAlert: 
    'Drucker <strong>{{name}}</strong> gelöscht.',
    resetAlert:
    'Drucker <strong>{{name}}</strong> zurückgesetzt.',

    printerUpdatedAlert: 
    'Änderungen an <strong>{{name}}</strong> gespeichert.',

    resetText: 
    'Wollen Sie den Drucker <strong>{{printer.name}}</strong> ' +
      'zurücksetzen?',
    resetButton: 'Ja, Drucker zurücksetzen!',

    printerDeleteText: 'Wollen Sie den Drucker ' +
      '<strong>{{printer.first_name}} {{printer.last_name}}</strong> ' + 
      'wirklich löschen?',
    printerDeleteButton: 'Ja, <strong>{{printer.name}}</strong> löschen!'
  }
});

