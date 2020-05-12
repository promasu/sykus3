#!/bin/busybox sh

show_groups() {
  echo "Gruppe existiert nicht. Bitte eine der folgenden Gruppen benutzen:"
  sni_api "groups?session=$SESSION"
  echo -e "\n"
}

while true; do
  echo -e "\n"
  echo "Neuen Rechner anmelden"
  echo "----------------------"

  while true; do  
    echo -n "Benutzername: "
    read USER

    echo -n "Passwort: "
    read -s PASS
    PASS="$(echo -n "$PASS" |sha256sum |cut -d' ' -f1)"
    PASS="$(echo -n "SYKUSSALT$PASS" |sha256sum |cut -d' ' -f1)"

    SESSION="$(sni_api "login?username=$USER&password=$PASS")"

    if [ "$(echo "$SESSION" |cut -d':' -f1)" == "err" ]; then
      echo -e "\nAuthentifizierung fehlerhaft.\n"
    else
      echo -e "\nAuthentifizierung OK."
      break
    fi
  done

  echo
  while true; do
    echo -n "Rechnergruppe: "
    read GROUP

    if [ "$GROUP" == "" ]; then
      show_groups
    else
      break
    fi
  done

  echo -n "Rechnername: "
  read NAME

  MAC="$(cat /tmp/net.mac)"
  RES=$(sni_api "add?session=$SESSION&name=$NAME&host_group=$GROUP&mac=$MAC")

  echo
  case "$RES" in
    "ok")
      echo "Rechner angemeldet."
      break
      ;;
    "err:invalidsession")
      echo "Sitzung abgelaufen".
      ;;
    "err:input")
      echo "Ungültige Eingabe."
      ;;
    "err:notfound")
      echo "Rechnergruppe nicht gefunden."
      show_groups
      ;;
    *)
      echo "Fehler. Dies sollte nicht passieren."
      break
      ;;
  esac

done

sleep 60 && reboot &
echo
echo "Enter zum Neustarten..."
read DUMMY
reboot
sleep 3600

