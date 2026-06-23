Create R alias; find the active bank and an available bank to activate, skip if
there is none:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ ACTIVE=$(R "ba-cli 'DeviceInfo.ActiveFirmwareImage?'" | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ R "ba-cli 'DeviceInfo.FirmwareImage.*.Status?'" | grep -E '="Available"' > /tmp/cram-fwi-available.txt
  $ TARGET=$(grep -oE 'FirmwareImage\.[0-9]+' /tmp/cram-fwi-available.txt | grep -oE '[0-9]+' | head -1)
  $ test -n "$ACTIVE" || exit 80
  $ test -n "$TARGET" || exit 80

Trigger Activate with a future Start (8s) in the background:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$TARGET.Activate(Start=8,End=60,Mode=\"Immediately\")'" > /tmp/cram-activate.out 2>&1 &
  $ sleep 3

During the time window the bank is not yet activated:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$TARGET.Status?'" | grep -oE '="Active"' | wc -l | tr -d ' '
  0

After the timer elapses the bank becomes Active:

  $ for i in $(seq 1 25); do R "ba-cli 'DeviceInfo.FirmwareImage.$TARGET.Status?'" | grep -q '="Active"' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$TARGET.Status?'" | grep -oE 'Status="Active"'
  Status="Active"

Restore the original active bank:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$ACTIVE.Activate(Start=0,End=10,Mode=\"Immediately\")'" > /dev/null 2>&1
  $ wait
