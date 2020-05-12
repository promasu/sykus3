define({
  root: {
    titleMain: 'Einstellungen',

    btnSave: 'Einstellungen speichern',

    catCommon: 'Allgemein',
    catWLAN: 'Client-WLAN',
    catRADIUS: 'RADIUS-Server',
    catSMART: 'SMART Board',

    schoolName: 'Schulname',
    schoolNameText: 'Der Name der Schule, der oben rechts im Webinterface ' + 
      'und beim Client-Login angezeigt wird.',

    wlanSSID: 'SSID',
    wlanKey: 'WPA-Personal PSK',
    wlanText: 
    'Mit diesen WLAN-Daten verbinden sich die Sykus-Clients ' +
      'automatisch mit dem Netzwerk. Es wird automatisch erkannt, ob ' +
      'der Access-Point WPA-Personal oder WPA-Enterprise benutzt. ' + 
      'Wenn Sie kein WPA-Personal benutzen ' +
      'möchten, lassen Sie das entsprechende Feld leer. Sie müssen ein ' +
      'neues Image erstellen, damit diese Einstellungen wirksam werden.',

    radiusSecret: 'Shared Secret',
    radiusSecretText: 'Mit diesem Passwort authentifizieren sich ' + 
      'die RADIUS Clients am Server. Bitte beachten Sie, dass Sie alle ' +
      'Access-Points etc. neu konfigurieren müssen, ' +
      'wenn Sie dieses Passwort ändern.',

    smartSerial: 'Notebook Key',
    smartSerialText: 'Der Produktschüssel für die SMART Notebook Software. ' +
      'Sie müssen das entsprechende ' +
      'Paket in der Softwareverwaltung auswählen und ein neues Image ' +
      'erstellen, damit der Schlüssel benutzt wird. ' + 
      'Wenn Sie keinen oder einen ungültigen Schlüssel eingeben, ' +
      'wird die Testversion installiert.',

    savedAlert: 'Einstellungen gespeichert.'
  }
});

