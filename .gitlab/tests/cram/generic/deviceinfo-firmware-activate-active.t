Create R alias; pick the active bank:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ ACTIVE=$(R "ba-cli 'DeviceInfo.ActiveFirmwareImage?'" | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ test -n "$ACTIVE" || exit 80

Activating the already-active bank is not honored as a fresh activation - the
active/booted image is unchanged (no switch):

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Activate(Start=0,End=10,Mode=\"Immediately\")'" > /dev/null 2>&1
  $ sleep 3
  $ R "ba-cli 'DeviceInfo.ActiveFirmwareImage?'" | grep -oE "FirmwareImage.$ACTIVE\"" | wc -l | tr -d ' '
  1

Restore the bank status (the failed self-activation marks the active bank failed):

  $ R "/etc/init.d/deviceinfo-manager restart" > /dev/null 2>&1
  $ for i in $(seq 1 15); do R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Status?'" | grep -qF '="Active"' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Status?'" | grep -oE 'Status="Active"'
  Status="Active"
