Create R alias; pick the active bank and make the other bank unavailable:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ ACTIVE=$(R "ba-cli 'DeviceInfo.ActiveFirmwareImage?'" | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ INACTIVE=$(R "ba-cli 'DeviceInfo.FirmwareImage.*.Status?'" | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | sort -u | grep -v "^$ACTIVE\$" | head -1)
  $ test -n "$ACTIVE" || exit 80
  $ test -n "$INACTIVE" || exit 80
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$INACTIVE.Download(URL=\"http://127.0.0.1:1/x.swu\",AutoActivate=0)'" > /dev/null 2>&1
  $ for i in $(seq 1 15); do R "ba-cli 'DeviceInfo.FirmwareImage.$INACTIVE.Available?'" | grep -qF 'Available=0' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$INACTIVE.Available?'" | grep -oE 'Available=0'
  Available=0

Activating an unavailable bank is rejected and does not activate it:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$INACTIVE.Activate(Start=0,End=10,Mode=\"Immediately\")'" 2>&1 | grep -oE 'unknown error'
  unknown error
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$INACTIVE.Status?'" | grep -oE '="Active"' | wc -l | tr -d ' '
  0

Activating with an unsupported Mode is rejected:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Activate(Start=0,End=10,Mode=\"Bogus\")'" 2>&1 | grep -oE 'invalid argument'
  invalid argument

Activating with Start not less than End is rejected:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Activate(Start=100,End=10,Mode=\"Immediately\")'" 2>&1 | grep -oE 'invalid argument'
  invalid argument

Pointing BootFirmwareImage at an unavailable bank is rejected and unchanged:

  $ R "ba-cli 'DeviceInfo.BootFirmwareImage=\"DeviceInfo.FirmwareImage.$INACTIVE\"'" 2>&1 | grep -oE 'invalid value'
  invalid value
  $ R "ba-cli 'DeviceInfo.BootFirmwareImage?'" | grep -oE "FirmwareImage.$INACTIVE\"" | wc -l | tr -d ' '
  0

Disabling the active bank (Available=false) is rejected and stays true:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Available=false'" 2>&1 | grep -oE 'invalid value'
  invalid value
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Available?'" | grep -oE 'Available=[01]'
  Available=1
