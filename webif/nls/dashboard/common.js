define({
  root: {
    title: 'Guten Tag, {{user.first_name}} {{user.last_name}}!',

    roomctlTitle: 'Raumsteuerung',
    roomctlText: 'Sie befinden sich in einem Computerraum, den Sie ' +
      '<a href="#teacher/RoomCtl"><strong>steuern können</strong></a>.',

    quotaTitle: 'Speicherplatz',
    quotaText: 'Sie benutzen momentan ' + 
      '<strong>{{dashboard.quota_used}} MB</strong> von ' + 
      '<strong>{{dashboard.quota_total}} MB</strong> Speicherplatz.',

    quotaWarning: 'Ihr Speicherplatz ist fast vollständig belegt. ' +
      'Bitte leeren Sie den Papierkorb und löschen große Dokumente, ' +
      'die Sie nicht mehr benötigen.',

    remoteTitle: 'Eigene Geräte',
    remoteText: 'Erfahren Sie <a href="#dashboard/Remote">hier</a>, ' +  
      'wie Sie in der Schule und von zu Hause aus mit Ihren ' + 
      '<a href="#dashboard/Remote">eigenen Geräten</a> arbeiten können.'

  }
});

