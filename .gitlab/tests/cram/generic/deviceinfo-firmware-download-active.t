Create R alias; pick the active bank:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ ACTIVE=$(R "ba-cli 'DeviceInfo.ActiveFirmwareImage?'" | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ test -n "$ACTIVE" || exit 80

Download on the active bank with AutoActivate=false is rejected:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Download(URL=\"http://127.0.0.1:1/x.swu\",AutoActivate=0)'" 2>&1 | grep -oE 'invalid argument'
  invalid argument

Download on the active bank with AutoActivate=true is not supported:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Download(URL=\"http://127.0.0.1:1/x.swu\",AutoActivate=1)'" 2>&1 | grep -oE 'not supported'
  not supported
